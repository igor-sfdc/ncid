#!/usr/bin/perl

# cidupdate - update Caller ID call log file or files using the
# current alias file.
#
# Created by Aron Green on Mon Nov 25, 2002
#
# Copyright (c) 2002-2016 by
#   Aron Green,
#   John L. Chmielewski <jlc@users.sourceforge.net> and
#   Steve Limkemann
#   Chris Lenderman

use strict;
use warnings;
use Pod::Usage;
use File::Basename;
use Getopt::Long qw(:config no_ignore_case_always);

my (@aliases, $alias, $cidlog, $newcidlog, $changed);
my ($help, $man, $version, $multiple, $ignore1, $regex);
my ($type, $from, $to, $depend, $mod_time, $logType);
my ($date, $time, $line, $number, $mesg, $name, @log_files);
my ($htype, $scall, $ecall, $ctype, $mtype, $message, $info);

my $prog = basename($0);
my $VERSION = "(NCID) XxXxX";

my $ALIAS = "/etc/ncid/ncidd.alias";
my $CIDLOG = "/var/log/cidcall.log";

select(STDERR); $| = 1; # enable autoflush, otherwise output to STDERR
select(STDOUT); $| = 1; # may appear before output to STDOUT

Getopt::Long::Configure ("bundling");
my ($result) = GetOptions(
    'help|h'        => \$help,
    'man|m'         => \$man,
    'version|V'     => \$version,
    'aliasfile|a=s' => \$alias,
    'cidlog|c=s'    => \$cidlog,
    'ignore1|r'     => \$ignore1,
    'multi'         => \$multiple,
    'regex|R'       => \$regex
 ) || pod2usage(2);
die "$prog $VERSION\n" if $version;
pod2usage(-verbose => 1, -exitval => 0) if $help;
pod2usage(-verbose => 2, -exitval => 0) if $man;

$alias = $ALIAS if !defined $alias;
$cidlog = $CIDLOG if !defined $cidlog;

@log_files = glob "$cidlog*";
die "Terminated: missing file: $cidlog\n" if $#log_files == -1;

$#log_files = 0 unless $multiple;

$SIG{'HUP'}  = 'sigHandle';
$SIG{'INT'}  = 'sigHandle';
$SIG{'QUIT'} = 'sigHandle';
$SIG{'TERM'} = 'sigHandle';
$SIG{'PIPE'} = 'sigHandle';

open(ALIASFILE, $alias) || errorExit("Could not open $alias: $!\n");

while (<ALIASFILE>) {
    next unless /^alias/;
    chomp;
    s/\s+#.+$//;
    if (/^alias\s+(\w+)\s+"?([^"]+)"?\s+=\s+"?([^"]+)"?\s+if\s+"?([^"]+)"?$/) {
        # alias NAME|NMBR "from" = "to" if "depend"
        ($type, $from, $to, $depend) = ($1, $2, $3, $4);
    } elsif (/^alias\s+(\w+)\s+"?([^"]+)"?\s+=\s+"?([^"]+)"?$/) {
        # alias NAME|NMBR "from" = "to"
        ($type, $from, $to, $depend) = ($1, $2, $3, '');
    } elsif (/^alias\s+"?([^"]+)"?\s+=\s+"?([^"]+)"?$/) {
        # alias "from" = "to"
        ($type, $from, $to, $depend) = ('NMBRNAME', $1, $2, '');
    } else {
        print "Unknown: $_\n";
        next;
    }
    $to =~ s/\s*$//;
    $depend =~ s/\s*$//;
    push @aliases, ([$type, $from, $to, $depend]);
}

#CID: *DATE*11242002*TIME*2112*LINE*1*NMBR*9549142285*MESG*NONE*NAME*Cell*

foreach $cidlog (@log_files) {
    unlink $cidlog if $cidlog =~ /\.new\.new$/;
    next if $cidlog =~ /\.new$/;
    $newcidlog = "$cidlog.new";
    open(CIDLOG, $cidlog) || errorExit("Could not open $cidlog: $!\n");
    open(NEWCIDLOG, ">$newcidlog") || errorExit("Could not open $newcidlog: $!\n");

    while (<CIDLOG>) {
        if (/^BLK:|^CID:|^END:|^HUP:|^OUT:|^PID:|^WID:|^MSG:|^NOT:|^RLY:/) {
            ($logType, $date, $time, $line, $number, $mesg, $name) =
                (split /\*/) [0, 2, 4, 6, 8, 10, 12];
            if (/^END/) {
                ($logType, $htype, $date, $time, $scall, $ecall, $ctype, $line, $number, $name) =
                (split /\*/) [0, 2, 4, 6, 8, 10, 12, 14, 16, 18];
            }
            if (/^MSG|^NOT/) {
                # https://stackoverflow.com/questions/14127282/match-from-last-occurrence-using-regex-in-perl
                # allow 1 or more *'s in $message
                ($message, $info) = /(.*)(\*\*\*.*?$)/;

                # get the data fields from $info
                ($date, $time, $name, $number, $line, $mtype) = 
                (split /\*/, $info) [4, 6, 8, 10, 12, 14];

                ($logType) = $message =~ /(^\w+:\s)/;
                $message =~ s/^\w+:\s//;
            }

            if ($number eq 'RING') {
                print NEWCIDLOG;
                next;
            }
            foreach $alias (@aliases) {
                ($type, $from, $to, $depend) = @$alias;
                if ($type eq "NAME" && $depend) {
                    if (strmatch($number, $depend) && !strmatch($name, $to)) {
                        record_change ("(NAMEDEP) Changed \"$name\" to \"$to\" for $number", $cidlog);
                        $name = $to;
                    }
                }
                elsif ($type eq "NAME") {
                    if (strmatch($name, $from) && !strmatch($name, $to)) {
                        record_change ("(NAMEONLY) Changed \"$name\" to \"$to\"", $cidlog);
                        $name = $to;
                    }
                }
                if ($type eq "NMBR" && $depend) {
                    if (strmatch($name, $depend) && !strmatch($number, $to)) {
                        record_change ("(NMBRDEP) Changed \"$number\" to \"$to\" for $name", $cidlog);
                        $number = $to;
                    }
                }
                elsif ($type eq "NMBR") {
                    if (strmatch($number, $from) && !strmatch($number, $to)) {
                        record_change ("(NMBRONLY) Changed \"$number\" to \"$to\"", $cidlog);
                        $number = $to;
                    }
                }
                if ($type eq "LINE") {
                    if (strmatch($line, $from) && !strmatch($line, $to)) {
                        record_change ("(LINEONLY) Changed \"$line\" to \"$to\"", $cidlog);
                        $line = $to;
                    }
                }
                if ($type eq "NMBRNAME") {
                    if (strmatch($name, $from) && !strmatch($name, $to)) {
                        record_change ("(NMBRNAME:NAME) Changed \"$name\" to \"$to\"", $cidlog);
                        $name = $to;
                    }
                    if (strmatch($number, $from) && !strmatch($number, $to)) {
                        record_change ("(NMBRNAME:NMBR) Changed \"$number\" to \"$to\"", $cidlog);
                        $number = $to;
                    }
                }
            }
            if ($logType eq "END: ") {
                print NEWCIDLOG
                  "$logType*HTYPE*$htype*DATE*$date*TIME*$time*SCALL*$scall*ECALL*$ecall*CTYPE*$ctype*LINE*$line*NMBR*$number*NAME*$name*\n";
            } elsif ($logType eq "MSG: " || $logType eq "NOT: "){
                print NEWCIDLOG
                  "$logType$message***DATE*$date*TIME*$time*NAME*$name*NMBR*$number*LINE*$line*MTYPE*$mtype*\n";
            } else {
                print NEWCIDLOG
                  "$logType*DATE*$date*TIME*$time*LINE*$line*NMBR*$number*MESG*$mesg*NAME*$name*\n";
            }
        } else {
            print NEWCIDLOG;
        }
    }
    no_change ($cidlog);
    $mod_time = (stat CIDLOG)[9];
    close CIDLOG;
    close NEWCIDLOG;
    utime $mod_time, $mod_time, $newcidlog;
}
report_changes ();
if ($changed) {
    if ( -t STDIN) {
        print "\nreject or accept changes? (R/a): ";
        my $resp = <STDIN>;
        chomp $resp;
        $resp = 'r' unless $resp;
        if (substr ((lc $resp), 0, 1) eq 'r') {
            remove_new ();
            print "\nUpdates to CID call logs have been discarded\n\n";
        } else {
            use_new ();
            print "\nChanges have been made to the CID log files\n\n";
        }
    }
} else {remove_new ();}

{
    my (%files, @files, %changes, @changes);

    sub record_change {
        my ($key, $file) = @_;

        push @files, $file unless exists $files{$file};
        $files{$file} ++;
        push @changes, $key unless exists $changes{$key};
        $changes{$key}++;
    }

    sub report_changes {
        my ($temp1, $temp2);

        print "\n" if -t STDIN;
        foreach (@files) {
            ($temp1, $temp2) = $files{$_} == 1 ? ('was', ''): ('were', 's');
            if ($files{$_} == 0) {$files{$_} = 'no';}
            else {$changed = 1;}
            print "There $temp1 $files{$_} change$temp2 to $_\n";
        }
        print "\n";
        foreach (@changes) {
            $temp1 = $changes{$_} == 1 ? '': 's';
            print "$_ $changes{$_} time$temp1\n";
        }
    }

    sub no_change {
        my $file = shift;

        if (not exists $files{$file}) {
            push @files, $file;
            $files{$file} = 0;
        }
    }

    sub remove_new {

        foreach (@files) {
            unlink "$_.new"
        }
    }

    sub use_new {

        foreach (@files) {
            if (/\.log.+$/) {
                # not the current call log
                rename "$_.new", $_;
            } elsif (system ("killall -SIGUSR1 ncidd") != 0) {
                # update the current call log if signal to ncidd failed
                rename "$_.new", $_;
            }
        }
    }
}

# This function is also used in ncidutil.pl.  If you modify
# it here, make the same modifications in ncidutil.pl.
sub strmatch {
    my($string, $find) = @_;

    # remove comment at end of the line
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
            # handle  ^<string> ^1?<string> ^*<string> ^*<string>* ^<string>*
            $find =~ s/\^\*/^.*/;
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

sub cleanup {
    close CIDLOG;
    close NEWCIDLOG;
    remove_new ();
}

sub errorExit {
    cleanup ();
    die "Terminated: @_";
}

sub sigHandle {
    my $sig = shift;
    cleanup ();
    die "Terminated: Caught SIG$sig\n";
}

=head1 NAME

cidupdate -  update aliases in the NCID call file

=head1 SYNOPSIS

 cidupdate [--help|-h] [--man|-m] [--version|-V]

 cidupdate [--aliasfile|-a <aliasfile>]
           [--cidlog|-c <cidlog>]
           [--ignore1|-i]
           [--regex|-R]
           [--multi]

=head1 DESCRIPTION

The cidupdate script updates the current call log file
(cidcall.log) using the entires found in the alias file
(ncidd.alias).

If the "--multi" option is present, the current cidcall.log file
and previous call files are updated.

Call types updated are: BLK, CID, END, HUP, OUT, PID, WID 

Message types updated are: MSG, NOT

=head2 Options

=over 7

=item -h, --help

Displays the help message and exits.

=item -m, --man

Displays the manual page and exits.

=item -V, --version

Displays the version and exits.

=item -a <aliasfile>, --aliasfile <aliasfile>

Set the alias file to <aliasfile>

Default: /etc/ncid/ncidd.alias

=item -c <logfile>, --cidlog <logfile>

Set the call file to <logfile>

Default: /var/log/cidcall.log

=item -i, --ignore1

This is a US/Canada option only.

A leading one in an alias definition and in the calling number is ignored.

Normally an alias requires the calling number as it appears in the cidcall.log.
In the US a leading 1 may or may not be provided in incoming or outgoing calls.

Default: The leading 1 must be in the alias if it is in the calling number.

=item --multi

Updates the current cidcall.log file and all previous call files.

Default: Updates only the cidcall.log file

=item -R, --regex

Uses Regular Expressions instead of Simple Expressions.

Default: Uses Simple Expressions

=back

=head1 SEE ALSO

ncidd.conf.5,
ncidd.alias.5,
ncidd.blacklist.5,
cidalias.1,
cidcall.1

=cut
