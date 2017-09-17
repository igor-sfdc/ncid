<!-- INSTALL-Cygwin.md - Removable HEADER Start -->

Last edited: Aug 6, 2016 

<!-- Removable HEADER End -->

## <a name="instl_cygwin_top"></a>Cygwin Package Install

> If NCID does not work, see [INSTALL](#instl_generic_top) for some simple tests.

> If using the email2ncid gateway, review [email2ncid setup](#gateways_email).  
  If using the ncid2ncid gateway, review [ncid2ncid setup](#gateways_n2n).  
  If using the obi2ncid gateway, review [obi2ncid setup](#gateways_obi).  
  If using the rn2ncid gateway, review [rn2ncid setup](#gateways_rn).  
  If using the sip2ncid gateway, review [sip2ncid setup](#gateways_sip).
  If using the wc2ncid gateway, review [wc2ncid setup](#gateways_wc).  
 If using the yac2ncid gateway, review [yac2ncid setup](#gateways_yac).

> [Table of Contents](#doc_top)


### Sections:
> [NOTES](#instl_cygwin_note)  
  [INSTALL](#instl_cygwin_inst)  
  [CONFIGURE](#instl_cygwin_conf)  
  [START](#instl_cygwin_st)  
  [REBASE](#instl_cygwin_reb)  
  [RUN AS A QUASI-SERVICE](#instl_cygwin_run)  

### <a name="instl_cygwin_note"></a>NOTES:

> The server does not function directly controlling a modem.

> The server must be configured for either:

> - **nomodem**, if using a serial Caller ID device
> - **noserial**, if using a obi2ncid, sip2ncid, yac2ncid, or wc2ncid gateway.

> The supplied yac2ncid gateway requires [YAC](http://sunflowerhead.com/software/yac/)
  to control a modem under Windows
    
> The supplied sip2ncid gateway requires
  [WinPcap](http://www.winpcap.org/) and
  [WpdPack](http://www.winpcap.org/devel.htm)

> The last test was using WinPcap_4_1_3.exe and WpdPack_4_1_2.zip

> The ncid client GUI mode requires X-windows so it can only be used in
  command line mode.  You should install and use the windows version of ncid.
  However, the windows version does not support output modules so if you
  need an output module, you can use the Cygwin version of ncid:

            ncid --no-gui <module> &

### <a name="instl_cygwin_inst"></a>INSTALL:

> #### Install WinPcap from windows if using the **sip2ncid** gateway:

> - download latest WinPcap installer from http://www.winpcap.org/
> - run the WinPcap installer and allow to start on boot

> - if compiling ncid from source you also need to:

>> - download the latest [WpdPack](http://www.winpcap.org/devel.htm) zip file
>> - unzip the WpdPack zip file to create the WpdPack directory

> #### Install Cygwin from http://cygwin.com/

> - download setup-x86.exe into a empty folder
> - run setup-x86.exe
> - select cygwin download site (we used US site http://cygwin.mirror.constart.com)
> - add the following to the default install setup

>> - Devel/gcc-core
>> - Devel gcc-g++
>> - Devel/make
>> - Editors/vim
>> - Interpreters/perl_pods
>> - Interpreters/tcl
>> - Net/openssh

> - move the WpdPack directory to \, if compiling ncid from source:

> - It is strongly recommended you enable cut and paste in the Cygwin window.

>> - Left click on the icon in upper left
>> - Select Properties
>> - Check Mark the QuickEdit Mode in Edit Options
    
> #### Install or upgrade NCID:

>> The NCID package normally installs in /usr/local:

>> - Install or upgrade using the tar archive, if available:

>>> Extracting the tar file will REPLACE the contents of all of
   the NCID configuration files. Be sure to back them up first.
   This includes all files in /usr/local/etc/ncid/.

>>
            Copy ncid-VERSION-cygwin.tgz to cygwin
            sudo tar -xzvf ncid-VERSION-cygwin.tgz -C /
            EXAMPLE: sudo tar -xzvf ncid-1.2-cygwin.tgz -C /

>> - Install or upgrade using the install script, if available.

>>> For an upgrade, the install script will preserve existing configurations, and
   new ones installed will have *.new as the extension.
>>
            Copy ncid-VERSION-cygwin_install.sh to cygwin
            sudo sh ncid-VERSION-cygwin_install.sh
            EXAMPLE: sudo sh ncid-1.3-cygwin_install.sh
 
>> - If there is no binary package, you need to compile the source
    (usually not required):
>>
            Copy ncid-VERSION-src.tar.gz to cygwin, then:
            tar -xzvf ncid-VERSION-src.tar.gz
            cd ncid
            make cygwin  (compiles for /usr/local, see top of Makefile)
            sudo make cygwin-install

> #### If your phone system is VoIP and you want to use sip2ncid:

> - nothing else to do

> #### If you want to use your modem, you need YAC

> - download and install [YAC](http://sunflowerhead.com/software/yac/)
> - configure the YAC server for a listener at localhost (127.0.0.1)

### <a name="instl_cygwin_conf"></a>CONFIGURE:

> The Makefile configures ncidd.conf for the Cygwin, but you may
   want to change some of the defaults.

> You need to configure sip2ncid to use the Network Interface.
   To find out the network interface name, you need to use the "-l"
   option to sip2ncid.  You should see your Network interface names
   listed.  Select the active one and use it with the "-i" option to
   sip2ncid.

### <a name="instl_cygwin_st"></a>START:

> If this is your first time, you should do
  the [Test Using `sip2ncid`](#instl_generic_sip)
  and [Test Using `yac2ncid`](#instl_generic_yac) procedures in
  the [INSTALL (generic)](#instl_generic_top) section first.

> start the server and clients:

> - ncidd

> If using [obi2ncid](#gateways_obi)

> - obi2ncid &

> If using [sip2ncid](#gateways_sip)

> - sip2ncid -l (list NETWORK_INTERFACES)  
    (Note: the interface list is < INTERFACE : DESCRIPTION >)
  - sip2ncid -i NETWORK_INTERFACE

> If using [wc2ncid](#gateways_wc):

> - wc2ncid &

> If using [yac2ncid](#gateways_yac)

> - yac2ncid &

> If using ncid for the first start test:

> - ncid --no-gui &

> Call yourself and see if it works.

### <a name="instl_cygwin_reb"></a>REBASE:

> One of the idiosyncrasies of Cygwin is the need to rebase the dll's
  (set a base dll load address) so they don't conflict and create
  forking errors. The easiest way to do this is documented at
  [Rebaseall](http://cygwin.wikia.com/wiki/Rebaseall)
	  
> Just start an ash or dash prompt from \cygwin\bin, and then type:  

>> rebaseall -v  
   exit
		
### <a name="instl_cygwin_run"></a>RUN AS A QUASI-SERVICE:

> - Don't do this process until you have ncidd and sip2ncid or other processes
    running properly. Once you have things setup though, you can set ncidd and
    sip2ncid to (sort of) run as a service in Windows. I only say "sort of"
    because it's not technically a service, but is called from another
    Cygwin component that is a service.
	  
> - Re-run the setup.exe that you used to install Cygwin, and install the
    cygrunsrv package. It's under Admin.

> - Go to a cygwin command line, and type the following to install ncidd as a
    service:
>
          cygrunsrv -I ncidd -n -p /usr/local/bin/ncidd
                    -f "Network CallerID daemon(ncidd)" -a -D
		 
>> Explaining these parameters:
>>
          -I indicates install  
          -n indicates that the service never exits by itself (I don't
             recall why this has to be set, but it doesn't work otherwise)
          -p /usr/local/bin/ncidd:
             Application path which is run as a service.
          -f "Network CallerID daemon (ncidd)":
             Optional string which contains  the service description
             (the desc you see in the Services listing)
          -a -D: passes the parameter "-D" to the ncidd program so it
                 runs in debug mode. This keeps ncidd running in the
                 "foreground" of the  cygrunsrv process.
		 
> - Likewise, to remove the ncidd service: cygrunsrv -R ncidd
		
> - To install sip2ncid to run in the background, the command line is similar:
>
          cygrunsrv -I sip2ncid -n -p /usr/local/bin/sip2ncid -y ncidd \  
                    -a '-i "/Device/NPF_{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}" \
                    -D' -f "Service to pick SIP packets from network and send to ncidd" \  
                    --termsig KILL
		
>> Explaining these parameters:
>>
		  -I indicates install
		  -n indicates that the service never exits by itself (I don't
             recall why this has to be set, but it doesn't work otherwise)
		  -p /usr/local/bin/sip2ncid: Application path which is run as
             a service.
		  -y ncidd: adds a service dependency with the ncidd service so
             that the ncidd service gets started automatically when you
             start sip2ncid
		  -a '-i "/Device/NPF_{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}" -D':
			     note the single and double quotes in this section. You need to
			     replace XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX in the above
			     with NETWORK_INTERFACE from way above. To be clear, you want to
			     replace /Device/NPF_{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
			     with NETWORK_INTERFACE from way above.
		  -f "Service to pick SIP packets from network and send to ncidd":
		     Optional string which contains the service description
			 (the desc you see in the Services listing)
		  --termsig KILL: termination signal to send. If you don't include
		                  this the service doesn't always get stopped.

> - Likewise, to remove the sip2ncid service:
>
          cygrunsrv -R sip2ncid

> - To install ncid-notify to run in the background, the command
	  line is similar:
>
          cygrunsrv -I ncid-notify -p /bin/sh.exe -a \
		            '-c "/usr/local/bin/ncid --no-gui --message --program ncid-notify"' \
		            -f "Service to use notify service to send ncid messages to iPad"
		
>> Explaining these parameters:
>>
          -I indicates install
          -p /bin/sh.exe: Application path to run, which in this case is 
             just sh.exe because ncid-notify is a shell script            
          -a '-c "/usr/local/bin/ncid --no-gui  --program ncid-notify"'
                 these are the parameters that get sent to sh.exe:
          -c "/usr/local/bin/ncid: this is the path to the ncid script
          --no-gui: tells ncid not to have a gui
          --program ncid-notify: tells ncid to pass data to "ncid-notify"
          -f "Service to use notify service to send ncid messages to iPad":

>> Optional string which contains the service description
   (the desc you see in the Services listing)
>
          -y ncidd: you COULD also add this line to add a service dependency
                    with the ncidd service so that the ncidd service gets started
                    automatically when you start ncid-notify. I don't do this,
                    because strictly speaking, you could be running ncidd on a
                    different computer.
			 
> - Likewise, to remove the ncid-notify service:
>
          cygrunsrv -R ncid-notify
