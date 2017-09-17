<!-- Gateways.md - Removable HEADER Start -->

Last edited: Sep 30, 2016

<!-- Removable HEADER End -->

## <a name="gateways_top"></a>NCID Gateways

> [Table of Contents](#doc_top)

### Gateways Index

> [email2ncid setup](#gateways_email)  
  [ncid2ncid setup](#gateways_n2n)  
  [obi2ncid setup](#gateways_obi)  
  [rn2ncid setup](#gateways_rn)  
  [sip2ncid setup](#gateways_sip)  
  [wc2ncid setup](#gateways_wc)  
  [yac2ncid setup](#gateways_yac)  

<br>

### <a name="gateways_email"></a>email2ncid setup
> How to setup the email-to-NCID message gateway to convert an email into an NCID
> message and send it to the NCID server.  If the *notify* option is used, it
> will only send the email subject line to the NCID server.


> #### Sections:

>>  [REQUIREMENTS](#gateways_emailr)  
    [CONFIGURATION](#gateways_emailc)  
    [TESTING](#gateways_emailt)  
    [STEP-BY-STEP SETUP FOR RASPBERRY PI](#gateways_emailpi)

> #### <a name="gateways_emailr"></a>REQUIREMENTS:

> - A dynamic DNS service. Here are just a few examples:<p>
>> 
> Name       | Basic Service | Website
> -----------|---------------|--------
> ChangeIP   | free          | https://www.changeip.com/dns.php  
> DNSdymanic | free          | http://www.dnsdynamic.org/
> Dynu       | free          | https://www.dynu.com  
> DynDNS     | paid          | https://www.dyn.com  
    

> - A Mail Transport Agent (MTA):
>>  exim, postfix, sendmail, etc

> - procmail

> #### <a name="gateways_emailc"></a>CONFIGURATION:

> - firewall:  

>>>  Forward port 25 TCP/UDP to the computer running the MTA.

> - procmail:  

>>>  Run the following setup script to create or update $HOME/.procmailrc:  
   
>>>         ncid-setup email2ncid

>>>  The $HOME/.procmailrc file is configured to pipe to **email2ncid** when the
     subject line is **NCID Message**.  A commented out recipe will pipe to
     **email2ncid --notify** if the *From:* email address matches.  A second
     commented out recipe will forward the email if the *From:* email address matches.

> - MTA:  

>> - Accept mail for your dynamic DNS service host name.  
>> - Listen on all network interfaces, not just localhost.  
>> - Use mbox format.  
>> - Configure smarthost to your server provider email host if you want to send email.

> #### <a name="gateways_emailt"></a>TESTING:

> You can test if email2ncid is configured for the email server and can connect to it.
  The test line and result should be similar to:

>        $ echo test | email2ncid -t3
         > test
         test=3
         Configuration File: /etc/ncid/email2ncid.conf
         mesg=0 start=0 plain=0 html=0 multi=0 meta=0 status=0
         ncidserver: localhost:3334
             200 Server: ncidd (NCID) 1.5
             210 API: 1.3 Feature Set 1 2 3 4
             253 No Call log

> Next, send an email to yourself at the host name
 you picked for the Dynamic DNS service. The subject line must be: **NCID Message**

> If it does not work, save the email message.  You can retest it by:
>> cat saved_email_message | email2ncid -t1

> Review [email2ncid.1](http://ncid.sourceforge.net/man/email2ncid.1.html) for more information.

> #### <a name="gateways_emailpi"></a>STEP-BY-STEP SETUP FOR RASPBERRY PI:

> How to setup the **email2ncid** gateway on the Raspberry Pi for user **pi**.

> - First go to the free dynamic IP service at https://www.changeip.com/dns.php and register a host
    name at their domain.  For example: `foobar.freedynamicdns.us`

> - Configure your firewall to pass port 25 TCP and UDP to the Raspberry Pi IP address.  
    The Raspberry Pi must have a fixed IP address or a static DHCP lease.

> * Install programs (mutt is recommended for a mail reader):  
>>     sudo apt-get install procmail exim4 mutt

> * Configure exim4:  
>>     sudo dpkg-reconfigure exim4-config  

>> with the following settings:
 
>> Configuration Parameter | Select or Type In
>> :-----------------------| :------
>> Mail Server Configuration info screen| `Ok`
>> General type of mail configuration: | `mail sent by smarthost; received via SMTP or fetchmail`
>> System mail name: `raspberrypi` | Accept default
>> Mail Server Configuration info screen| `Ok`
>> IP-addresses to listen on for incoming SMTP connections: `127.0.0.1 ; ::1`  | Replace with `0.0.0.0`
>> Other destinations for which mail is accepted: `raspberrypi` | Add a semicolon and then your Internet host name: `raspberrypi;foobar.freedynamicdns.us`
>> Machines to relay mail for: | Leave blank
>> IP address or host name of the outgoing smarthost: | Change to blanks if no outgoing mail or enter your service provider outgoing smarthost
>> Hide local mail name in outgoing mail? | `No`
>> Mail Server Configuration info screen| `Ok`
>> Keep number of DNS-queries minimal (Dial-on-Demand)? | `No`
>> Delivery method for local mail: | `mbox format in /var/mail/`
>> Split configuration into small files? | `No`
>> Root and postmaster mail recipient: | Add user id, for Raspberry Pi it is usually `pi`

> * Start exim4:  
>>     sudo invoke-rc.d exim4 start

> * Enable exim4 at boot:  
>>     sudo update-rc.d exim4 defaults

> *  Run the following setup script to create or update $HOME/.procmailrc:  
>>     ncid-setup email2ncid

> * If the NCID server is **not** running on the Raspberry Pi, edit file
> *email2ncid.conf*, uncomment the line for variable NCIDSERVER, and set 
> it to the correct IP address (or hostname) and port. For example:
>>     NCIDSERVER=192.168.10.55:3333

> * Test with a 2 line mail message:
>>     mail pi@foobar.freedynamicdns.us
>>     Subject: NCID Message
>>     My first
>>     email message.

> * The resulting NCID message that is broadcast to all clients should be one 
> line: **My first email message.**

<br> 

### <a name="gateways_n2n"></a>ncid2ncid setup

> How to setup the ncid2ncid gateway to forward caller ID and
  messages from multiple NCID sending servers (four maximum) to a 
  single NCID receiving server.

> #### Sections:

>>  [REQUIREMENTS](#gateways_n2nr)  
    [CONFIGURATION](#gateways_n2nc)  
    [TESTING](#gateways_n2nt)  
    [START/STOP/RESTART/STATUS/AUTOSTART](#gateways_n2ns) 

> #### <a name="gateways_n2nr"></a>REQUIREMENTS: 

> One NCID receiving server and at least one NCID sending server.

> #### <a name="gateways_n2nc"></a>CONFIGURATION:

> - Receiving Server

>> The ncid2ncid process connects to a receiving server as a gateway, 
> that is, a device that is a source of caller ID and messages. Typically,
> ncid2ncid is running on the receiving server and for this reason the 
> default receiving server is 127.0.0.1:3333. This can be changed by using
> the *tohost* and *toport* variables in file **ncid2ncid.conf**, or by using
> the `-t|--tohost [host][:port]` arguments on the command line. 
> 
>> A receiving server is required.

> - Sending Servers

>> The ncid2ncid process connects to sending servers as if it is a
> client. You specify sending servers using the *fromhostX* and *fromportX*
> variables in file **ncid2ncid.conf**, where X is a digit 1-4. You can also
> configure the sending servers from the command line by using multiple 
> `-f|--fromhost [host][:port]` arguments. 
> 
>> Note the subtle difference: Only specify a digit 1-4 for variables in file
> **ncid2ncid.conf**; do not use them on the command line. 
> The following examples are equivalent:

>> **ncid2ncid.conf**:  
>> 
>>         set fromhost1 = 192.168.20.1  
>>         set fromport1 = 3334  
>>         set fromhost2 = 192.168.20.9:3335  

>> command line:
>> 
>>         ncid2ncid --fromhost 192.168.20.1:3334 --fromhost 192.168.20.9:3335
>> 
>> There are no default sending servers and at least one must be specified.

> - The default port for all sending/receiving servers is 3333.

> #### <a name="gateways_n2nt"></a>TESTING:

> Start **ncid2ncid** in debug mode at verbose level 3:

>         sudo ncid2ncid -Dv3

> Debug mode will give a reason if **ncid2ncid** dies and will show it
  processing data.

> If ncid2ncid does not work, you should have enough information to ask for help.

> #### <a name="gateways_n2ns"></a>START/STOP/RESTART/STATUS/AUTOSTART:

> Normally ncid2ncid is started using the provided init, service, rc, or
  plist script for your OS. For more information, refer to the
  [INSTALL](#instl_generic_top) section for your OS.  If no script is provided
  you need to start ncid2ncid manually:

>         sudo ncid2ncid

> If any options are needed, add them to **ncid2ncid.conf**.

<br>

### <a name="gateways_obi"></a>obi2ncid setup
> How to setup an Obihai device to send Caller ID and messages via the
  obi2ncid gateway.

> #### Sections:

>>  [REQUIREMENTS](#gateways_obir)  
    [DEVICE CONFIGURATION](#gateways_obi_dc)  
    [NCID CONFIGURATION](#gateways_obi_nc)  
    [TESTING](#gateways_obit)  
    [OUTPUT TESTING](#gateways_obio)  
    [START/STOP/RESTART/STATUS/AUTOSTART](#gateways_obis)  

> #### <a name="gateways_obir"></a>REQUIREMENTS:

> An [Obihai](http://www.obihai.com/) device is required. 
  Only the OBi100, OBi110, OBi200 with and without OBILINE, and OBi202 
  were available for development and testing. Other OBIHAI products may
  or may not work.
  
> It is possible to configure multiple OBi devices to work with
  NCID. Each device must have a unique port configured, and
  the [DEVICE CONFIGURATION](#gateways_obi_dc) and 
  [NCID CONFIGURATION](#gateways_obi_nc) must use the same port.
  Ports 4335 through 4339 are normally used.  Port 4339 is used
  by the **test-obi-gw** test script in the NCID source package.
  
> You must install your OBi device on your local network, create
  a free [OBiTALK account](http://www.obitalk.com/), and link your
  OBi to your account so that it appears on your OBiTALK Dashboard.
  Then you need to set up your voice service provider(s) (there are
  "wizards" that make it easy to set up the most common ones).
   
> Make sure you can successfully make and receive calls before
  continuing.
   
> #### <a name="gateways_obi_dc"></a>DEVICE CONFIGURATION:

> The OBi device needs to be configured for NCID use. You can do
  this using either the "Advanced Configuration" (a.k.a. "Expert")
  mode accessible through the OBiTALK dashboard, or by using a
  browser to login directly to the OBi device using its IP 
  address. The OBiTALK Dashboard is the simplest and easiest 
  method and is what will be used below.

> On the OBiTALK dashboard, find your OBi device and click on the
  dark gray gear icon with the red "E" (for "Expert" or Advanced
  Configuration).
    
> Navigate to **System Management->Device Admin**.  

>>  - Find the **Syslog** section.

>>  - Override the **Server** parameter by first UNCHECKING **OBiTALK
      Settings** and then immediately UNCHECK **Device Default**.

>>  - Under the **Value** column for **Server**, type in the NCID
      server hostname or IP address.
      
>>  - Override the **Port** parameter by first UNCHECKING **OBiTALK
      Settings** and then immediately UNCHECK **Device Default**.

>>  - Under the **Value** column for **Port**, change the default
      of **514** to **4335**.
      
>>  - Click on the **Submit** button to save the changes.

>>  - The page will be redisplayed. At the top you should see the
      message *Successfully saved OBi Expert config to OBiTALK*
      or something similar.

> Navigate to **Voice Service**.  

>>  - There will be a list that starts with "SP1 Service" and
      depending on the OBi model will go up to "SP4 Service." 
      For any and all of these Services that is *not* configured
      for GTALK (a.k.a. Google Voice), scroll to where you see
      the parameter name of **X_SipDebugOption** (it is usually
      a few lines above the start of the **SIP Credentials**
      section).
  
>>  - Override the **X_SipDebugOption** parameter by first 
      UNCHECKING **OBiTALK Settings** and then immediately UNCHECK
      **Device Default**. Under the **Value** column, change the
      default of **Disable** to **Log All Except REGISTER Messages**.
      
>>  - Click on the **Submit** button to save the changes.

>>  - The page will be redisplayed. At the top you should see the
      message *Successfully saved OBi Expert config to OBiTALK*
      or something similar.

> #### <a name="gateways_obi_nc"></a>NCID CONFIGURATION:


>   The ncidd server defaults to using a modem to get Caller ID.  If
    you have a standard telephone line (POTS) modem configured, you
    can keep the modem and also use the obi2ncid gateway.


>   If you do not use a modem and you are not using another gateway,
    you need to configure ncidd by uncommenting this line in
    **ncidd.conf**:

>          # set noserial = 1

> This tells ncidd to run without a serial device or modem connected.

> Once you change **ncidd.conf**, you must start/restart ncidd to
  read it.

> (Note: Do not confuse the *noserial* and *nomodem* settings.
  See [Note 1](#gateways_note1) for an explanation of the
  differences.)

> Normally obi2ncid does not need to be configured unless you
  set up the OBi device to use a syslog port other than 4335.

> #### <a name="gateways_obit"></a>TESTING:

> If this is the first time you set obi2ncid up, you should test
  obi2ncid without connecting it to ncidd.  For example, if using a obi200:

>          obi2ncid -t -L obi200.log

> The above command puts obi2ncid in test mode at verbose level 3.
  It will display verbose statements on the terminal, ending with
  "Listening at port 4335". Test mode prevents obi2ncid from
  connecting with ncidd.

> If obi2ncid terminates you should be able to see why and fix it.

> If you have a problem that requires debugging you should use
  verbose level 5 and create a data file. For example, if using a obi200:

>          obi2ncid -t -v5 -L obi200.log -R obi200.data

> You can get a detailed usage message by executing:

>          obi2ncid --help

> or print out the manual page by executing:

>          obi2ncid --man

> If it looks OK, terminate obi2ncid with **\<CTRL\>\<C\>**.
    
> Next, restart obi2ncid in debug mode so it will connect to ncidd:

>          obi2ncid -Dv3

> Make a call and you should see the **CALL** and **CALLINFO** lines
  that are sent to the server.  You should also see **CID** and
  **END** lines sent back from the server.  If there is a problem 
  an error message may be generated.

> #### <a name="gateways_obio"></a>OUTPUT TESTING:

> This is an advanced set of tests used when adding a new voice provider or device
  to the obi2ncid.  It is also after fixing a problem with a voice provider, to
  make sure the fix did not break anything.

> Suggested setup for easiest testing:

> - If testing both the OBi110 and OBi200, leave the OBi110 at
    port 4335 and change the OBi200 port to 4336.

> - It's best to test at verbose 3 in test mode to just see
    **CALL** and **CALLINFO** lines:  
    
>            perl obi2ncid.pl -t -L test.log -C obi2ncid.conf -o 4335

> - If there is a problem with a test or tests, change to v5,
    then after each test move the test.log and test.data files to another
    name so there is one test call per log.
    
>            perl obi2ncid.pl -t -L test.log -R test.data -C obi2ncid.conf -o 4335 -v5

> Complete testing of the OBi110 and OBi200 requires checking that the name,
  number, and line id are the same for the **CALL** and **CALLINFO** lines.  In addition
  **CALLINFO** should show **CANCEL** if there was no pickup or
  **BYE** if there was a pickup.

> To verify all is working correctly you need to test the following:

>            Incoming call:
                originating caller hangup before answer
                originating caller hangup after answer
                receiving caller hangup after answer

>            Outgoing call:
                originating caller hangup before answer
                originating caller hangup after answer
                receiving caller hangup after answer

> Additional tests for POTS calls. On the OBi110, connect the house Telco
  line to the OBi110 Telco Line connector. The OBi200 requires the *OBiLINE
  FXO to USB Phone Line Adapter*; connect the house Telco line to the OBiLINE.

>            Incoming Telco Line
                hangup with no answer
                hangup after house phone answers
                hangup after answer on the OBi device

>            Outgoing Telco Line
                hangup with no answer
                hangup after house phone answers
                hangup after answer on the OBi device

> #### <a name="gateways_obis"></a>START/STOP/RESTART/STATUS/AUTOSTART:

> Normally obi2ncid is started using the provided init, service, rc, or
  plist script for your OS. For more information, refer to the
  [INSTALL](#instl_generic_top) section for your OS.  If none is provided
  you need to start obi2ncid manually:

>         sudo obi2ncid &

> You can also set it up to start at boot, along with ncidd.  If any options
  are needed, add them to **obi2ncid.conf**.

> If obi2ncid does not work, you should have enough information to ask for help.

<br>

### <a name="gateways_rn"></a>rn2ncid setup
> How to setup Remote Notifier on an Android smart phone to
  send Caller ID and messages via the rn2ncid gateway.

> #### Sections:

>>  [REQUIREMENTS](#gateways_rnr)  
    [CONFIGURATION](#gateways_rnc)  
    [TESTING](#gateways_rnt)  
    [START/STOP/RESTART/STATUS/AUTOSTART](#gateways_rns)  

> #### <a name="gateways_rnr"></a>REQUIREMENTS:

>   The smart phone needs to be running [Remote Notifier for Android from
    Google Play](https://play.google.com/store/apps/details?name=org.damazio.notifier&hl=en).

>   Install it and configure it for the IP address of the computer running
    ncidd.

> #### <a name="gateways_rnc"></a>CONFIGURATION:

>   The ncidd server defaults to using a modem to get Caller ID.  If
    you have a standard telephone line (POTS) modem configured, you
    can keep the modem and use the rn2ncid gateway.


>   If you do not use a modem and you are not using another gateway,
    you need to configure ncidd by uncommenting this line in **ncidd.conf**:

>          # set noserial = 1

> This tells ncidd to run without a serial device or modem connected.

> Once you change **ncidd.conf**, you must start/restart ncidd to read it.

> (Note: Do not confuse the *noserial* and *nomodem* settings.
  See [Note 1](#gateways_note1) for an explanation of the differences.)

> Normally rn2ncid does not need to be configured unless you are using 
  ncid-page to send calls and messages to your smart phone. In that 
  case you need to edit the *reject* line at the end of **rn2ncid.conf** 
  and specify the "from" of SMS/MMS messages to be rejected and not passed
  through to the NCID server. (If you do not do this, the result will be an
  endless loop which could result in excessively high data or text charges
  by your cell phone carrier.) The setting for *reject* is usually of the
  form root@[hostname] where [hostname] is the result of executing the
  Unix `hostname` command on the computer running ncidd.

> For example:

>> **$** hostname  
   smurfzoo.private  
   **$**
   

> Edit **rn2ncid.conf**:

>          reject = root@smurfzoo.private

> #### <a name="gateways_rnt"></a>TESTING:

> If this is the first time you set rn2ncid up, you should test rn2ncid
  without connecting it to ncidd.

>          rn2ncid --test

> The above command puts rn2ncid in test and debug modes at verbose level 3.
  It will display verbose statements on the terminal, ending with
  "Listening at port 10600".  It should show configured options.
  Test mode prevents rn2ncid from connecting with ncidd.

> If rn2ncid terminates you should be able to see why and fix it.

> You can get a detailed usage message by executing:

>          rn2ncid --help

> or print out the manual page by executing:

>          rn2ncid --man

> On your smart phone, launch Remote Notifier and choose
  "Send test notification".  rn2ncid should show something like this:

>          NOT: PHONE 0123: PING Test notification

> (Note: 0123 is the phone ID and will be different for your phone.)

> If it looks OK, terminate rn2ncid with **\<CTRL\>\<C\>**.
    
> Next, restart rn2ncid in debug mode so it will connect to ncidd:

>          rn2ncid -Dv3

> Do the "Send test notification" again and it should be sent to the server
  and its clients.  If you do not get a "NOT" (short for "NOTIFY") message 
  sent to the server, you should instead get an error message saying what
  is wrong.

> If you had the PING "Test notification" sent to a client, setup is complete.

> #### <a name="gateways_rns"></a>START/STOP/RESTART/STATUS/AUTOSTART:

> Normally rn2ncid is started using the provided init, service, rc, or
  plist script for your OS. For more information, refer to the
  [INSTALL](#instl_generic_top) section for your OS.  If none is provided
  you need to start rn2ncid manually:

>          sudo rn2ncid &

> You can also set it up to start at boot, along with ncidd.  If any options
  are needed, add them to **rn2ncid.conf**.

> If rn2ncid does not work, you should have enough information to ask for help.

<br>

### <a name="gateways_sip"></a>sip2ncid setup

> How to setup VoIP Caller ID using sip2ncid.

> ### Sections:

>  [REQUIREMENTS](#gateways_sipr)  
   [CONFIGURATION](#gateways_sipc)  
   [TESTING](#gateways_sipt)  
   [START/STOP/RESTART/STATUS/AUTOSTART](#gateways_sips)  

> #### <a name="gateways_sipr"></a>REQUIREMENTS:

> VoIP telephone service using SIP.

> Configure your LAN for SIP.  
  See [ATA (Analog Terminal Adapter)](#devices_ata).

> #### <a name="gateways_sipc"></a>CONFIGURATION:

> The ncidd server defaults to a using a modem to get Caller ID.  if
  you have a standard telephone line (POTS) modem configured, and you
  have at least one VoIP telephone line, all you need to do is 
  start sip2ncid to get Caller ID from VoIP.  The server will handle
  a modem and the sip2ncid gateway easily.

> If you are only using VoIP and do not want to use a modem, you
  need to configure ncidd by uncommenting this line in **ncidd.conf**:

>          # set noserial = 1

> This tells ncidd to run without a serial device or modem connected.

> Once you change **ncidd.conf**, you must start/restart ncidd to read it.

> (Note: Do not confuse the *noserial* and *nomodem* settings.
  See [Note 1](#gateways_note1) for an explanation of the differences.)

> Use the sip2ncid `--listdevs` or `-l` option to see your network devices:

>          sudo sip2ncid --listdevs

> If you are using a DirecTiVo and the command does not return anything, you
  need to load the af_packet kernel module as described [here](http://www.tivocommunity.com/tivo-vb/showthread.php?p=5728255#post5728255):

>          insmod /lib/modules/af_packet.o  
          

> #### <a name="gateways_sipt"></a>TESTING:

> To determine if you can receive any network packets, use the `--testall`
  or `-T` option:

>          sudo sip2ncid --testall

> This will display a packet count and a packet type. It does not know
  all packet types so you may get some UNKNOWN packet types.  It also
  sets debug mode and verbose level 3. You can increase the verbose level
  to see more detail, but if you decrease it below 3, you will not
  see any packets.

> To determine if you can receive SIP data packets, use the `--testudp` or
  `-t` option:
  
>          sudo sip2ncid --testudp

> This will display SIP packets and what, if anything, it does.  It also
  sets debug mode and verbose level 3.  You can also change the verbose
  level.  If you set verbose to 1, sip2ncid will display lines sent to
  the server instead of the packet contents:
  
>          sudo sip2ncid -tv1

> If no packets are received in about 45 seconds:

>          No SIP packets at port XXXX in XX seconds

> If sip2ncid terminates you should be able to see why and fix it.

> You can get a detailed usage message by executing:

>          sip2ncid --help

> Sometimes it picks the wrong default interface. If you are using eth0:

>          sudo sip2ncid -ti eth0

> If you need to see what interfaces are present you can use the
  `--interface` or `-i` option: 

>          sudo sip2ncid --listdevs

> The display is:

>          <interface> : <description>

>  The interface name is everything up to the first space.

> If you do not see any SIP packets, change to port 5061 and try again:

>          sudo sip2ncid --testudp --sip :5061

> You should see something like:

>          Network Interface: eth0  
>          Filter: port 10000 and udp

> Then about every 20 seconds you should see something like:

>          Packet number 1:
>          Protocol: UDP  
>          SIP/2.0 200 OK  
>          Via: SIP/2.0/UDP 70.119.157.214:10000;branch=z9hG4bK-22b185d1  
>          From: 321-555-7722 <sip:13215551212@atlas2.atlas.vonage.net:10000>;tag=46f26356c0a3394bo0  
>          To: 321-555-7722 <sip:13215551212@atlas2.atlas.vonage.net:10000>  
>          Call-ID: fa72d1c2-ead1bdcf@70.119.157.214  
>          CSeq: 86785 REGISTER  
>          Contact: 321-555-1212 <sip:13215551212@70.119.157.214:10000>;expires=20  
>          Content-Length: 0
>
>          Registered Line Number: 13215551212

> The Registered Line Number line will only appear in packet number 1.

> If you do not get the above, you may need to specify an address and/or port
  for sip2ncid to listen for the SIP Invite.  You cannot continue unless you
  get the above.

> If you are using the Linksys RT31P2 Router, you will not see any packets
  unless the computer is in its DMZ (Demilitarized Zone).  Port forwarding 
  the UDP port will not work.  You must set up the DMZ.  If you are using a 
  different VoIP router, try to put the computer in the DMZ and see if that 
  works.  If not, view the SIP tutorial:

> [Configure your home network for SIP-based Caller ID](http://www.files.davidlaporte.org/sipcallerid.html).

> Once you receive the above packets, call yourself.  If you do not get a
  Caller ID message sent to ncidd, you should get an error message saying
  what is wrong.  This has been tested with Vonage and may need tweaking
  for other VoIP service providers.

> If you had Caller ID sent to a client, setup is complete.  You can then
  restart sip2ncid without the test option so it will not display anything.
  You can also set it up to start at boot, along with ncidd.  If any options
  are needed at boot, add them to **sip2ncid.conf**.

> #### <a name="gateways_sips"></a>START/STOP/RESTART/STATUS/AUTOSTART:

> Normally sip2ncid is started using the provided init, service, rc, or
  plist script for your OS. For more information, refer to the 
  [INSTALL](#instl_generic_top) section for your OS.  If none is provided 
  you need to start sip2ncid manually:

>          sudo sip2ncid &

> You can also set it up to start at boot, along with ncidd.  If any options
  are needed, add them to **sip2ncid.conf**.

> If sip2ncid does not work, you should have enough information to ask for help.

<br>

### <a name="gateways_wc"></a>wc2ncid setup

> How to setup one or more Whozz Calling Ethernet Link (WC) devices for
 Caller ID using wc2ncid.

> #### Sections:

>>  [REQUIREMENTS](#gateways_wcr)  
    [CONFIGURATION](#gateways_wcc)  
    [TESTING](#gateways_wct)  
    [START/STOP/RESTART/STATUS/AUTOSTART](#gateways_wcs)  

> #### <a name="gateways_wcr"></a>REQUIREMENTS:

> A Whozz Calling Ethernet Link (WC) device (see: http://callerid.com)
  connects to POTS (Plain Old Telephone System) lines and can handle
  2, 4, or 8 lines.  Some models only handle incoming calls while
  others handle incoming and outgoing calls.

> The Whozz Calling user manual tells how to hook up the device.
  You plug your POTS telephone lines into the device and you connect
  the device to your local network.

> #### <a name="gateways_wcc"></a>CONFIGURATION:

> All WC devices must have an IP address within your network in order
  for them to be configured for use by wc2ncid.  This limitation will
  be removed in a future release.  When you try to configure a device
  with an address outside your network, wc2ncid will either give a warning
  or an error message and terminate.  You can then use the wct script to
  change the IP address to one that is in your network.  Use the discover
  option of wct to locate the device:

>          wct --discover

> The ncidd server defaults to using a modem to get Caller ID.  If
  you have a standard telephone line (POTS) modem configured, you
  can keep the modem and use the WC device to handle additional
  POTS or VoIP lines, or you can replace the modem with the WC device.

> It is recommended that you *not* use a modem so you need to configure ncidd
  by uncommenting this line in **ncidd.conf**:

>          # set noserial = 1

> This tells ncidd to run without a serial device or modem connected.

> Once you change **ncidd.conf**, you must start/restart ncidd to read it.

> (Note: Do not confuse the *noserial* and *nomodem* settings.
  See [Note 1](#gateways_note1) for an explanation of the differences.)

> Next, edit **wc2ncid.conf** to configure one or more devices. Look for this
  line:
  
>          wcaddr = 192.168.0.90

>   If your network is on 192.168.0 and the above address is not used,
    you can leave it.  If your network is on 192.168.1 you can set the
    IP address for WC device number 1 (WC-1), for example, by changing the
    line to be:

>          wcaddr = 192.168.1.90

>   If you have 2 devices and want to use addresses 192.168.2.90 and
    192.168.2.91, WC device 1 is 192.168.2.90 and WC device 2 is
    192.168.2.91.

>          wcaddr = 192.168.2.90, 192.168.2.91

> #### <a name="gateways_wct"></a>TESTING:

> Once you set the IP address for the WC device in **wc2ncid.conf**, start
  wc2ncid and tell it to configure the WC device:

>          wc2ncid [--test] --set-wc

> The `--test` parameter is optional, but it is a good idea to use it so
  wc2ncid does not connect to the NCID server during the configuration
  process.

> If you have 2 or more WC devices, and they are both set to the same
  address or the factory default of 192.168.0.90, you need to change
  both addresses in **wc2ncid.conf**. For example:

>          wcaddr = 192.168.0.91, 192.168.0.92

> Turn on one device and execute:

>          wc2ncid [--test] --set-wc

> Terminate wc2ncid with **\<CTRL\>\<C\>**. Leave the first device turned on, then
  turn on the second device and execute:

>          wc2ncid [--test] --set-wc

> Both devices should be configured and operational.  Terminate wc2ncid
  with **\<CTRL\>\<C\>**.

> If this is the first time you set wc2ncid up, you should test wc2ncid
  without connecting it to the ncidd server:

>          wc2ncid --test

> The above command puts wc2ncid in test and debug modes at verbose level 3.
  It will display verbose statements on the terminal, ending with "Waiting
  for calls".  It should show the configured address for each device.
  Test mode prevents wc2ncid from connecting with ncidd.

> If wc2ncid terminates you should be able to see why and fix it.

> You can get a detailed usage message by executing:

>          wc2ncid --help

> or print out the manual page by executing:

>          wc2ncid --man

> Call yourself.  You should see more verbose messages as the call is
  processed.  If it looks OK, terminate wc2ncid with **\<CTRL\>\<C\>**.

> Next, restart wc2ncid in debug mode so it will connect to ncidd:

>          wc2ncid -Dv3

> Call yourself.  If you do not get a Caller ID message sent to ncidd,
  you should get an error message saying what is wrong.

> If you had Caller ID sent to a client, setup is complete.

> #### <a name="gateways_wcs"></a>START/STOP/RESTART/STATUS/AUTOSTART:

> Normally wc2ncid is started using the provided init, service, rc, or
  plist script for your OS. For more information, refer to the 
  [INSTALL](#instl_generic_top) section for your OS.  If none is provided
  you need to start wc2ncid manually:

>          sudo wc2ncid &

> You can also set it up to start at boot, along with ncidd.  If any options
  are needed, add them to **wc2ncid.conf**.

> If wc2ncid does not work, you should have enough information to ask for help.

<br>

### <a name="gateways_yac"></a>yac2ncid setup

> How to setup a YAC modem server for Caller ID using yac2ncid.

> #### Sections:

>>  [REQUIREMENTS](#gateways_yacr)  
    [CONFIGURATION](#gateways_yacc)  
    [TESTING](#gateways_yact)  
    [START/STOP/RESTART/STATUS/AUTOSTART](#gateways_yacs)  

> #### <a name="gateways_yacr"></a>REQUIREMENTS:

> A YAC server on a Windows computer running Microsoft Windows 98 or later.

> The YAC server has not been updated since approximately 2002. You
  can try to download it from the original 
  [YAC homepage](http://www.sunflowerhead.com/software/yac/), from a saved site
  copy at the 
  [Internet Archive's Wayback Machine](http://web.archive.org/web/20141029025318/http://sunflowerhead.com/software/yac/), 
  or from any of several global download sites such as
  http://yac.software.informer.com/. Follow the installation
  instructions.

> #### <a name="gateways_yacc"></a>CONFIGURATION:

>  Configure the YAC server by giving it the IP address where ncidd is running. 
   Do this by right-clicking the YAC icon in the System Tray, and then select 
   "Listeners...".

>  To configure NCID, uncomment this line in **ncidd.conf**:

>          # set noserial = 1

> This tells ncidd to run without a serial device or modem connected.

> Once you change **ncidd.conf**, you must start/restart ncidd to read it.

> (Note: Do not confuse the *noserial* and *nomodem* settings.
  See [Note 1](#gateways_note1) for an explanation of the differences.)

> Normally yac2ncid does not need to be configured, but
  you should review **yac2ncid.conf** to see if you want to change 
  any of its defaults.

> After modifying **ncidd.conf** and **yac2ncid.conf**, you must
  start/restart ncidd first and then the yac2ncid gateway.

> #### <a name="gateways_yact"></a>TESTING:

> Make sure the YAC server is running on the Windows computer.

> Run the yac2ncid gateway with the verbose option:

>          yac2ncid -v

> Call yourself. If you do not get a Caller ID message sent to ncidd,
  you should get an error message saying what is wrong.

> If you had Caller ID sent to a client, setup is complete. You can 
  then restart yac2ncid without the verbose option so it will not 
  display anything. You can also set it up to start at boot, along
  with ncidd.

> #### <a name="gateways_yacs"></a>START/STOP/RESTART/STATUS/AUTOSTART:

> Normally yac2ncid is started using the provided init, service, rc, or
  plist script for your OS. For more information, refer to the 
  [INSTALL](#instl_generic_top) section for your OS.  If none is provided 
  you need to start yac2ncid manually:

>          sudo yac2ncid &

> You can also set it up to start at boot, along with ncidd.  If any options
  are needed, add them to **yac2ncid.conf**.

> If yac2ncid does not work, you should have enough information to ask for help.

<br>

### <a name="gateways_note1"></a>Note 1:

>In **ncidd.conf** there is an important difference between
the settings *noserial* and *nomodem*:

> - You would use *noserial* when you have no serial device connected at all.
> - You would use *nomodem* if you <u>do</u> have a serial device connected
    that is not a modem.
> - A list of *nomodem* serial devices working with NCID can be found in the
    [Devices Supported](#devices_top) section.
