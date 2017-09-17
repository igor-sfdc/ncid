#!/usr/bin/perl

# obi2ncid - Obihai to NCID gateway

# hacked from rn2ncid (Copyright (c) by John L Chmielewski and Todd Andrews)

# Copyright (c) 2015-2016
#  by John L. Chmielewski <jlc@users.sourceforge.net>
#  and Todd Andrews <tandrews@users.sourceforge.net>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

use POSIX qw(strftime);
use Getopt::Long qw(:config no_ignore_case_always);
use File::Basename;
use Config::Simple;
use Pod::Usage;
use IO::Socket::INET;
use IO::Select;

my $prog    = basename($0);
my $confile = basename($0, '.pl');
my $VERSION = "(NCID) XxXxX";

my $IDENT = "HELLO: IDENT: gateway $prog $VERSION";
my $COMMAND = "HELLO: CMD: no_log";

my $ConfigDir  = "/usr/local/etc/ncid";
my $ConfigFile = "$ConfigDir/$confile.conf";

my ($ncidaddr, $ncidport) = ("localhost", 3333);
my ($peerport, $peeraddr);
my $ncidhost = "";
my $ncidsock = undef;
my $ncidline = undef;
my $nciddate = "";
my $ncidname = "";
my $ncidnmbr = "";
my $obiport  = 4335;
my $cl_obiport = undef;
my $obisock = undef;
my $obidata;
my $abort = 1;
my $delay = 30;
my $cl_delay = undef;
my $logfile = basename($0, '.pl');
   $logfile = "/var/log/" . $logfile . ".log";
my ($logfileMode, $logfileModeEnglish);
my $logfileAppend;
my $logfileOverwrite;
my $rawfile;
my ($rawfileMode, $rawfileModeEnglish);
my $rawfileAppend;
my $rawfileOverwrite;
my ($doingRawfileWrite,$rawfileOpen);
my $debug;
my $verbose = 1;
my $cl_verbose = undef;
my ($help, $man, $version);
my $pidfile = "";
my ($pid, $savepid);
my $test;
my $fileopen;
my ($select, @ready, $rh);
my ($cfg, %config);
my $lineOBi = "OBITALK";
my $noLineID = "OBIHAI";
my $lineid = "";
my $lineFXO = "FXO";
my $lineFXS = "FXS";
my $linefx;
my $cl_linefx;
my ($linesp1, $linesp2, $linesp3, $linesp4);
my $sip = 0;
my $fxo = 0;
my $fxs = 0;
my ($incall, $outcall, $startcall, $endcall, $connected, $gtalk);
my ($scall, $ecall, $calltype, $callend, $dialok);
my $digit = "";
my ($x, $y);
my $noFilter = 0;
my $doFilter;
my $configFilterError = "";

my $def_sp = "         "; # default spaces used for indenting
my ($sp, $stamp, $stampSp);
my $margin = 79;
my (@prettyData, @prettyIndent);

my ($packetUTC, $packetDate);
my $lastPacketUTC = 0;
my $lastPacketDelay = 5; # minimum seconds between packets to trigger $lastPacketSeparator
my $lastPacketSeparator = "=" x $margin;
my $sendToNcidSeparator = ">" x $margin;
my $recvFromNcidSeparator = "<" x $margin;
my $showLastPacketSeparator = 0;
my $packetCount = 0;
my $showPacketDate = 0;
my $showPacketCount = 0;

# default filters in case there is no obi2ncid.conf,
# or if obi2ncid.conf doesn't have any filter lines at all
my @def_filter = ();
push @def_filter, "PRD:NOPriFbToTry";
push @def_filter, "Prd:SrvName";
push @def_filter, "BASE:resolving root.pnn.obihai.com";
push @def_filter, "IPC: Event";
push @def_filter, "DNS SERVER:";
push @def_filter, "ETH: WAN primary has been renewed!";
push @def_filter, "SNTP->pool.ntp.org";
push @def_filter, "SIP Err:MissingReqHdr";

my @filter = ();

my $date = strftime("%m/%d/%Y %H:%M:%S", localtime);

$endcall = 0;
&resetFlags;

my @fxocall = ({type=>"", line=>"", nmbr=>"", name=>"", scall=>"", callend=>""});

# command line processing
#
# It is intentional that linesp1-linesp4 cannot be
# set by the command line because it was not deemed
# to be useful to do so.
#
my @save_argv = @ARGV;
Getopt::Long::Configure ("bundling");
my ($result) = GetOptions(
               "configfile|C=s" => \$ConfigFile,
               "debug|D" => \$debug,
               "delay|d=i" => \$cl_delay,
               "help|h" => \$help,
               "linefx|f=s" => \$cl_linefx,
               "logfile-append|l=s" => \$logfileAppend,
               "logfile-overwrite|L=s" => \$logfileOverwrite,
               "man|m" => \$man,
               "ncidhost|n=s" => \$ncidhost,
               "no-filter|N" => \$noFilter,
               "obiport|o=s" => \$cl_obiport,
               "pidfile|p=s" => \$pidfile,
               "rawfile-append|r=s" => \$rawfileAppend,
               "rawfile-overwrite|R=s" => \$rawfileOverwrite,
               "test|t" => \$test,
               "verbose|v=i" => \$cl_verbose,
               "version|V" => \$version,
             ) || pod2usage(2);
die "$prog $VERSION\n" if $version;
pod2usage(-verbose => 1, -exitval => 0) if $help;
pod2usage(-verbose => 2, -exitval => 0) if $man;

$doFilter = 1 - $noFilter;

# reading configuration file after command line processing
# is necessary because the command line can change the
# location of the configuration file
$cfg = new Config::Simple($ConfigFile);
if (defined $cfg) {
    # opened config file
    %config = $cfg->vars();
    $x="default.verbose"  ;$verbose  = $config{$x} if defined $config{$x};
    $x="default.ncidaddr" ;$ncidaddr = $config{$x} if defined $config{$x};
    $x="default.ncidport" ;$ncidport = $config{$x} if defined $config{$x};
    $x="default.delay"    ;$delay    = $config{$x} if defined $config{$x};
    $x="default.obiport"  ;$obiport  = $config{$x} if defined $config{$x};
    $x="default.linefx"   ;$linefx   = $config{$x} if defined $config{$x};
    $x="default.linesp1"  ;$linesp1  = $config{$x} if defined $config{$x};
    $x="default.linesp2"  ;$linesp2  = $config{$x} if defined $config{$x};
    $x="default.linesp3"  ;$linesp3  = $config{$x} if defined $config{$x};
    $x="default.linesp4"  ;$linesp4  = $config{$x} if defined $config{$x};
    
    # Config::Simple only keeps the last "filter = " line but we need
    # to read and store all of them.
    if ($doFilter) {
       @filter = ();
       if (open(CONFIGFILE, $ConfigFile)) {
           while (<CONFIGFILE>) {
              # http://docstore.mik.ua/orelly/perl/cookbook/ch08_17.htm
              chomp;
              s/^\s+.*\s+$//;         # remove leading and trailing whitespace          
              next unless length;     # anything left?
              my ($var, $value) = split(/\s*=\s*/, $_, 2);
              if ($var eq "filter") {
                 if (substr($value,0,1) eq '"') {$value=substr($value,1);} # remove leading quote
                 if (substr($value,-1,1) eq '"') {$value=substr($value,0,-1);} # remove trailing quote
                 push @filter, $value if length($value);
              }
           }
           if (!@filter) {
              $configFilterError = "Config file has no 'filter' lines\n";
           }
       } else {
           $configFilterError = "Could not re-open $ConfigFile to read 'filter' lines\n";
       }
    }

}

if ($doFilter && !@filter) {
   # user wants to filter but the config file doesn't have any, or we
   # couldn't read the config file
   $configFilterError .= "Using default filters\n";
   @filter = @def_filter;
}   

$doingRawfileWrite = defined $rawfileAppend || $rawfileOverwrite;
   
if ($test) {
    $debug = 1;
    $verbose = 3;
}

# these command line values override the configuration file values
$delay    = $cl_delay if defined $cl_delay;
$linefx   = $cl_linefx if $cl_linefx;
$ncidport = $1 if $ncidhost =~ s/:(\d+)//;
$ncidaddr = $ncidhost if $ncidhost;
$obiport  = $cl_obiport if defined $cl_obiport;
$verbose  = $cl_verbose if defined $cl_verbose;
$linesp1  = "SP1" if !$linesp1;
$linesp2  = "SP2" if !$linesp2;
$linesp3  = "SP3" if !$linesp3;
$linesp4  = "SP4" if !$linesp4;

if ($linefx) { $lineFXO = $lineFXS = $linefx; }

if ($verbose >=5 ) {
   $showPacketCount = 1;
}

if ($verbose >=6 ) {
   $showLastPacketSeparator = 1;
   $showPacketDate = 1;
}

&openLogfileForWriting;

&openRawfileForWriting if $doingRawfileWrite;

logMsg(1, "Started: $date\n");

# log command line and any options on separate lines
my $cl = "Command line: " . $0;
for my $arg (@save_argv) {
    if ( '-' eq substr($arg, 0, 1)) {
        logMsg(1, "$cl\n");
        $cl = "              $arg";
    } else {
        $cl = $cl . " " . $arg;
    }
}
logMsg(1, "$cl\n");

if ($fileopen) {logMsg(1, "Logfile: $logfileModeEnglish $logfile\n");}
else {logMsg(1, "Could not open logfile: $logfile\n");}

if ($doingRawfileWrite) {
   logMsg(1, "Rawfile: $rawfileModeEnglish $rawfile\n");
}

if (defined $cfg) {logMsg(1, "Processed config file: $ConfigFile\n");}
else {logMsg(1, "Config file not found: $ConfigFile\n");}

if ($configFilterError) {logMsg(1, $configFilterError);}

logMsg(1, "Gateway: $prog version $VERSION\n");
logMsg(1, "Verbose level: $verbose\n");
logMsg(1, "lineFXO: $lineFXO\n");
logMsg(1, "lineFXS: $lineFXS\n");
logMsg(1, "linesp1: $linesp1\n");
logMsg(1, "linesp2: $linesp2\n");
logMsg(1, "linesp3: $linesp3\n");
logMsg(1, "linesp4: $linesp4\n");
logMsg(1, "lineOBi: $lineOBi\n");
logMsg(1, "noLineID: $noLineID\n");
logMsg(1, "NCID server: $ncidaddr:$ncidport\n");
logMsg(1, "delay between each try to reconnect to server is $delay seconds\n");
logMsg(1, "Filtering is " . (!@filter ? "OFF" : "ON") . "\n");

if (@filter) {
   logMsg(6,"\nFilters loaded:\n\n");
   foreach $x (@filter) {
      logMsg(6,"   $x\n");
   }
   logMsg(6,"\n");
}

&doPID;

logMsg(1, "Debug mode\n") if ($debug);
if ($test) {logMsg(1, "Test mode\nNot sending data to NCID server\n");}

$SIG{'HUP'}  = 'sigHandle';
$SIG{'INT'}  = 'sigHandle';
$SIG{'QUIT'} = 'sigHandle';
$SIG{'TERM'} = 'sigHandle';
$SIG{'PIPE'} = 'sigIgnore';

$select = IO::Select->new();

# $select undefined if could not create new object
errorExit("ERROR in Select Object Creation : $!") if !defined $select;

&connectNCID if !$test;
$abort = 0;

&connectOBI;

# get a set of readable handles, block until at least one is ready
while (1) {
    if (!(@ready = $select->can_read($delay))) {
        # select timeout
        if (!$test && !defined $ncidsock) {
            &connectNCID;
            if (defined  $ncidsock) {
                logMsg(1, "Listening at port $obiport\n");
            }
        }
    }
    foreach $rh (@ready) {
        if (defined $ncidsock && $rh == $ncidsock) {
          # NCID server Caller ID
          $ncidline = <$rh>;
          if (!defined $ncidline) {
            $select->remove($ncidsock);
            $ncidsock = undef;
            logMsg(1, "NCID server at $ncidaddr:$ncidport disconnected\n");
            logMsg(1, "Trying to reconnect every $delay seconds\n");
          }
          else { 
              logMsg(5, "\n$recvFromNcidSeparator\n");
              logMsg(5, $ncidline);
              logMsg(5, "$recvFromNcidSeparator\n");
          }
        }
        elsif ($rh == $obisock) {
          # OBI has data
          $rh->recv($obidata, 1024);
          if (!$test && !defined $ncidsock) { &connectNCID; }
          $packetUTC = time;
          $packetCount++;
          &writeToRawfile ($obidata) if $doingRawfileWrite;

          my $okToProcessPacket = 1;
          if ($verbose >= 5) {
            if (@filter) {
              foreach my $x (@filter) {
                if ($obidata =~ /$x/) {
                  $okToProcessPacket = 0;
                  last;
                }
              }
            }
          }
          if ($okToProcessPacket) {
             &gotPacket;
             &doPacket;
          }

        }
        else {
            print ("Obi device disconnect?\n");
        }
    }
}

sub connectNCID {
  $ncidsock = IO::Socket::INET->new (
    Proto    => 'tcp',
    PeerAddr => $ncidaddr,
    PeerPort => $ncidport,
  );

  # $ncidsock undefined if could not connect to server
  if (!defined $ncidsock) {
    if (!$abort) {return;}
    else {errorExit("NCID server: $ncidaddr:$ncidport $!");}
  }

  logMsg(1, "Connected to NCID server at $ncidaddr:$ncidport\n");

  # send ident to server
  print $ncidsock "$IDENT\n";
  logMsg(1, "Sent: $IDENT\n");

  # make sure call log not sent
  print $ncidsock "$COMMAND\n";
  logMsg(1, "Sent: $COMMAND\n");

  my $greeting = <$ncidsock>;
  logMsg(1, "$greeting");

  # read and discard cidcall log sent from server
  while (<$ncidsock>)
  {
    # a log file may or nay not be sent
    # but a 300 message is always sent

    if (/^[23]\d\d/) { logMsg(1, $_); }
    else { logMsg(7, $_); }
    last if /^300/;
  };

  $select->add($ncidsock);
}

sub connectOBI {
  $obisock = IO::Socket::INET->new (
    Proto     => 'udp',
    LocalPort => $obiport,
    Reuse     => 1
  ) or errorExit("Could not listen at port: $obiport $!");

  logMsg(1, "Listening at port $obiport\n");

  $select->add($obisock);
}

sub gotPacket {

    #$packetDate = strftime("%m/%d/%Y %H:%M:%S", localtime($packetUTC));
    $packetDate = strftime("%H:%M:%S", localtime($packetUTC));

    $stamp="";
    if ($showPacketDate) {
       $stamp=$packetDate . " ";
    }
    if ($showPacketCount) {
       $stamp=$stamp . sprintf("[%5d] ",$packetCount);
    }
    $stampSp=" " x length($stamp);
    $sp = $stampSp . $def_sp; # indent

    &initPrettyData;
            
    my $diff=$packetUTC-$lastPacketUTC;
    if ($lastPacketUTC >0 && $diff >= $lastPacketDelay) {
       logMsg(5, "\n" . $lastPacketSeparator . "\n") if $showLastPacketSeparator;
    }
    $lastPacketUTC = $packetUTC;
                  
    logMsg(5, "\n");
    logMsg(5,showPrettyData($stamp . "Got  : "));

}

# incoming or outgoing call
sub doPacket {
    
    my ($cname, $cnmbr, $cstate);

    logMsg(6, "Packet Start:\n$obidata\nPacket End\n");

    if ($obidata =~ /GTALK:sess/) {
        logMsg(4, $stampSp . "Match:    GTALK:sess\n");
        if ($obidata =~ /from 0 to/) {
            logMsg(4, $stampSp . "Match:    from 0 to\n");
            $lineid = "GTALK";
            $incall = 1 if !$outcall;
            $gtalk = 1;
            logMsg(4, "$sp incall=$incall gtalk=$gtalk lineid=$lineid dialok=$dialok\n");
        }
        elsif ($obidata =~ /from 4 to/) {
            logMsg(4, $stampSp . "Match:    from 4 to\n");
            logMsg(4, "$sp incall=$incall gtalk=$gtalk lineid=$lineid connected=$connected\n");
            &doCallStart;
        }
    }
    elsif ($obidata =~ /GTT:call.* [56] to/) {
        logMsg(4, $stampSp . "Match:    GTT:call.* [56] to\n");
        $connected = 1;
        logMsg(4, "$sp incall=$incall gtalk=$gtalk lineid=$lineid connected=$connected\n");
    }
    elsif ($obidata =~ /ringback/ || $obidata =~ /:Retx/) {
        logMsg(4, $stampSp . "Match:    ringback|:Retx\n");
        &doCallStart;
    }
    elsif ($obidata =~ /DAA CND/) {
        # this is an FXS call, as such no call flags can be set
        # $cnmbr, $cname, $cstate are tmp variables and can be set
        # $lineid cannot be set
        logMsg(4, $stampSp . "Match:    DAA CND\n");
        ($cnmbr)  = $obidata =~ /\d+,(.+?),/;
        ($cname)  = $obidata =~ /\d+,.+?,(.+?),/;
        ($cstate) = $obidata =~ /\d+,.+?,.+?,( \w+)/;
                                         
        if (defined $cnmbr) {
           $cname = "" if !defined $cname;
           if (defined $cstate) {$cname = $cname . "," . $cstate;}
        
           $fxo = 1;

           $fxocall[0]{type} = "IN";
           $fxocall[0]{line} = $lineFXO;
           $fxocall[0]{nmbr} = $cnmbr;
           $fxocall[0]{name} = $cname;
           $fxocall[0]{callend} = "CANCEL";
           logMsg(4, "$sp fxo=$fxo  FXOline=$lineFXO\n");
           logMsg(4, "$sp         FXOnmbr=$cnmbr\n");
           logMsg(4, "$sp         FXOname=$cname\n");
           &doCallStart;
        }
        
    }
    elsif ($obidata =~ /^REGISTER sip/mo) {
        logMsg(4, $stampSp . "Match:    ^REGISTER sip\n");
        logMsg(4, "$sp sip=$sip gtalk=$gtalk incall=$incall outcall=$outcall\n");
        if ($gtalk) { return; }
        ($lineid) = $obidata =~ /^[Tt]o?:\s+<sip:\w*(\w\w\w\w\w\w)@/mo;
        logMsg(4, "$sp sip outcall: lineid  =$lineid\n");
    }
    elsif ($obidata =~ /^INVITE sip/mo) {
        logMsg(4, $stampSp . "Match:    ^INVITE sip\n");
        if ($sip || $gtalk) { return; }
        logMsg(4, "$sp sip=$sip gtalk=$gtalk incall=$incall outcall=$outcall\n");
        $incall = 1 if !$outcall;
        if ($incall) {
            ($lineid) = $obidata =~ /^[Tt]o?:\s+<sip:\w*(\w\w\w\w\w\w)@/mo;
            ($ncidname, $ncidnmbr) = $obidata =~ /^[Ff]r?o?m?:\s+"(.*)"\s+<sip:([-)(\w]+)@/mo;
            logMsg(4, "$sp sip incall: lineid  =$lineid\n");
            logMsg(4, "$sp             ncidnmbr=$ncidnmbr\n");
            logMsg(4, "$sp             ncidname=$ncidname\n");
        } else {
            ($lineid) = $obidata =~ /^[Ff]r?o?m?:\s+<sip:\w*(\w\w\w\w\w\w)@/mo;
            ($ncidnmbr) = $obidata =~ /^[Tt]o:\s+<sip:(\w+)@/mo;
            logMsg(4, "$sp sip outcall: lineid  =$lineid\n");
            logMsg(4, "$sp              ncidnmbr=$ncidnmbr\n");
        }
        $sip = 1;
        if ($incall || $outcall) { &doCallStart; }
    }
    elsif ($obidata =~ /:WebrtcIn/) {
        logMsg(4, $stampSp . "Match:    :WebrtcIn\n");
        $outcall = 0;
        logMsg(4, "$sp outcall=$outcall  lineid=$lineid\n");
    }
    elsif ($obidata =~ /:Start/) {
        logMsg(4, $stampSp . "Match:    :Start\n");
        $connected = 1 if (!$gtalk && !$connected);
        logMsg(4, "$sp connected=$connected\n");
        &doCallStart;
    }
    elsif ($obidata =~ /:NewCallOn.*>[,\w]\w/) {
        logMsg(4, $stampSp . "Match:    :NewCallOn.*[,\\w]\\w\n");
        $dialok = 1;
        if ($outcall) {
            if ($obidata =~ /Term 9/) {
                $fxo = 1;
                $fxocall[0]{type} = "OUT";
                $fxocall[0]{line} = $lineFXO;
                $fxocall[0]{nmbr} = $ncidnmbr;
                $fxocall[0]{name} = $ncidnmbr;
            } else {
                if (!$lineid) { ($lineid) = $obidata =~ /,\w*(\w\w\w\w)/; }
            }
            logMsg(4, "$sp outcall: lineid  =$lineid\n");
            logMsg(4, "$sp          ncidnmbr=$ncidnmbr\n");
        } else {
            $incall = 1;
            ($ncidname, $ncidnmbr) = $obidata =~ /(\w+),(\w+)/;
            $ncidnmbr = "" if !defined $ncidnmbr;
            $ncidname = "" if !defined $ncidname;
            logMsg(4, "$sp incall: lineid  =$lineid\n");
            logMsg(4, "$sp         ncidnmbr=$ncidnmbr\n");
            logMsg(4, "$sp         ncidname=$ncidname\n");
        }
        logMsg(4, "$sp dialok=$dialok outcall=$outcall incall=$incall fxo=$fxo\n");
            &doCallStart if $fxo;
    }
    elsif ($obidata =~ /:NewCallOn.*>,/) {
        logMsg(4, $stampSp . "Match:    :NewCallOn.*,\n");
        logMsg(4, "$sp lineid=$lineid outcall=$outcall incall=$incall\n");
        if ($lineid eq "") { &resetFlags;  $endcall = 1 }
    }
    elsif ($obidata =~ /CID to deliver:/) {
        logMsg(4, $stampSp . "Match:    CID to deliver:\n");
        if ($fxo) {
            logMsg(4, "$sp fxo=$fxo, FXO call, nothing to do\n");
        }
        else {
            ($cname, $cnmbr) = $obidata =~ /'(.*)'\s+([-)(\w]+)/;

            if (!defined $cname) { return; }
            # Ignore name and number == (null)
            if ($cname =~ '(null)' && $cnmbr =~ '(null)') { return; }

            $incall = 1 if !$outcall;
            $ncidname = $cname;
            $ncidnmbr = $cnmbr;
            logMsg(4, "$sp incall=$incall  outcall=$outcall\n");
            logMsg(4, "$sp ncidnmbr=$ncidnmbr\n");
            logMsg(4, "$sp ncidname=$ncidname\n");
            &doCallStart
        }
    }
    elsif ($obidata =~ /:Call terminated/) {
        logMsg(4, $stampSp . "Match:    :Call terminated\n");
        if ($incall || $outcall) {
            if ($obidata =~ /cancelled/) { $callend = "CANCEL"; }
            else { $callend = "BYE"; }
            logMsg(4, "$sp incall=$incall  outcall=$outcall\n");
            &doCallEnd;
        }
    }
    elsif ($obidata =~ /:Del Channel/) {
        logMsg(4, $stampSp . "Match:    :Del Channel\n");
        if ($incall || $outcall) {
            if ($connected) { $callend = "BYE"; }
            else { $callend = "CANCEL"; }
            logMsg(4, "$sp incall=$incall  outcall=$outcall\n");
            &doCallEnd;
        }
        $lineid = "";
    }
    elsif ($obidata =~/FXO OFFHOOK/) {
        # this indicates an FXS call was picked up (start of call)
        # $fxo was set to 0 in &doCallStart
        # $fxo cannot be set to 1;
        # no call flags can be set
        logMsg(4, $stampSp . "Match:    FXO OFFHOOK\n");
        $fxocall[0]{callend} = "BYE";
        logMsg(4, "$sp fxo=$fxo callend=BYE\n");
    }
    elsif ($obidata =~/FXO ONHOOK/) {
        # this indicates an FXS call ended
        # $fxo was set to 0 in &doCallStart
        # $fxo must be set to 1;
        # no call flags can be set
        logMsg(4, $stampSp . "Match:    FXO ONHOOK\n");
        $fxo = 1;
        logMsg(4, "$sp fxs=$fxs fxo=$fxo\n");
        if ($fxocall[0]{line} ne "") { &doCallEnd(); }
    }
    elsif (($incall || $outcall) && $obidata =~ /ONHOOK/) {
        logMsg(4, $stampSp . "Match:    ONHOOK\n");
        logMsg(4, "$sp dialok=$dialok\n");
        if ($sip) {
            logMsg(4, "$sp sip=$sip\n");
        }
        elsif ($incall) {
            $callend = "BYE";
            &doCallEnd;
        }
        elsif (!$dialok) {
            logMsg(4, $stampSp . "Incomplete call\n");
            &resetFlags;
            $endcall = 1;
        }
        else {
                if ($outcall) {
                    if ($connected) {
                        $callend = "BYE";
                    } else {  $callend = "CANCEL"; }
                }
                else {  $callend = "BYE"; }
                logMsg(4, "$sp sip=$sip outcall=$outcall connected=$connected  callend=$callend\n");
                &doCallEnd;
        }
    }
    elsif ($obidata =~ /OFF HOOK|HOOK FLASH/) {
        logMsg(4, $stampSp . "Match:    OFF HOOK|HOOK FLASH\n");
        $fxo = 0;  # needed for callcentric
        $outcall = 1 if !$incall;
        logMsg(4, "$sp incall=$incall  outcall=$outcall\n");
    }
    elsif ($obidata =~ /DTMF ON/) {
        logMsg(4, $stampSp . "Match:    DTMF ON\n");
        ($digit) = $obidata =~ /\s:\s(.)\s@/;
        $digit="<no digit>" if !defined $digit;
        if ($dialok) {
           logMsg(4, "$sp Phone number already captured. Ignoring digit $digit.");
        } else {
           logMsg(4, "$sp ncidnmbr=$ncidnmbr + digit=$digit = $ncidnmbr$digit\n");
           $ncidnmbr = "$ncidnmbr$digit";
           if ($ncidnmbr =~ /\*\*\d/ && !($ncidnmbr =~ /\*\*7/)) {
              logMsg(4, "$sp Selecting outgoing line $ncidnmbr\n");
              if    ($ncidnmbr =~ /\*\*1/) { $lineid = $linesp1; }
              elsif ($ncidnmbr =~ /\*\*2/) { $lineid = $linesp2; }
              elsif ($ncidnmbr =~ /\*\*3/) { $lineid = $linesp3; }
              elsif ($ncidnmbr =~ /\*\*4/) { $lineid = $linesp4; }
              elsif ($ncidnmbr =~ /\*\*9/) { $lineid = $lineOBi; }
              logMsg(4, "$sp lineid=$lineid\n");
              $ncidnmbr = "";
           }
           elsif ($ncidnmbr =~ /##/ || $ncidnmbr =~ /\*\*70/) {
              # phone line connected to OBILINE selected by "##" or "**70"
              logMsg(4, "$sp Selecting outgoing $lineFXS line with $ncidnmbr\n");
              $lineid = $lineFXS;
              $fxs = 1;
              $ncidnmbr = "";
           }
        }
    }
    elsif ($obidata =~ /^CANCEL sip/mo || $obidata =~ /^BYE sip/mo) {
        logMsg(4, $stampSp . "Match:    ^CANCEL sip|^BYE sip\n");
        logMsg(4, "$sp incall=$incall  outcall=$outcall\n");
        if ($incall || $outcall) {
            if ($obidata =~ /^CANCEL/mo) { $callend = "CANCEL"; }
            else { $callend = "BYE"; }
            logMsg(4, "$sp callend=$callend\n");
            &doCallEnd;
        }
    }
}

sub doCallStart () {
    my $msg;

    $nciddate = strftime("%m%d%H%M", localtime);
    $scall = strftime("%m/%d/%Y %H:%M:%S", localtime);
    $ncidname = "NONAME" if !$ncidname; 
    $dialok = 1 if $outcall;

    #logMsg(4, "\n" . $stampSp . "doCallStart(): fxo=$fxo endcall=$endcall dialok=$dialok\n");
    logMsg(4, "\n");
    
    if ($fxo) {
        $msg = sprintf("CALL: ###DATE%s...CALL%s...LINE%s...NMBR%s...NAME%s+++",
          $nciddate, $fxocall[0]{type}, $fxocall[0]{line}, $fxocall[0]{nmbr},
          $fxocall[0]{name}, $fxocall[0]{scall});
          $fxocall[0]{scall} = $scall;
          $fxo = 0;
    }
    else {
        if ($startcall) {
            logMsg(4, "$sendToNcidSeparator\n");
            logMsg(4, "startcall=$startcall, CALL line already sent\n");
            logMsg(4, "$sendToNcidSeparator\n");
            return;
        }
        $startcall = 1;
        if (!$incall && !$outcall) {
          logMsg(1, "WARNING: Cannot determine if incoming or outgoing call\n");
          logMsg(1, "WARNING: Call Type may be wrong\n");
        }
        $endcall = 0;
        if (!$lineid) { $lineid = $lineOBi; }
        if ($outcall) { $calltype = "OUT"; }
        else { $calltype = "IN"; }
        $msg = sprintf("CALL: ###DATE%s...CALL%s...LINE%s...NMBR%s...NAME%s+++",
          $nciddate, $calltype, $lineid, $ncidnmbr, $ncidname);
    }
    logMsg(5, "\n$sendToNcidSeparator\n");
    logMsg(3, "$msg\n");
    logMsg(5, "$sendToNcidSeparator\n");
    if (!$test && defined $ncidsock) { print $ncidsock $msg, "\r\n"; }
}

sub doCallEnd() {
    my $msg;

    $nciddate = strftime("%m%d%H%M", localtime);
    $ecall = strftime("%m/%d/%Y %H:%M:%S", localtime);

    #logMsg(4, "\n" . $stampSp . "doCallEnd(): fxo=$fxo\n\n");
    logMsg(4, "\n");
    
    if ($fxo) {
        $msg = sprintf(
          "CALLINFO: ###%s...DATE%s...SCALL%s...ECALL%s...CALL%s...LINE%s...NMBR%s...NAME%s+++",
          $fxocall[0]{callend}, $nciddate, $fxocall[0]{scall}, $ecall,
          $fxocall[0]{type},
          $fxocall[0]{line}, $fxocall[0]{nmbr}, $fxocall[0]{name});
        logMsg(5, "\n$sendToNcidSeparator\n");
        logMsg(3, "$msg\n");
        logMsg(5, "$sendToNcidSeparator\n");
        if (!$test && defined $ncidsock) { print $ncidsock $msg, "\r\n"; }

        $fxocall[0]{line} = "";
        $fxocall[0]{nmbr} = "";
        $fxocall[0]{name} = "";
        $fxocall[0]{scall} = "";
        $fxo = 0;
    }
    else {
      if (!$startcall && $endcall) {
        logMsg(5, "$sendToNcidSeparator\n");
        logMsg(5, "startcall=$startcall, endcall=$endcall CALLINFO line already sent\n");
        logMsg(5, "$sendToNcidSeparator\n");
        &resetFlags;
        return;
      }
      $endcall = 1;
      if ($ncidnmbr) {
        $msg = sprintf(
          "CALLINFO: ###%s...DATE%s...SCALL%s...ECALL%s...CALL%s...LINE%s...NMBR%s...NAME%s+++",
          $callend, $nciddate, $scall, $ecall, $calltype, $lineid, $ncidnmbr, $ncidname);
        logMsg(5, "\n$sendToNcidSeparator\n");
        logMsg(3, "$msg\n");
        logMsg(5, "$sendToNcidSeparator\n");
        if (!$test && defined $ncidsock) { print $ncidsock $msg, "\r\n"; }
      } else {
        if ($connected) {
          logMsg(3, "Did not receive number for Outgoing Call\n");
        } else {
          logMsg(3, "Outgoing Call not completed\n");
        }
      }
      &resetFlags;
    }
}

sub resetFlags {
    $dialok = $incall = $outcall = $startcall = $connected = $gtalk = $sip = $fxo = $fxs =0;
    $calltype = $ncidname = $ncidnmbr = $nciddate = $scall = $ecall = $lineid = $callend = "";
}

sub showCallStateFlags {
    my $heading = shift;
    my $sp2=$stampSp; # indent    
    if (length($heading) && $heading ne $sp) {
       logMsg(4,$sp2 . "$heading\n");
       #$sp2=$stampSp . " " . " " x length($heading);
       $sp2=$stampSp . " " . $def_sp;
    }
    
    $x = defined  $connected     ? $connected : "?";
    $y = defined  $dialok        ? $dialok    : "?";
    logMsg(4,$sp2 . "connected   =$x  dialok     =$y\n");

    $x = defined  $sip           ? $sip       : "?";
    $y = defined  $startcall     ? $startcall   : "?";
    logMsg(4,$sp2 . "sip         =$x  newcall    =$y\n");

    $x = defined  $gtalk         ? $gtalk    : "?";
    $y = defined  $incall        ? $incall   : "?";
    logMsg(4,$sp2 . "gtalk       =$x  incall     =$y\n");

    $x = defined  $fxs           ? $fxs      : "?";
    $y = defined  $outcall       ? $outcall  : "?";
    logMsg(4,$sp2 . "fxs         =$x  outcall    =$y\n");

    $x = defined  $fxo           ? $fxo      : "?";
    $y = defined  $endcall       ? $endcall  : "?";
    logMsg(4,$sp2 . "fxo         =$x  endcall    =$y\n");
    
    logMsg(4,"\n");
    
    $x = defined  $callend       ? $callend  : "<undefined>";
    logMsg(4,$sp2 . "callend     =$x\n");

    $x = defined  $lineid        ? $lineid   : "<undefined>";
    logMsg(4,$sp2 . "lineid      =$x\n");

    $x = defined  $ncidnmbr      ? $ncidnmbr : "<undefined>";
    logMsg(4,$sp2 . "ncidnmbr    =$x\n");

    $x = defined  $ncidname      ? $ncidname : "<undefined>";
    logMsg(4,$sp2 . "ncidname    =$x\n");

    $x = defined  $fxocall[0]{callend} ? $fxocall[0]{callend} : "<undefined>";
    logMsg(4,$sp2 . "fxocallEND  =\n");

    $x = defined  $fxocall[0]{line}    ? $fxocall[0]{line}    : "<undefined>";
    logMsg(4,$sp2 . "fxocallLINE =$x\n");

    $x = defined  $fxocall[0]{nmbr}    ? $fxocall[0]{nmbr}    : "<undefined>";
    logMsg(4,$sp2 . "fxocallNMBR =$x\n");

    $x = defined  $fxocall[0]{name}    ? $fxocall[0]{name}    : "<undefined>";
    logMsg(4,$sp2 . "fxocallNAME =$x\n");

    $x = defined  $fxocall[0]{scall}   ? $fxocall[0]{scall}   : "<undefined>";
    logMsg(4,$sp2 . "fxocallSCALL=$x\n");

    logMsg(4,"\n");
}

sub initPrettyData {

   # This routine takes input data and splits by newlines, and then further
   # splits and indents by comma and semi-colon delimited fields.
   #
   # When there's a colon on a line, its position determines the amount of indent
   # for subsequent comma and semi-colon delimited fields. Indentation for each
   # line is stored in @prettyIndent.
   # 
   # E.G., non-pretty input data:
   #
   # SIP/2.0 200 OK\n
   # Call-ID: 7915393-3627523159-101678@msw1.telengy.net\n
   # CSeq: 1 CANCEL\n
   # Content-Length: 0\n
   # From: "ACME WIDGETS" <sip:14715551212@66.193.176.35>;tag=3627523159-101710\n
   # To: <sip:19055551212@ss.callcentric.com>;tag=SP1159b546023bac174\n
   # Via: SIP/2.0/UDP 204.11.192.170:5080;branch=z9hG4bK-44c657aafa40c806dd689aeb5575dbde;received=204.11.192.170;rport=5080\n
   # Server: OBIHAI/OBi110-1.3.0.2824\n
   #
   # will eventually become in &showPrettyData:
   #
   # SIP/2.0 200 OK\n
   # Call-ID: 7915393-3627523159-101678@msw1.telengy.net\n
   # CSeq: 1 CANCEL\n
   # Content-Length: 0\n
   # From: "ACME WIDGETS" <sip:14715551212@66.193.176.35>;\n
   #       tag=3627523159-101710\n
   # To: <sip:19055551212@ss.callcentric.com>;\n
   #     tag=SP1159b546023bac174\n
   # Via: SIP/2.0/UDP 204.11.192.170:5080;\n
   #      branch=z9hG4bK-44c657aafa40c806dd689aeb5575dbde;\n
   #      received=204.11.192.170;\n
   #      rport=5080\n
   # Server: OBIHAI/OBi110-1.3.0.2824\n

    my $tmpdata = $obidata;
    $tmpdata =~ s/\0/<null>/g;
    my @tmpdataPretty=split("\n",$tmpdata);
    @prettyData=();
    @prettyIndent=();
    
    my $max;
    my $count;
        
    foreach my $text (@tmpdataPretty) {
          
          # don't prettify lines that begin with "<" : <7> PRD:NOPriFbToTry
          # handle lines with zero space after colon : ACK sip:14715551212; rn=6465701001
          # and one+ space(s) after colon            : Diversion: <sip:633074@66.193.176.47>; reason=unavailable;
          
          my $colon=0;
          if (length($text)) {
             if (substr($text,0,1) ne "<") {
                $colon=index($text,": ");
                if ($colon gt -1) {
                   $colon=$colon+2;
                } else {
                  $colon=index($text,":");
                  if ($colon gt -1) {
                     $colon=$colon+1;
                  } else {
                  $colon=0;
                  }
               }
             }
          }
                
          my $c;
          my $x;
          my $s;
          my $firstTime;
          my $added=0;
          my $indent;

          $c=","; # must process commas first
          $x=index($text,$c);
          if ($x gt -1 && $colon ne 0 && !$added) {
             my @tmp1=split($c,$text);
             $added=1;
             $firstTime=1;
             $max = $#tmp1;
             foreach $count (0..$max) {
                $indent=$firstTime ? 0 : $colon;
                $s=$tmp1[$count];
                $s=$s . $c if $count ne $max;
                push (@prettyData, $s);
                push (@prettyIndent, $indent);
                $firstTime=0;
             }
          }
          
          $c=";";
          $x=index($text,$c);
          if ($x gt -1 && $colon ne 0 && !$added) {
             my @tmp1=split($c,$text);
             $added=1;
             $firstTime=1;
             $max = $#tmp1;
             foreach $count (0..$max) {
                $indent=$firstTime ? 0 : $colon;
                $s=$tmp1[$count];
                $s=$s . $c if $count ne $max;
                push (@prettyData, $s);
                push (@prettyIndent, $indent);
                $firstTime=0;
             }
          }
          
          if (!$added) {
             push (@prettyData, $text);
             push (@prettyIndent, 0);   
          }
    }
                  
}          

sub showPrettyData {

    my $f = shift; # first line of text, everything else indented to the right

    # This routine dynamically adjusts the indention of @prettyData so that it
    # will line up with the width of $f. Because the length of $f is dynamic,
    # this routine also handles line wrap within $margin.
    #
    # E.G.:
    # $f="Received: "
    # Received: SIP/2.0 200 OK\n
    #           Call-ID: 7915393-3627523159-101678@msw1.telengy.net\n
    #           From: "ACME WIDGETS" <sip:14715551212@66.193.176.35>;\n
    #                 tag=3627523159-101710\n
    #
    # $f="Test: "
    # Test: SIP/2.0 200 OK\n
    #       Call-ID: 7915393-3627523159-101678@msw1.telengy.net\n
    #       From: "ACME WIDGETS" <sip:14715551212@66.193.176.35>;\n
    #             tag=3627523159-101710\n
    #
        
    my $output="";
        
    my $max = $#prettyData;
        
    foreach my $count (0..$max) {
       my $remain = $prettyData[$count]; # text
     
       my $extraIndent = 0;
       my $equal = index($remain,"=");
       if ($equal gt -1) {$equal=$equal+1;}
       else {$equal = 0;}
       
       while ($remain) {
          
          my $projectedLength = length($f) + $prettyIndent[$count] + $extraIndent + length($remain);
          my $totalIndent = length($f) + $prettyIndent[$count] + $extraIndent;
          
          if ($projectedLength > $margin) {
             my $bytesToPrint=$margin-1-$totalIndent;
             $output=$output . $f . (" " x ($totalIndent-length($f))) . substr($remain,0,$bytesToPrint) . "\n";
             $f=" " x length($f);
             $remain=substr($remain,$bytesToPrint);
             $extraIndent=$equal;
          } else {
            $output=$output . $f . (" " x ($totalIndent-length($f))) . $remain . "\n";
            $f=" " x length($f);
            $remain=""
          }
       }
    }
    
    return "$output\n";

}    
    

sub doPID {
    # Only create a PID file if $pidfile contains a file name
    if ($pidfile ne "") {
        if (-e $pidfile) {
            # only one instance per computer permitted
            unless (open(PIDFILE, $pidfile)) {
                errorExit("pidfile exists and is unreadable: $pidfile\n");
            }
            $savepid = <PIDFILE>;
            close(PIDFILE);
            chop $savepid;

            # Check PID file to see if active PID in it
            # Does not work for Windows
            if (-d "/proc") {
                if (-d "/proc/$savepid") {
                    errorExit("Process ($savepid) already running: $pidfile\n");
                } else {
                    logMsg(1, "Found stale pidfile: $pidfile\n");
                }
            } else {
                my $ret = `ps $savepid 2>&1`;
                if ($? == 0) {
                    errorExit("Process ($savepid) already running: $pidfile\n");
                } elsif ($? != -1) {
                    logMsg(1, "Found stale pidfile: $pidfile\n");
                } else {
                    logMsg(1, "ps command not found\n");
                }
            }
        }

        if (open(PIDFILE, ">$pidfile")) {
            print(PIDFILE "$$\n");
            $pid = $$;
            close(PIDFILE);
            logMsg(1, "Wrote pid $pid in $pidfile\n");
        } else { logMsg(1, "Could not write pidfile: $pidfile\n"); }
    }   
    else {logMsg(1, "Not using PID file\n");}
}

sub openLogfileForWriting {

    $logfileMode = ">>"; # default to append
    $logfileModeEnglish = "Appending to";
      
    if ($logfileAppend and $logfileOverwrite) { $logfileOverwrite = undef; }
    
    if ($logfileOverwrite) {
       $logfileMode = ">";
       $logfileModeEnglish = "Overwriting";
       $logfile = $logfileOverwrite;
    } else {
      if ($logfileAppend) {
         $logfile = $logfileAppend;
      }
    }
    
    if (open(LOGFILE, "$logfileMode$logfile")) {
        LOGFILE->autoflush(1); # make LOGFILE handle 'hot', i.e., no buffering
        $fileopen = 1;
    }

}

sub openRawfileForWriting {

    $rawfileMode = ">>"; # default to append
    $rawfileModeEnglish = "Appending to";
      
    if ($rawfileAppend and $rawfileOverwrite) { $rawfileOverwrite = undef; }
    
    if ($rawfileOverwrite) {
       $rawfileMode = ">";
       $rawfileModeEnglish = "Overwriting";
       $rawfile = $rawfileOverwrite;
    } else {
      if ($rawfileAppend) {
         $rawfile = $rawfileAppend;
      }
    }
    
    open(RAWFILE, "$rawfileMode$rawfile")
        or errorExit("ERROR in creating rawfile $rawfile : $!");
        
    RAWFILE->autoflush(1); # make RAWFILE handle 'hot', i.e., no buffering
    $rawfileOpen = 1;
}    

sub logMsg {
    my($level, $message) = @_;

    if (!defined $message) {print "Oops, unexpected exit\n"; exit 1}

    # write to STDOUT
    print $message if $debug && $verbose >= $level;

    # write to logfile
    print LOGFILE $message if $fileopen && $verbose >= $level;
}

sub writeToRawfile {
    
    print RAWFILE @_;

}    

sub cleanup() {
    close($ncidsock) if $ncidsock;
    close($obisock) if $obisock;
    close(RAWFILE) if $rawfileOpen;
    unlink($pidfile) if $pid;
}

sub sigHandle {
    my $sig = shift;
    &cleanup;
    my $date = strftime("%m/%d/%Y %H:%M:%S", localtime);
    logMsg(1, "\nTerminated $date: Caught SIG$sig\n");
    close(LOGFILE);
    exit(0);
}

sub sigIgnore {
    my $sig = shift;
    my $date = strftime("%m/%d/%Y %H:%M:%S", localtime);
    logMsg(1, ": Ignored SIG$sig: $date\n");
}

sub errorExit {
    logMsg(1, "@_");
    &cleanup;
    my $date = strftime("%m/%d/%Y %H:%M:%S", localtime);
    logMsg(1, "\nTerminated: $date\n");
    close(LOGFILE);
    exit(-1);
}

=head1 NAME

obi2ncid - Obihai device to NCID gateway

=head1 SYNOPSIS

 obi2ncid [--configfile               |-C <filename>]
          [--debug                    |-D]
          [--delay                    |-d <seconds>]
          [--help                     |-h]
          [--linefx                   |-f <string>]
          [--logfile-append           |-l <filename>]
          [--logfile-overwrite        |-L <filename>]
          [--man                      |-m]
          [--ncidhost                 |-n <[host][:port]>]
          [--no-filter                |-N]
          [--obiport                  |-o <port>]
          [--pidfile                  |-p <filename>]
          [--rawfile-append           |-r <filename>]
          [--rawfile-overwrite        |-R <filename>]
          [--test                     |-t]
          [--verbose                  |-v <1-9>]
          [--version                  |-V]

=head1 DESCRIPTION

The B<obi2ncid> gateway obtains Caller ID from an Obihai VOiP 
telephone adapter and sends it to the NCID server.  The server 
then sends the CID information to the NCID clients.

The gateway was developed using Obi100, OBi110 and OBi200 devices
that were available.

The B<obi2ncid> gateway uses either GTALK, the Voice Service
AuthUserName, or the configurable default name for a line identifier.

The line identifier(s) can be aliased by the NCID server so you can give 
each Voice Service a meaningful identification.

The B<obi2ncid> configuration file is B</etc/ncid/obi2ncid.conf>.
See the obi2ncid.conf man page for more details.

The B<obi2ncid> gateway can run on any computer, but normally it is run
on same box as the NCID server.  If it is not run on the same box as the
NCID server, you must configure the server IP address in the configuration
file.

=head2 LINEID

The B<obi2ncid> gateway attempts to assign the lineid based on
the following table. "SP" is an abbreviation for "Service 
Provider" and "PSTN" is an abbreviation for "Public Switched
Telephone Network."

    Call type                       Lineid assigned
    =========                       ===============
    Google Voice in or out              "GTALK"
    VoIP in or out on default line   <AuthUserName>
    Incoming PSTN                        "FXO"
    Outgoing PSTN using ##<number>       "FXS"
    Outgoing VoIP using **1<number>      "SP1"
    Outgoing VoIP using **2<number>      "SP2"
    Outgoing VoIP using **3<number>      "SP3"
    Outgoing VoIP using **4<number>      "SP4"
    Device setup  using **5<number>      "SP5"
    Outgoing VoIP using **9<number>    "OBITALK"  (a.k.a. Obi-to-Obi)

    NOTES: If line selected is the GTALK line, then GTALK replaces SP?.
           If line selected is **9, then OBITALK replaces SP9.
           PSTN requires an OBiLINE device connected to an Obi200.
    
For incoming/outgoing PSTN calls, see the description for --linefx.
    
If **[0-9] is dialed on the keypad to select a line, 
the lineid becomes SP[0-9].

The number of SP lines are 1 to 4 plus 5 and 9, depending on the 
device. The default lineid for SP1 to SP4 can be changed only
in the obi2ncid.conf configuration file.  Google Talk is special
in that "GTALK" can be detected on which SP line is used for it.
The other voice providers must have their linesp[0-4] variable
set to their lineid.

SP9 has the reserved lineid of "OBITALK" and can not be changed.

In cases where the lineid cannot otherwise be determined,
the default lineid becomes OBIHAI.

=head2 IMPORTANT

This gateway does not work properly with a OBILINE add-on accessory
that connects to a phone line.

=head1 REQUIREMENTS

=over

=item Obihai VoIP Telephone Adapter: Obi100, Obi110, Obi200, Obi202?

http://www.obihai.com/

=item Google Voice or a SIP voice provider

(voip.ms, callcentric, others untested)

=item The NCID server

http://ncid.sourceforge.net/ncid/ncid.html

=back

perl 5.6 or higher,
perl(Config::Simple)

=head1 OPTIONS

=over 2

=item --configfile <filename>, -C <filename>

Specifies the configuration file to use.  The program will still run if
a configuration file is not found.

Default: /usr/local/etc/ncid/obi2ncid.conf

=item --debug, -D

Debug mode, displays all messages that go into the log file.
Use this option to run interactively.

=item --delay <seconds>, -d <seconds>

If the connection to the NCID server is lost,
try every <delay> seconds to reconnect.

Default: 30

=item --help, -h

Displays the help message and exits.

=item --linefx <string>, -f <string>

This option requires the OBiLINE FXO-to-USB Phone Line 
Adapter for the Obi2xx series. The Obi110 has it built in.

Normally "FXO" and "FXS" refer to line (telco) and phone (handset)
respectively. OBiLINE changes the meaning of these to be "FXO" for 
incoming calls and "FXS" for outgoing calls, so by default "FXO" and
"FXS" are used as the lineid and can not be changed.

However, if --linefx is given a value, it replaces both "FXO" and "FXS"
with that value.

For example:
    --linefx POTS
will cause the lineid for incoming and outgoing calls to be POTS.

Default: no default

=item --logfile-append <filename>, -l <filename>

=item --logfile-overwrite <filename>, -L <filename>

Specifies the logfile name to write.  The program will still run if
it does not have permission to write to it.

If both options are present, --logfile-append takes precedence.

Default: Append to /var/log/obi2ncid.log

=item --man, -m

Displays the manual page and exits.

=item --ncidhost=<[host][:port]>, -n <[host][:port]>

Specifies the NCID server.
Port may be specified by suffixing the hostname with :<port>.

Input must be <host> or <host:port>, or <:port>.

Default:  localhost:3333

=item --no-filter, -N

Useful for development and troubleshooting purposes.

A list of zero or more filter lines is stored in B<obi2ncid.conf>.

An Obihai device periodically sends out packets when it is doing
its own internal "housekeeping." Such packets do not have anything
to do with call activity, but they can clutter and confuse verbose
output because of their sheer volume and frequency.

However, in unusual circumstances it may be necessary to use the
--no-filter option to include all housekeeping packets.

Default: filtering is ON

=item --obiport <port>, -o <port>

Specifies the UDP port to listen on for Caller ID from an OBi device.

Default: 4335

=item --pidfile <filename>, -p <filename>

Specifies the pidfile name to write. The program will still run if
it does not have permission to write a pidfile. The pid filename that
should be used is /var/run/obi2ncid.pid.

Default: no pidfile

=item --rawfile-append <filename>, -r <filename>

=item --rawfile-overwrite <filename>, -R <filename>

Useful for development and troubleshooting purposes.

Writes packets to a file exactly as received from the gateway device.
A filename extension of .data is suggested. The rawfile can be
"played back" using B<test-obi-gw>.

Raw packets from Obihai devices do not have a date/time stamp.
When played back, the B<obi2ncid> gateway script will treat the
packets as arriving using the current date/time.

If both options are present, --rawfile-append takes precedence.

Default: no raw file

=item --test, -t

Test mode is a connection to the gateway device without a connection to
the NCID server. It sets debug mode and verbose = 3.  The verbose 
level can be changed on the command line.

Default: no test mode

=item --verbose <1-9>, -v <1-9>

Output information, used for the logfile and the debug option.  Set
the level to a higher number for more information.  Levels range from
1 to 9, but not all levels are used.

Default: verbose = 1

=item --version, -V

Displays the version and exits.

=back

=head1 EXAMPLES

=over 4

=item Start obi2ncid in test mode at verbose level 3

obi2ncid --test

=item Start obi2ncid in test mode at verbose level 5 and keep a test log

obi2ncid -t -v5 -L test.log

=item Start obi2ncid in test mode and keep a file of the input data

obi2ncid -t -R test.data

=item Start obi2ncid in debug mode at verbose level 1

obi2ncid -D

=back

=head1 FILES

/etc/ncid/obi2ncid.conf

=head1 SEE ALSO

ncidd.8,
ncidd.conf.5,
obi2ncid.conf.1
test-obi-gw (available in source distribution only)

=cut
