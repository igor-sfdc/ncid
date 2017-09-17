#!/usr/bin/perl -w

# cidcall - caller ID report

# Created by John L. Chmielewski on Fri Sep 14, 2001
#
# Copyright (c) 2001-2016 by
#   John L. Chmielewski <jlc@users.sourceforge.net>
#   Todd Andrews <tandrews@users.sourceforge.net>
#   Aron Green

use strict;
use warnings;
use Pod::Usage;
use File::Basename;
use Getopt::Long qw(:config no_ignore_case_always);
use File::Glob ':bsd_glob';

my ($help, $man, $version);
my ($blk, $cid, $end, $hup, $msg, $not, $out, $pid, $wid, $allTypes);
my ($label, $date, $lineid, $name, $number);
my ($stime, $etime, $mtype, $mesg, $exception, $extra, $iflag);
my $cidlog;
my ($stripOne, @columns);
my ($lineCount_col, $label_col, $name_col, $nmbr_col, $lineid_col,  $date_col, $stime_col, $etime_col, $exception_col, $mesgType_col, $mesg_col) = (0..10);
my $lineCount;
my ($humanReadable, $delimited) = (1, 2);
my $outputFormat = $humanReadable;
my $delimiter = ",";
my $cl_lineid;
my $yearlog = 0;

my $prog = basename($0);
my $VERSION = "(NCID) XxXxX";

format STDOUT =
@<<< @<<<<<<<<<<<<<<<<<<<< @<<<<<<<<<<<< @<<<<<<<<<< @<<<<<<<<<< @<<<<<<< @<<<<<<<
$label, $name,             $number,      $lineid,    $date,      $stime,  $extra
.

select(STDERR); $| = 1; # enable autoflush, otherwise output to STDERR
select(STDOUT); $| = 1; # may appear before output to STDOUT

Getopt::Long::Configure ("bundling");
my ($result) = GetOptions(
    "help|h"        => \$help,
    "man|m"         => \$man,
    'version|V'     => \$version,
    "format|f=i"    => \$outputFormat,
    "lineid|i=s"    => \$cl_lineid,    
    "delimiter|d=s" => \$delimiter,
    "strip-one|1"   => \$stripOne,
    "all-types|a"   => \$allTypes,
    "yearlog|y=i"   => \$yearlog,
    "BLK|B"         => \$blk,
    "CID|C"         => \$cid,
    "END|E"         => \$end,
    "HUP|H"         => \$hup,
    "MSG|M"         => \$msg,
    "NOT|N"         => \$not,
    "OUT|O"         => \$out,
    "PID|P"         => \$pid,
    "WID|W"         => \$wid
 ) || pod2usage(2);
die "$prog $VERSION\n" if $version;
pod2usage(-verbose => 1, -exitval => 0) if $help;
pod2usage(-verbose => 2, -exitval => 0) if $man;

($cidlog = shift) || ($cidlog = "/var/log/cidcall.log");

$cidlog = glob("~/NCID/log/cidcall-$yearlog.log") if $yearlog;

if ( ($outputFormat < 0) || ($outputFormat > 2) ) { die "Format option must be in the range of 0-2.";}

$delimiter = pack ('H2', '09') if $delimiter eq "t";

if ($outputFormat == $delimited) { 
   #create column headings
   &initColumns;
   $columns[$lineCount_col]= "Line Count";
   $columns[$label_col]    = "Call Type";
   $columns[$name_col]     = "Name";
   $columns[$nmbr_col]     = "Number";
   $columns[$lineid_col]   = "Line ID";
   $columns[$date_col]     = "Date";
   $columns[$stime_col]    = "Start";
   $columns[$etime_col]    = "End";
   $columns[$exception_col]= "Exception";
   $columns[$mesgType_col] = "Message Type";
   $columns[$mesg_col]     = "Message";
   &doDelimited;
}   

open(CIDLOG, $cidlog) || die "Could not open $cidlog\n";

$lineCount = 0;

if ($allTypes) {$blk = $cid = $end = $hup = $msg = $not = $out = $pid = $wid = 1;}

while (<CIDLOG>) {
  if (!$outputFormat) { print; next;}
  $lineCount ++;
  if (!$blk && !$cid && !$end && !$hup && !$msg && !$not && !$out && !$pid && !$wid) {
    if (/BLK:|CID:|HUP:|OUT:|PID:|WID:/) {&parseLine;}
  }
  else {
    if ($blk) { if (/BLK:/) {&parseLine;} }  
    if ($cid) { if (/CID:/) {&parseLine;} }
    if ($end) { if (/END:/) {&parseLine;} }
    if ($hup) { if (/HUP:/) {&parseLine;} }
    if ($msg) { if (/MSG:/) {&parseLine;} }
    if ($not) { if (/NOT:/) {&parseLine;} }
    if ($out) { if (/OUT:/) {&parseLine;} }
    if ($pid) { if (/PID:/) {&parseLine;} }
    if ($wid) { if (/WID:/) {&parseLine;} }
  }
}

sub parseLine {
    if (/MSG:|NOT:/) {
      $etime = "";
      if (($iflag =  /\s+\*\*\*DATE/) != 1) {
        chop;
        $date = $stime = $number = $name = $mtype = "";
        ($label, $mesg) = /(\w+:)\s+(.*)$/;
      } else {
      ($mtype) = /.*\*MTYPE.([^*]+).*\*/;
      $extra = $mtype;
      ($label, $mesg, $date, $stime, $name, $number) = 
       /(\w+:)\s+(.*)\s+\*\*\*DATE.(\d+).*\*TIME.(\d+).*\*NAME.([^*]+).*\*NMBR.([^*]+).*\*/;
      }
    } else {
      $iflag = 1;
      $mesg = $extra = $mtype = $etime = "";
      ($label, $date, $stime, $number, $name) = 
       /(\w+:).*\*DATE.(\d+).*\*TIME.(\d+).*\*NU*MBE*R\*([^*]+).*\*NAME.([^*]+).*\*+$/;
      if (/END:/) {
        ($stime, $etime) =
         /.*SCALL.\d+\/\d+\/\d+ (\d\d:\d\d:\d\d).*ECALL.\d+\/\d+\/\d+ (\d\d:\d\d:\d\d).*$/;
        $extra = $etime;
      }
    }
    if ($iflag) {
        ($lineid) = /.*\*LINE.([^*]+).*\*/;
        $date =~ s/(\d\d)(\d\d)(\d\d\d\d)*/$1\/$2\/$3/;
        $date =~ s/\/$//;
        $stime =~ s/(\d\d)(\d\d)/$1:$2/;
        #$number =~ s/\d?(\d\d\d)(\d\d\d)(\d\d\d\d)/$1-$2-$3/;
    }

    if ($cl_lineid) {
       if ($cl_lineid ne $lineid) {return;}
    }

    $exception="";
    
    if ($outputFormat == $delimited) { 
       &initColumns; 
       $columns[$lineCount_col]= $lineCount;
       $columns[$label_col]    = $label;
       $columns[$name_col]     = $name;
       ($columns[$nmbr_col], $columns[$exception_col]) = (normalizeNumber($number));
       $columns[$lineid_col]   = $lineid;
       $columns[$date_col]     = $date;
       $columns[$stime_col]    = $stime;
       $columns[$etime_col]    = $etime;
       $columns[$mesgType_col] = $mtype;
       $columns[$mesg_col]     = $mesg;
       &doDelimited; 

    } else {
      write if $iflag;
      if ($mesg && $outputFormat == 1) {
        print "$label " if !$iflag;
        print "$mesg\n";
      }
    }
}

sub doDelimited {

   if ($delimiter eq ",") {
      # put quotes around columns containing the delimiter
      # Acme Manufacturing, Inc. => "Acme Manufacturing, Inc."
      foreach my $i (0 .. $#columns) {
          if (index($columns[$i],$delimiter) > -1 ) { $columns[$i] = "\"" . $columns[$i] . "\""; }
      }
    }

    print $columns[$lineCount_col], $delimiter,
          $columns[$label_col]    , $delimiter,
          $columns[$name_col]     , $delimiter,
          $columns[$nmbr_col]     , $delimiter,
          $columns[$lineid_col]   , $delimiter,
          $columns[$date_col]     , $delimiter,
          $columns[$stime_col]    , $delimiter,
          $columns[$etime_col]    , $delimiter,
          $columns[$exception_col], $delimiter,
          $columns[$mesgType_col] , $delimiter,
          $columns[$mesg_col]     , 
          "\n";
        
}                 
    
sub initColumns {
    @columns=();
    $columns[$lineCount_col]="";
    $columns[$label_col]    ="";
    $columns[$name_col]     ="";
    $columns[$nmbr_col]     ="";
    $columns[$lineid_col]   ="";
    $columns[$date_col]     ="";
    $columns[$stime_col]    ="";
    $columns[$etime_col]    ="";
    $columns[$exception_col]="";
    $columns[$mesgType_col] ="";
    $columns[$mesg_col]     ="";
}    

sub normalizeNumber {
    my $n = shift;
    my $orig_n = $n;
    my $exception = "";
    if (substr($n,0,1) eq "*") { $n=substr($n,1); }
    if (substr($n,-1) eq "*") { $n=substr($n,0,length($n)-1);}
    if ( (substr($n,0,1) eq "1" ) && (length($n) == 11) && $stripOne ) {
       $n = substr($n,1);
    }
    if ($n ne $orig_n) { $exception = "Original number: $orig_n"; }
    return ($n, $exception);
}    

=head1 NAME

cidcall - view calls, hangups, messages, and end of calls in the NCID call file

=head1 SYNOPSIS

 cidcall [--help|-h] [--man|-m] [--version|-V]

 cidcall [--format   |-f <0-2>]
         [--delimiter|-d <text>]
         [--strip-one|-1]
         [--all-types|-a]
         [--yearlog  |-y <4 digit year>]
         [--BLK      |-B]
         [--CID      |-C]
         [--END      |-E]
         [--HUP      |-H]
         [--MSG      |-M]
         [--NOT      |-N]
         [--OUT      |-O]
         [--PID      |-P]
         [--WID      |-W]
         [cidlog]

=head1 DESCRIPTION

The cidcall tool displays the cidcall.log file in one of
three different formats: raw, human readable, and delimited.  

The default is to display BLK, CID, HUP, OUT, PID, and WID lines in
a human readable format.

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

Output format 0 displays the call log file as-is. All other options are ignored.

Output format 1 displays the call log in human readable text.

Output format 2 displays the call log with field delimiters for easy 
parsing by another program. 
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

If the leading "1" is stripped, the "Exception" column will so indicate.

=item -i, --lineid <text>

Output only those lines where the lineid matches <text>. 

=item -a, --all-types

Equivalent to typing --BLK, --CID, --END, --HUP, --MSG, --NOT, 
--OUT, --PID, and --WID on the command line.

=item -B, --BLK

Displays BLK lines (blocked calls) in the call file.

=item -C, --CID

Displays CID lines (incoming calls) in the call file.

=item -E, --END

Displays END lines (gateway end of call) in the call file.

=item -H, --HUP

Displays HUP lines (terminated calls) in the call file.

=item -M, --MSG

Displays MSG lines (messages) in the call file.

=item -N, --NOT

Displays NOT lines (smartphone note (message)) in the call file.

=item -O, --OUT

Displays OUT lines (outgoing calls) in the call file.

=item -P, --PID

Displays PID lines (smartphone Caller ID) in the call file.  Obsolete.

=item -W, --WID

Displays WID lines ("call waiting" calls) in the call file.

=item -y, --yearlog <4 digit year>

Obtains data from $HOME/NCID/log/cidcall-<year>.log instead of the
default.  This overrides a call log given on the command line.

=back

=head2 Arguments

=over 7

=item cidlog

The NCID call file.

Default: /var/log/cidcall.log

=back

=head1 EXAMPLES

=over 2

=item Output as tab-delimited, changing 11-digit numbers beginning with "1" to be 10-digits:

cidcall -f 2 -d t -1

=item Output as pipe-delimited, changing 11-digit numbers beginning with "1" to be 10-digits, then sorting numerically on the phone number column:

cidcall -f 2 -d '|' -1 | sort -t '|' -k4,4 -n

=back

=head1 FILES

 /var/log/cidcall.log
 $HOME/NCID/log/cidcall-<year>.log

=head1 SEE ALSO

ncidd.conf.5

=cut
