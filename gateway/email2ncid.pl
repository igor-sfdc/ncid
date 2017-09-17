#!/usr/bin/perl

# email2ncid - email to NCID gateway

# Requires: procmail

# The email2ncid script is called by procmail when an NCID email
# is received.  It is not a daemon like the other gateways.

# If an email subject line is "NCID Message", the email is converted
# into an NCID message (MSG:) and sent to the server.

# Copyright (c) 2016
#  by John L. Chmielewski <jlc@users.sourceforge.net>

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
use Getopt::Long qw(:config no_ignore_case_always);
use File::Basename;
use Config::Simple;
use Pod::Usage;
use IO::Socket::INET;

my $prog = basename($0);
my $confile = basename($0, '.pl');
my $VERSION = "(NCID) XxXxX";

my $IDENT = "HELLO: IDENT: gateway $prog $VERSION";
my $COMMAND = "HELLO: CMD: no_log";

my $ConfigDir = "/usr/local/etc/ncid";
my $ConfigFile = "$ConfigDir/$confile.conf";

my ($help, $man, $version);

my ($ncidaddr, $ncidport) = ("localhost", 3333);
my $NCIDserver = undef;
my $lineid = "NETWORK";
my $lineID = undef;
my %config;
my ($ncidsock, $ncidserver, $tmp, $test, $cfg);
my ($subj, $start, $plain, $html, $multi, $meta, $status, $notify);
my ($from, $addr, $boundary, $message);

$test = $subj = $start = $plain = $html = $multi = $meta = $status = 0;
$notify = 0;
$ncidserver = $boundary = $message = $from = $addr = "";

Getopt::Long::Configure ("bundling");
my ($result) = GetOptions("ncidserver|n=s" => \$NCIDserver,
               "configfile|C=s" => \$ConfigFile,
               "help|h" => \$help,
               "notify|N" => \$notify,
               "man|m" => \$man,
               "version|V" => \$version,
               "test|t=i" => \$test,
             ) || pod2usage(2);
die "$prog $VERSION\n" if $version;
pod2usage(-verbose => 1, -exitval => 0) if $help;
pod2usage(-verbose => 2, -exitval => 0) if $man;

# reading configuration file after command line processing
# is necessary because the command line can change the
# location of the configuration file
$cfg = new Config::Simple($ConfigFile);
if (defined $cfg) {
# opened config file
    %config = $cfg->vars();
    $ncidserver = $config{'default.ncidserver'};
    $lineID = $config{'default.lineid'};
}

# these must always have a value
$lineid = $lineID if $lineID;

# these command line values override the configuration file values
$ncidserver = $NCIDserver if $NCIDserver;

if ($ncidserver) {
    ($tmp) = $ncidserver =~ /([^:]*)/;
    $ncidaddr = $tmp if $tmp;
    ($tmp) = $ncidserver =~ /.*:(.*)/;
    $ncidport = $tmp if $tmp;
}

while (<STDIN>) {
    if ($test >= 3) { printf "> $_"; }
    if (/^Subject: /) {
        if (/^Subject: +NCID +Message/) {
            $subj = 1;
        } elsif ($notify) {
            chop;
            ($message) = /^Subject:(.*)/;
            last if $from;
        }
        next;
    }
    if (/^From: /) {
        ($from) = /^From: "?([^"]*?) </;
        ($addr) = / <([^>]*)/;
        next;
    }
    if (/^Content-Type: +text\/plain/) {
        $plain = 1;
        next;
    }
    if (/^Content-Type: +text\/html/) {
        $html = 1;
        next;
    }
    if (/^Content-Type: +multipart\/alternative/) {
        $multi = 1;
    }
    if (/<meta http-equiv=/) {
        $meta = 1;
        next;
    }
    if (/^Status: RO/) {
        $status = 1;
        next;
    }
    if ($subj == 1) {
        # get the boundary characters
        if (/boundary/)
        {
            ($boundary) = /boundary="?([^"\n]*)/;
            next;
        }
        if (/^\s*$/) {
            if ($html== 1 || $multi == 1 || $meta == 1) { $status = 0; }
            # if content plain and status were not found, skip line
            if ($plain == 0 && $status == 0) { next; }
            # first blank line indicates start of text
            if ($start == 0) { $start = 1; }
            next;
        }
        if ($start == 1) {
            chop;
            # boundary may be at end of message
            if ($boundary && $_ =~ $boundary) { last; }
            # combine text lines into one message line
            $message = "$message $_";
            next;
        }
    }
}
if ($test >= 1) {
    print "test=$test\n";
    print "Configuration File: $ConfigFile\n";
    print("subj=$subj start=$start plain=$plain html=$html multi=$multi meta=$meta status=$status\n");
    print "ncidserver: $ncidaddr:$ncidport\n";
}

if (!$test || $test >= 2) { &connectNCID; }
if ($message) {
    $message = "MSG:$message ###NAME*$from*NMBR*$addr*LINE*$lineid*MTYPE*EMAIL";
    if ($test >= 1) {
        print("from=$from  addr=$addr boundary=$boundary\n");
        print "$message\n";
    }
    else { print($ncidsock "$message\r\n"); }
}
close($ncidsock) if $ncidsock;

sub connectNCID {
  my $api = "";
  my $ignore;

  $ncidsock = IO::Socket::INET->new(
    Proto    => "tcp",
    PeerAddr => $ncidaddr,
    PeerPort => $ncidport,
  );

  # $ncidsock undefined if could not connect to server
  if (!$ncidsock) {
    print("NCID server: $ncidaddr:$ncidport $!");
    exit 1;
  }

  # send ident to server
  print $ncidsock "$IDENT\n";

  # make sure call log not sent
  print $ncidsock "$COMMAND\n";

  if ($test >= 1) {
    print "    Sent: $IDENT\n";
    print "    Sent: $COMMAND\n";
  }

  my $greeting = <$ncidsock>;

  # read and discard cidcall log sent from server
  while (<$ncidsock>)
  {
    # a log file may or may not be sent
    # but a 300 message is always sent
    $api = $_ if /^210/;
    last if /^300/;
    $ignore = $_;
  };
  if ($test >= 2) {
    print("    $greeting");
    print("    $api") if $api;
    print("    $ignore"); # 300 message
  }
}

=head1 NAME

email2ncid - convert an email to an NCID message

=head1 SYNOPSIS

 email2ncid [--configfile|-C <filename>]
            [--help|-h]
            [--man|-m]
            [--notify|-N]
            [--ncidserver|-n <[host][:port]>]
            [--test|-t <1-9>]
            [--version|-V]

=head1 DESCRIPTION

The email2ncid gateway sends the contents of an email to the NCID
server as one line.  It is called from a .procmailrc file when
an email contains the line: Subject: NCID Message

The email2ncid gateway has an option to only send an email subject
line to the NCID server.  It is called from a .procmailrc file when
the email address or name matches on the email "From:" line.

The email must be in either plain text, or HTML and plain text.
The output of email2ncid is a one line NCID message sent to
an NCID server.

=head1 OPTIONS

=over

=item -C, --configfile <filename>

Specifies the configuration file to use.  The program will still run if
a configuration file is not found.

=item -h, --help

Displays the help message and exits.

=item -m, --man

Displays the manual page and exits.

=item -N, --notify

This option sends a message to NCID containing only the subject line
instead of the email contents as one line.  It is a notification of
some type:

    * visitor arrived at a gate in a gated community
    * an important email arrived

=item -n <[host][:port]>, --ncidserver=<[host][:port]>

Specifies the NCID server.
Port may be specified by suffixing the hostname with :<port>.

Input must be <host:port> or <host>, or <:host>

=item -t, --test <1-9>

Test mode connects to the server and displays some information
and the message.  It does not send the message to the server.
Set the level to a higher number for more information.
Levels range from 1 to 9, but not all levels are used.

    test = 1: show some variables and generated message
    test = 2: additionally show 2 or 3 lines returned by server
    test = 3: additionally show tne email message

Default: no test mode

=item -V, --version

Displays the version.

=back

=head1 REQUIREMENTS

=over

=item The NCID server

http://ncid.sourceforge.net/ncid/ncid.html

=item A dynamic DNS service:

ChangeIP (https://www.changeip.com/dns.php)

Dynu     (https://www.dynu.com)

DynDNS   (https://www.dyn.com)

=item A Mail Transport Agent (MTA):

exim, postfix, sendmail, etc.

=item firewall:

Forward port 25 TCP/UDP to the computer running the MTA

=item procmail:

$HOME/.procmailrc must be created or updated to call email2ncid.

Execute the following command to automate this process:

=over

ncid-setup procmailrc

=back

=item Perl

perl 5.6 or higher,
perl(Config::Simple)

=back

=head1 FILES

/etc/ncid/email2ncid.conf

$HOME/.procmailrc

=head1 SEE ALSO

ncidd.8,
email2ncid.conf.5,
procmail.1
