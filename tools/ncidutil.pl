#!/usr/bin/perl

# ncidutil - Perform various operations on the alias, black list
#            and white list files.  Designed to be called by the
#            server in response to client requests.
#
# Created by Steve Limkemann on Sat Mar 23, 2013
#
# Copyright (c) 2013-2015 by
#   Steve Limkemann
#   John L. Chmielewski <jlc@users.sourceforge.net>

use strict;
use warnings;
use Pod::Usage;
use File::Basename;
use Getopt::Long qw(:config no_ignore_case_always);

my ($filename, $filename1, $list, $action, $item, @tag, $tagged, $where);
my ($found, $finished, $sep, $alias, $comment, $extra, $type, $name);
my ($multiple, $blacklist, $whitelist, $filein, $fileout, $nmbr, $regex);
my ($aliasType, $listType, $search, $replace, $entry, $ignore1, $save_line);

my $prog = basename($0);
my $VERSION = "(NCID) XxXxX";

my @listTypes = ('Alias', 'Blacklist', 'Whitelist', 'UNKNOWN');
my @aliasNo= ('NOALIAS');
my @aliasTypes = ('NOALIAS', 'NAMEDEP', 'NMBRDEP', 'NMBRNAME', 'NMBRONLY', 'NAMEONLY', 'LINEONLY', 'UNKNOWN');

@tag = ('', '##############', '# Auto Added #', '##############', '');

my ($help, $man, $version);

select(STDERR); $| = 1; # enable autoflush, otherwise output to STDERR
select(STDOUT); $| = 1; # may appear before output to STDOUT

Getopt::Long::Configure ("bundling");
my ($result) = GetOptions(
    'help|h'        => \$help,
    'man|m'         => \$man,
    'ignore1|i'     => \$ignore1,
    'multi=s'       => \$multiple,
    'regex|R'       => \$regex,
    'version|V'     => \$version
 ) || pod2usage(2);
die "$prog $VERSION\n" if $version;
pod2usage(-verbose => 2, -exitval => 0) if $man;
pod2usage(-verbose => 1, -exitval => 0) if $help || scalar @ARGV < 4;

($filename, $list, $action, $item, $extra) = @ARGV;

foreach $listType (@listTypes) {
    die "Unknown list type: \"$list\"" if $listType eq 'UNKNOWN';
    last if $listType eq $list;
}

if ($list eq 'Alias') {
    ($nmbr) = $item =~ /(.*)&&/;
    ($alias) = $item =~ /&&(.*)/;
    ($type, $name) = $extra =~ /(.*)&&(.*)/;

    $nmbr = '' if not defined $nmbr;
    $alias = '' if not defined $alias;
    $type = '' if not defined $type;
    $name = '' if not defined $name;

    $nmbr =~ s/-//g if $nmbr =~ /^[0-9\-]+$/;

    # check for valid alias type
    foreach $aliasType (@aliasTypes) {
        die "Unknown alias type: \"$type\"" if $aliasType eq 'UNKNOWN';
        last if $aliasType eq $type;
    }
    ($aliasType) = $type =~ /(\w\w\w\w)\w+/;

    # check for unsupported alias type
    foreach $aliasType (@aliasNo) {
        die "Unsupported alias type: \"$type\"" if $aliasType eq $type;
    }

    if ($type eq 'NAMEDEP' || $type eq 'NMBRONLY') {
       $item = $nmbr;
    } else { $item = $name; }

    $action = 'remove' if $action eq 'modify' and $alias eq '';
} else {
    $item =~ s/-//g if $item =~ /^[0-9\-]+$/;
    die "\"$action\" not allowed for $list\n" if $action eq "modify";
}

$filename1 = "${filename}.update";
open INPUT, '<', "$filename" or die "Unable to open $filename\n$!\n";
open OUTPUT, '>', "$filename1" or die "Unable to open $filename1\n$!\n";

if (defined $multiple and ($action eq 'modify' or $action eq 'remove')) {
    ($blacklist, $whitelist) = $multiple =~ /(.*)\s(.*)/;

    if ($name) { $entry = $alias; } else { $entry = $item; }
    foreach $filein ($blacklist, $whitelist) {
        $fileout = "${filein}.update";
        open FILEIN, '<', "$filein" or die "Unable to open $filein\n$!\n";
        open FILEOUT, '>', "$fileout" or die "Unable to open $fileout\n$!\n";

        while (<FILEIN>) {
            # skip blank and comment lines
            if (/^\s*#|^\s*$/) {
                print FILEOUT $_;
                next;
            }
            $search = getfield();
            if (&strmatch($entry, $search)) {
                if ($action eq "modify") {
                $save_line = $_;
                s/$search/$alias/;
                print FILEOUT $_;
                print "Modified: $filein\n";
                $save_line =~ s/\s+/ /g;
                print "    from: $save_line\n";
                s/\s+/ /g;
                print "      to: $_\n";
                }
            } else {print FILEOUT $_}
        }
        close FILEIN;
        close FILEOUT;
    }
}

$tagged = $found = $finished = 0;
while (<INPUT>) {
    if ($finished) {
        print OUTPUT $_;
        next;
    }
    chomp;
    if ($tagged <= $#tag and $_ eq $tag[$tagged]) {
        $tagged++;
    } elsif ($tagged <= $#tag) {
        $tagged = 0;
        $tagged++ if $_ eq $tag[0];
    }
    if (/^\s*#|^\s*$/) {
        # skip blank and comment lines
        print OUTPUT "$_\n";
        next;
    }
    $search = getfield();
    if (&strmatch($item, $search)) { $found = 1; }
    if ($found == 1) {
        if ($action eq 'add') {
            close INPUT;
            close OUTPUT;
            unlink "$filename1";
            die "$list entry is already present.\n";
        }
        if ($action eq 'modify') {
            $save_line = $_;
            ($comment) = /(\s*#.*)$/;
            $comment = "" if !defined $comment;
            if ($type =~ /DEP$/) {
                $_ = "alias $aliasType * = \"$alias\" if \"$item\"$comment";
            }
            elsif ($type eq 'NMBRNAME') {
                $_ = "alias \"$item\" = \"$alias\"$comment";
            }
            else {
                $_ = "alias $aliasType \"$item\" = \"$alias\"$comment";
            }
            print OUTPUT "$_\n";
            print "Modified: $filename\n";
            $save_line =~ s/\s+/ /g;
            print "    from: $save_line\n";
            $save_line = $_;
            s/\s+/ /g;
            print "      to: $_\n";
            $finished = 1;
            next;
        }
        if ($action eq 'remove') {
            print "Modified: $filename\n";
            $save_line = $_;
            s/\s/ /g;
            print " removed: $_\n";
            $finished = 1;
            next;
        }
    }
    print OUTPUT "$_\n";
}
close INPUT;

if ($finished) {
    close INPUT;
    close OUTPUT;
    rename "$filename1", "$filename";
    if (defined $multiple) {
        rename "${blacklist}.update", "$blacklist";
        rename "${whitelist}.update", "$whitelist";
    }
    die "Done.\n" 
}

if ($action eq 'add') {
    if ($tagged <= $#tag) {
        foreach (@tag) {
            print OUTPUT "$_\n";
        }
    }
    if ($list eq 'Alias') {
        $item = "alias NAME * = \"$alias\" if \"$nmbr\"" if $type eq "NAMEDEP";
        $item = "alias NMBR * = \"$alias\" if \"$name\"" if $type eq "NMBRDEP";
        $item = "alias NAME \"$name\" = \"$alias\"" if $type eq "NAMEONLY";
        $item = "alias NMBR \"$nmbr\" = \"$alias\"" if $type eq "NMBRONLY";
        $item = "alias \"$name\" = \"$alias\"" if $type eq "NMBRNAME";
        $item = "alias LINE \"$name\" = \"$alias\"" if $type eq "LINEONLY";
    } else {
        $item = "\"$item\"";
        if ($extra) {
            if ($extra =~ /^\s*=(.*)\s*$/) {
                ($extra) = ($1);
                $item = "$item \t#=$extra"
            }
            else { $item = "$item \t# $extra" if $extra; }
        }
    }
    print OUTPUT "$item\n";
    close OUTPUT;
    print "Modified: $filename\n";
    $item =~ s/\s+/ /g;
    print "   added: $item\n";
    rename "$filename1", "$filename";
    die "Done.\n" 
} else {
    close OUTPUT;
    unlink "$filename1";
    die "$list entry is not present.\n";
}

# This function is also used in cidupdate.pl.  If you modify
# it here, make the same modifications in cidupdate.pl.
sub strmatch {
    my($string, $find) = @_;

    # remove comment at the end of the line
    $string =~ s/\s+#.*$//;

    # remove '?' at beginning of line, some phone systems generate ?<name>
    $string =~ s/^\?//;
    $find =~ s/^\?//;

    if (defined $ignore1) {
        if ($find =~ /^1\?/) { $find =~ s/^1\?//; }
        else { $find =~ s/^1//; }
        $string =~ s/^1//;
    }
    if (!defined $regex) {
        if ($find =~ /^\^/) {
            # handle ^<string> ^1?<string> ^*<string> ^*<string>* ^<string>*
            $find =~ s/\^\*/\^.*/;
            if ($find =~ /\*$/) {$find =~ s/\*$//;}
            else {$find =~ s/$/\$/;}
        }else {
            # handle <string> 1?<string> *<string> *<string>* <string>*
            if ($find =~ /^\*/) {$find =~ s/\*//;}
            else {$find =~ s/^/\^/;}
            if ($find =~ /\*$/) {$find =~ s/\*$//;}
            else {$find =~ s/$/\$/;}
        }
        # escape regex characters not used
        $find =~ s/([+.()|{}\[\]-])/\\$1/g;
    }

    return ($string =~ /$find/);
}
sub getfield {
    my $line = $_;
    my ($ftype, $ffrom, $fto, $fsearch);

    chomp $line;
    $line =~ s/\s+#.*$|\s*$//;
    if ($line =~ /^alias/) {
      if ($line =~ /^alias\s+(\w+)\s+"?([^"]+)"?\s+=\s+"?([^"]+)"?\s+if\s+"?([^"]+)"?\s*/) {
        # alias NAME|NMBR "from" = "to" if "depend"
        ($ftype, $ffrom, $fto, $fsearch) = ($1, $2, $3, $4);
      } elsif ($line =~ /^alias\s+(\w+)\s+"?([^"]+)"?\s+=\s+"?([^"]+)"?\s*/) {
        # alias [NAME|NMBR] "from" = "to"
        ($ftype, $fsearch, $fto) = ($1, $2, $3);
      } elsif ($line =~ /^alias\s+"?([^"]+)"?\s+=\s+"?([^"]+)"?\s*/) {
        # alias "from" = "to"
        ($ftype, $fsearch, $fto) = ("", $1, $2);
      }
    } else {
      ($fsearch) = $line =~ /"?([^"]+)"?/;
    }
    $search = "" if !defined $search;
    return $fsearch;
}

=head1 NAME

ncidutil - manipulate entries in the alias, blacklist, and whitelist files

=head1 SYNOPSIS

 ncidutil [--help|-h] [--man|-m] [--version|-V]

 ncidutil [--multi "<blacklist and/or whitelist file names>"]
          [--regex|-R] [--ignore1|-i] <arguments>

=head1 DESCRIPTION

The ncidutil script is designed to be called by the NCID server in
response to client requests.  Five arguments are required.

The ncidutil script can add, modify or remove an alias from the
alias file.  If an alias is modified or removed and if the hangup
option of the server is enabled, ncidutil will add or remove the
alias entry in the blacklist and/or whitelist files.

The "--multi" option is used to determine if the blacklist and
whitelist files should be searched for an alias or if an entry
should be added or removed from the files.  The entry can be
an alias in the alias file.

=head2 Options

=over 11

=item -h, --help

Displays the help message and exits.

=item -m, --man

Displays the manual page and exits.

=item -V, --version

Displays the version and exits.

=item -i, --ignore1

This is a US/Canada option only.

A leading one in an alias definition and in the calling number is ignored.

Normally an alias requires the calling number as it appears in the cidcall.log.
In the US a leading 1 may or may not be provided in incoming or outgoing calls.

Default: The number for the alias entry must match the calling number.

=item --multi "<blacklist> <whitelist>"

Specifies the names of the blacklist and whitelist files to update when
an alias is modified. If both are specified, separate each with a space.

Default: ""

=item -R, --regex

Regular expressions are used instead of simple expressions.


=back

=head2 Arguments

=over 11

=item <filename>

Name of the alias, blacklist, or whitelist file.

=item <list>

The case-sensitive type of list: Alias, Blacklist, Whitelist

=item <action>

add, modify, remove

 for list = Alias:     add, remove, or modify
 for list = Blacklist: add or remove
 for list = Whitelist: add or remove

=item <item>

 For list = Alias,     item = "number&&alias".
 For list = Blacklist, item = "number|name&&".
 For list = Whitelist, item = "number|name&&".

Quotes are required.

 number is the number in the call file
 alias is from the user
 name is the name in the call file

=item <extra>

 For list = Alias,     extra is "type&&name".
 For list = Blacklist, extra is a optional "comment".
 For list = Whitelist, extra is a optional "comment".

Quotes are required.

 name is the name in the call file
 type is the uppercase alias type or NOALIAS:
    NAMEDEP, NMBRDEP, NMBRNAME, NMBRONLY, NAMEONLY, LINEONLY

=back

=head1 SEE ALSO

ncidd.conf.5,
ncidd.alias.5,
ncidd.blacklist.5,
ncidd.whitelist.5,
cidalias.1,
cidcall.1,
cidupdate.1

=cut
