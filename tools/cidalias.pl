#!/usr/bin/perl -w

# Created by Aron Green on Sun Nov 24, 2002
#
# Copyright (c) 2001-2015 by
#   Aron Green
#   John L. Chmielewski <jlc@users.sourceforge.net>
#   Steve Limkemann
#   Todd Andrews <tandrews@users.sourceforge.net>

use strict;
use warnings;
use Pod::Usage;
use File::Basename;
use Getopt::Long qw(:config no_ignore_case_always);

my ($help, $man, $version, $bflag, $label, $newname);
my ($alias, $blacklist, $whitelist, $name, $number, $from, $to, $search);
my (@multiples, $line, $index, $action, $lastAction, $listname);
my %listed = (bl => 0, wl => 0, bn => "", wn => "");
my $blwl = "bl";
my ($ret, $listfile, @list_files);
my ($aliasType, $stripOne, @columns);
my ($file_col, $line_col, $nmbr_col, $name_col, $type_col, $nmbr_note_col, $name_note_col, $nmbr_col2, $name_col2, $type_col2, $nmbr_note_col2, $name_note_col2) = (0..11);
my $lineCount;
my ($humanReadable, $delimited) = (1, 2);
my $outputFormat = $humanReadable;
my $delimiter = ",";

my $prog = basename($0);
my $VERSION = "(NCID) XxXxX";

my $ALIAS     = "/etc/ncid/ncidd.alias";
my $BLACKLIST = "/etc/ncid/ncidd.blacklist";
my $WHITELIST = "/etc/ncid/ncidd.whitelist";

format STDOUT =
@<<<<<<<<< @<<<<<<<<<<<<<<<<<<<< @<<<<<<< @<<<<<<<<<<<<<<<<<<<<
$listname, $search,              $label,  $newname
.

Getopt::Long::Configure ("bundling");
my ($result) = GetOptions(
    "help|h"            => \$help,
    "man|m"             => \$man,
    "version|V"         => \$version,
    "format|f=i"        => \$outputFormat,
    "delimiter|d=s"     => \$delimiter,
    "strip-one|1"       => \$stripOne,
    "alias|a=s"         => \$alias,
    "blacklist|b=s"     => \$blacklist,
    "whitelist|w=s"     => \$whitelist

 ) || pod2usage(2);
die "$prog $VERSION\n" if $version;
pod2usage(-verbose => 1, -exitval => 0) if $help;
pod2usage(-verbose => 2, -exitval => 0) if $man;

$alias = $ALIAS if !defined $alias;
$blacklist = $BLACKLIST if !defined $blacklist;
$whitelist = $WHITELIST if !defined $whitelist;

if ( ($outputFormat < 0) || ($outputFormat > 2) ) { die "Format option must be in the range of 0-2.";}

$delimiter = pack ('H2', '09') if $delimiter eq "t";

if ($outputFormat == $delimited) { 
   #create column headings
   &initColumns;
   $columns[$file_col] = "File Name";
   $columns[$line_col] = "Line Count";
   $columns[$nmbr_col] = "Number";
   $columns[$name_col] = "Name";
   $columns[$type_col] = "Alias Type";
   $columns[$nmbr_note_col] = "Number Notes";
   $columns[$name_note_col] = "Name Notes";
   &doDelimited;
}   

if ( ($outputFormat == $humanReadable) || ($outputFormat == $delimited) ) {
    @list_files = ($blacklist, $whitelist);
    foreach my $file (@list_files)
    {
        if ($file eq $blacklist) {
            $bflag = 1;
        } else {
            $bflag = 0;
        }
        $listfile = $file;
        &doList;
        $blwl = "wl";
    }
} else { print "Raw mode ignores $blacklist and $whitelist\n"; }

open(ALIASFILE, $alias) || die "Could not open $alias\n";

$lineCount = 0;

while (<ALIASFILE>) {
    if (!$outputFormat) {print; next;}
    $lineCount ++;
    next if (/^\s*#/ || /^$/);
    $line = $number = $name = undef;
    &initColumns; $columns[$file_col]=$alias; $columns[$line_col]=$lineCount;
    $aliasType = "UNKNOWN";
    if (/^\s*alias/) {
        chomp;
        s/\s+#.*$//;
        if (/alias NAME/) {
            if (/\s+if\s+/) {
                # alias NAME __ = "___" if "___"
                $aliasType = "NAMEDEP";
                ($name, $number) = /.*=\s+"?([^"]*)"?\s+if\s+"?([^"]*)"?/;
                $line = "If number is $number, change name to: $name\n";
                $search = $number;
                ($columns[$nmbr_col], $columns[$nmbr_note_col]) = (normalizeNumber($number));
                ($columns[$name_col], $columns[$name_note_col]) = (checkNameLength($name));
                $columns[$type_col] = $aliasType;
            } else {
                # alias NAME "___" = "___""___"
                $aliasType = "NAMEONLY";
                ($from, $to) = /NAME\s+"?([^"]*)"?\s+=\s+"?([^"]*)"?/;
                $line = "Change name from: $from To: $to\n";
                $search = $to;
                $columns[$name_col] = $from;
                $columns[$type_col] = $aliasType . "-FROM";
                ($columns[$name_col2], $columns[$name_note_col2]) = (checkNameLength($to));
                $columns[$type_col2] = $aliasType . "-TO";
            }
        } elsif (/alias NMBR/) {
            if (/\s+if\s+/) {
                # alias NMBR "___" = "___" if "___"
                $aliasType = "NMBRDEP";
                ($number, $name) = /=\s+"?([^"]*)"?\s+if\s+"?([^"]*)"?/;
                $line =  "If name is $name, change number to: $number\n";
                $search = $name;
                ($columns[$nmbr_col], $columns[$nmbr_note_col]) = (normalizeNumber($number));
                ($columns[$name_col], $columns[$name_note_col]) = (checkNameLength($name));
                $columns[$type_col] = $aliasType;
            } else {
                # alias NMBR "___" = "___"
                $aliasType = "NMBRONLY";
                ($from, $to) = /NMBR\s+"?([^"]*)"?\s+=\s+"?([^"]*)"?/;
                $search = $to;
                $line = "Change number from: $from To: $to\n";
                ($columns[$nmbr_col], $columns[$nmbr_note_col]) = (normalizeNumber($from));
                $columns[$type_col] = $aliasType . "-FROM";
                ($columns[$nmbr_col2], $columns[$nmbr_note_col2]) = (normalizeNumber($to));
                $columns[$type_col2] = $aliasType . "-TO";
                
            }
        } elsif (/alias LINE/) {
            # alias LINE "___" = "___"
            $aliasType = "LINEONLY";
            ($from, $to) = /LINE\s+"?([^"]*)"?\s+=\s+"?([^"]*)"?/;
            $line = "Change line from: $from To: $to\n";
            $search = $to;
            $columns[$name_col] = $from;
            $columns[$type_col] = $aliasType . "-FROM";
            $columns[$name_col2] = $to;
            $columns[$type_col2] = $aliasType . "-TO";
        } else {
            # alias "___" = "___"
            $aliasType = "NMBRNAME";
            ($from, $to) = /\s+"?([^"]*)"?\s+=\s+"?([^"]*)"?/;
            $line = "Change: $from To: $to\n";
            $search = $to;
            # currently assumes NAME to NAME; may need to check for digits
            # later in order to generate a proper NMBR to NMBR
            $columns[$name_col] = $from;
            $columns[$type_col] = $aliasType . "-FROM";
            ($columns[$name_col2], $columns[$name_note_col2]) = (checkNameLength($to));
            $columns[$type_col2] = $aliasType . "-TO";
        }
        
        if ($outputFormat == $delimited) { &doDelimited; }
        elsif (defined $search) {
            if (!defined $ret && ($listed{$search}{"bl"} || $listed{$search}{"wl"})) {
             print "\n"
            }
            undef $ret;
            print "Alias:     $line";
            if ($listed{$search}{"bl"}) {
                $listname = "Blacklist:";
                if ($listed{$search}{"bn"}) {
                    $label = "MatchName:";
                    $newname = $listed{$search}{"bn"};
                }
                else { $label = $newname = ""; }
                write;
            }
            if ($listed{$search}{"wl"}) {
                $listname = "Whitelist:";
                if ($listed{$search}{"wn"}) {
                    $label = "MatchName:";
                    $newname = $listed{$search}{"wn"};
                }
                else { $label = $newname = ""; }
                write;
            }
            if ($listed{$search}{"bl"} || $listed{$search}{"wl"}) {
                print "\n";
                $ret = 1;
            }
        }
    }
}

sub doList {

    if (open (LISTFILE, $listfile)) {
        $lineCount = 0;
        while (<LISTFILE>) {
        $lineCount ++;
        next if (/^\s*#/ || /^\s*$/);
            chomp;
            ($listname) = /#=\s*(.*)/;
            s /\s+#.*$//;
            if (/^^?[^'"]/) {
                @multiples = split /\s+/, $_;
                foreach my $item (@multiples) {
                    $listed{$item}{$blwl} = 1;
                    &initColumns; $columns[$file_col]=$listfile; $columns[$line_col]=$lineCount;
                    ($columns[$nmbr_col], $columns[$nmbr_note_col]) = (normalizeNumber($item));
                    if (defined $listname) {
                        if ($bflag) { $listed{$item}{"bn"} = $listname; }
                        else { $listed{$item}{"wn"} = $listname; }
                        ($columns[$name_col], $columns[$name_note_col]) = (checkNameLength($listname));
                    }
                    if ($outputFormat == $delimited) { &doDelimited; }
                }
            } else {
                $_ = substr $_, 1, -1;
                $listed{$_}{$blwl} = 1;
                &initColumns; $columns[$file_col]=$listfile; $columns[$line_col]=$lineCount;
                ($columns[$nmbr_col], $columns[$nmbr_note_col]) = (normalizeNumber($_));
                if (defined $listname) {
                    if ($bflag) { $listed{$_}{"bn"} = $listname; }
                    else { $listed{$_}{"wn"} = $listname; }
                    $columns[$name_col] = $listname;
                    ($columns[$name_col], $columns[$name_note_col]) = (checkNameLength($listname));
                }
                if ($outputFormat == $delimited) { &doDelimited; }
            }
        }
    }
    else { print "Could not open $listfile\n"; }
    close(LISTFILE);
}

sub doDelimited {

   if ($delimiter eq ",") {
      # put quotes around columns containing the delimiter
      # Acme Manufacturing, Inc. => "Acme Manufacturing, Inc."
      foreach my $i (0 .. $#columns) {
          if (index($columns[$i],$delimiter) > -1 ) { $columns[$i] = "\"" . $columns[$i] . "\""; }
      }
    }

    print $columns[$file_col], $delimiter, 
          $columns[$line_col], $delimiter,
          $columns[$nmbr_col], $delimiter, 
          $columns[$name_col], $delimiter, 
          $columns[$type_col], $delimiter, 
          $columns[$nmbr_note_col], $delimiter,
          $columns[$name_note_col],
          "\n";
        
    if ($columns[$type_col2]) {
       # When have NAMEONLY, NMBRONLY, LINEONLY, NMBRNAME, we write
       # two lines out so that we'll still only have text in the "Name"
       # column and numbers in the "Number" column
       print $columns[$file_col], $delimiter, 
             $columns[$line_col], $delimiter,
             $columns[$nmbr_col2], $delimiter, 
             $columns[$name_col2], $delimiter, 
             $columns[$type_col2], $delimiter, 
             $columns[$nmbr_note_col2], $delimiter,
             $columns[$name_note_col2],
             "\n";
    }         
}                 
    
sub initColumns {
    @columns=();
    $columns[$file_col]="";
    $columns[$line_col]="";
    $columns[$nmbr_col]="";
    $columns[$name_col]="";
    $columns[$type_col]="";    
    $columns[$nmbr_note_col]="";    
    $columns[$name_note_col]="";    
    $columns[$nmbr_col2]="";
    $columns[$name_col2]="";
    $columns[$type_col2]="";   
    $columns[$nmbr_note_col2]="";   
    $columns[$name_note_col2]="";        
}    
    
sub normalizeNumber {
    my $n = shift;
    my $orig_n = $n;
    my $note = "";
    if (substr($n,0,1) eq "*") { $n=substr($n,1); }
    if (substr($n,-1) eq "*") { $n=substr($n,0,length($n)-1);}
    if ( (substr($n,0,1) eq "1" ) && (length($n) == 11) && $stripOne ) {
       $n = substr($n,1);
    }
    if ($n ne $orig_n) { $note = "Original number: $orig_n"; }
    return ($n, $note);
}    

sub checkNameLength {
    my $s = shift;
    my $orig_s = $s;
    my $note = "";
    if (length($s)>50) {
       $s = substr($s, 0, 49);
       $note = "Name truncated to 50 characters, original name: $orig_s";
    }
    return ($s, $note);
}    
    
=head1 NAME

cidalias - view alias definitions in the NCID alias, blacklist, and whitelist files

=head1 SYNOPSIS

 cidalias [--help|-h] [--man|-m] [--version|-V]

 cidalias [--alias     |-a <file>] 
          [--blacklist |-b <file>] 
          [--whitelist |-w <file>] 
          [--format    |-f <0-2>]
          [--delimiter |-d <text>]
          [--strip-one |-1]

=head1 DESCRIPTION

The cidalias tool displays aliases in the alias file in one of
three different formats: raw, human readable, and delimited.  

=head2 Options

=over 7

=item -h, --help

Displays the help message and exits.

=item -m, --man

Displays the manual page and exits.

=item -V, --version

Displays the version and exits.

=item -f <0-2>, --format <0-2>

Determines the output format used.

Output format 0 displays the alias file as-is. The blacklist
and whitelist files are ignored.

Output format 1 displays the aliases in human readable text
and includes blacklist and whitelist info if applicable.

Output format 2 displays the alias, blacklist, and whitelist files
with field delimiters for easy parsing by another program. 
Uses options -d|--delimiter and -1|--strip-one.

The default output format is 1 (human readable).

=item -d <text>, --delimiter <text>

Used when output format is 2 (delimited). Fields will be delimited by 
<text>.

For pipe-delimited output, surround the pipe symbol with single or double
quotes: '|' or "|".

For tab-delimited output, specify only the letter "t".

For comma-delimited output, fields containing an embedded comma will 
automatically be surrounded by double-quotes.

Default delimiter is a comma (",").

=item -1, --strip-one

Used when output format is 2 (delimited). If a number is exactly
11 digits and it begins with "1", strip the "1" before outputting
it. This is to facilitate consistent sorting of the output for
10 digit numbers.

=item -a <file>, --alias <file>

Sets the name of the alias file.

Default: /etc/ncid/ncidd.alias

=item -b <file>, --blacklist <file>

Sets the name of the blacklist file.

Default: /etc/ncid/ncidd.blacklist

=item -w <file>, --whitelist <file>

Sets the name of the whitelist file

Default: /etc/ncid/ncidd.whitelist

=back

=head1 EXAMPLES

=over 2

=item Output as tab-delimited, changing 11-digit numbers beginning with "1" to be 10-digits:

cidalias -f 2 -d t -1

=item Output as pipe-delimited, changing 11-digit numbers beginning with "1" to be 10-digits, then sorting numerically on the phone number column:

cidalias -f 2 -d '|' -1 | sort -t '|' -k3,3 -n

=back

=head1 SEE ALSO

ncidd.conf.5,
ncidd.alias.5,
ncidd.blacklist.5,
ncidd.whitelist.5,
cidcall.1,
cidupdate.1

=cut
