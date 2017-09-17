<!-- INSTALL-FreeBSD.md - Removable HEADER Start -->

Last edited: Aug 6, 2016

<!-- Removable HEADER End -->

## <a name="instl_free_top"></a>FreeBSD Install

> If NCID does not work, see [INSTALL](#instl_generic_top) for some simple tests.

> If using the email2ncid gateway, review [email2ncid setup](#gateways_email).  
  If using the ncid2ncid gateway, review [ncid2ncid setup](#gateways_n2n).  
  If using the obi2ncid gateway, review [obi2ncid setup](#gateways_obi).  
  If using the rn2ncid gateway, review [rn2ncid setup](#gateways_rn).  
  If using the sip2ncid gateway, review [sip2ncid setup](#gateways_sip).  
  If using the wc2ncid gateway, review [wc2ncid setup](#gateways_wc).  
  If using the yac2ncid geatway, review [yac2ncid setup](#gateways_yac).

> [Table of Contents](#doc_top)

### Sections:

> [COMPILE:](#instl_free_comp)  
  [INSTALL:](#instl_free_inst)  
  [CONFIGURE:](#instl_free_conf)  
  [STARTUP:](#instl_free_start)  
  [START/STOP/STATUS:](#instl_free_ss)  
  [AUTOSTART:](#instl_free_as)  
  [TRIMMING LOG FILES:](#instl_free_trim)  
  [GMAKE NOTE:](#instl_free_note)  

### <a name="instl_free_comp"></a>COMPILE:

> - See INSTALL.

### <a name="instl_free_inst"></a>INSTALL:

> - install tcl/tk from either **ports** or use the **pkg** command

>> - make sure tcl calls tcl?.? and wish calls wish?.?,
     otherwise modify the TCLSH and WISH variables in ncid

> - install logrotate from either **ports** or use the **pkg** command
    if you want to use the NCID rotation on the cidcall.log file

>> - edit /etc/logrotate.conf and add the line:

>>>> include /usr/local/logrotate.d

> - the NCID package installs in /usr/local

> #### Install or upgrade using the tar archive as root, if available:

>> Extracting the tar file will REPLACE the contents of all of
   the NCID configuration files. Be sure to back them up first, as
   root. This includes all files in /usr/local/etc/ncid/.

>
            Copy ncid-VERSION-freebsd.tgz to the FreeBSD computer
            tar -xzvf ncid-VERSION-freebsd.tar.gz -C /
            EXAMPLE: tar -xzvf ncid-1.2-freebsd.tar.gz -C /

>> You will need to manually compare your backed up configuration
    files with the new ones, and manually edit any differences.

> #### Install or upgrade using the install script as root, if available:

>> GNU getopt is required when using the install script. See
      [this note](#instl_free_note).

>> For an upgrade, the install script will preserve existing configurations, and
   new ones installed will have \*.new as the extension.

>
            Copy ncid-VERSION-freebsd_install.sh to the FreeBSD computer
            sh ncid-VERSION-freebsd_install.sh
            EXAMPLE: sh ncid-1.3-freebsd_install.sh

>> You will need to manually compare your current configuration
     files with the \*.new ones, and manually edit any differences.

> #### If there is no binary package, you need to compile the source.

>> Gmake is required when compiling the source. See
      [this note](#instl_free_note).

>>  Your existing configuration files will be preserved, and new ones
    installed will have \*.new as the extension.

>
            Copy ncid-VERSION-src.tar.gz to the FreeBSD computer  
            tar -xzvf ncid-VERSION-src.tar.gz  
            gmake freebsd (compiles for /usr/local, see top of Makefile)  
            gmake freebsd-install

### <a name="instl_free_conf"></a>CONFIGURE:

> The ncidd.conf file is used to configure ncidd.

> - The default modem port in ncidd is a USB modem at /dev/cuaU0.
    There may also be /dev/ttyACM0 in addition to /dev/cuaU0.

> - You should set the modem in ncidd.conf, if you need to change it.
     Use one of cuaa0, cuaa2, cuaa3, cuaa4 in /dev which
     corresponds to COM1, COM2, COM3, COM4

> - If you are using COM1 then you would add this line to ncidd.conf:  
>
          set modem = /dev/cuaa0

> - If you are using a gateway instead of a local modem,
    you need to set noserial to 1:  
>
          set noserial = 1

> - If you are using a local modem with or without a gateway:  
>
          set noserial = 0  (this is the default)

### <a name="instl_free_start"></a>STARTUP:

> - If you are running the server and client on the same computer
     and using a modem:  
>
          /usr/local/etc/rc.d/ncidd onestart  
          ncid &

> - If you are running the server and using a SIP gateway:  
>
          /usr/local/etc/rc.d/rc.d/ncidd onestart  
          /usr/local/etc/rc.d/rc.d/sip2ncid onestart  
          ncid &

> - If you are running the server and using a Whozz Calling gateway:  
>
          /usr/local/etc/rc.d/rc.d/ncidd onestart  
          /usr/local/etc/rc.d/rc.d/wc2ncid onestart  
          ncid &

> - If you are running the server and using a YAC gateway:  
>
          /usr/local/etc/rc.d/rc.d/ncidd onestart  
          /usr/local/etc/rc.d/rc.d/yac2ncid onestart  
          ncid &

> - Call yourself and see if it works, if not:
>
       + stop the gateway used:  
>
              /usr/local/etc/rc.d/rc.d/sip2ncid onestop
>
       + stop the server:  
>
              /usr/local/etc/rc.d/rc.d/ncidd onestop
>
       + and continue reading the test sections.

> - If everything is OK, enable the NCID server, gateways, and
    client modules you are using to autostart at boot.

> - NOTE:  

>> - The ncid client normally starts in the GUI mode and there is no
     ncid.rc script to start or stop it.

>> - There are rc.d scripts for starting ncid with output modules,
     for example: ncid-page, ncid-kpopup, etc.

### <a name="instl_free_ss"></a>START/STOP/STATUS:

>  - The /usr/local/etc/rc.d/ncid\* scripts to start any of the daemons.
   The rc.d commands are: start, stop, restart, reload, and status.  The
   client can also be started using the output module name instead of ncid.
   All output modules can be run at the same time.

>> Here are examples:
>>
        sudo /usr/local/etc/rc.d/ncidd start  
        sudo /usr/local/etc/rc.d/ncidd reload  
        sudo /usr/local/etc/rc.d/sip2ncid restart  
        sudo /usr/local/etc/rc.d/ncid-speak stop  
        sudo /usr/local/etc/rc.d/ncid-page status  
        sudo /usr/local/etc/rc.d/ncid-kpopup rcvar

> - If a service is not enabled, you must prefix 'one' to the commands;
  start becomes onestart, stop becomes onestop, and so forth.

### <a name="instl_free_as"></a>AUTOSTART:

> - If you want NCID services to start automatically at boot, you need to
    add an enable line /etc/rc.conf.local for each service you want started.
    If /etc/rc.conf.local does not exist, create it.

> - Here is the list of rc scripts and their enable lines:

                /usr/local/etc/rc.d/     /etc/rc.conf.local
                --------------------     ------------------
                ncidd                    ncidd_enable="YES"
                sip2ncid                 sip2ncid_enable="YES"
                yac2ncid                 yac2ncid_enable="YES"
                ncid-kpopup              ncidkpopup_enable="YES"
                ncid-notify              ncidnotify_enable="YES"
                ncid-page                ncidpage_enable="YES"
                ncid-samba               ncidsamba_enable="YES"
                ncid-skel                ncidskel_enable="YES"
                ncid-speak               ncidspeak_enable="YES"
                ncid-yac                 ncidyack_enable="YES"

### <a name="instl_free_trim"></a>TRIMMING LOG FILES:

> - FreeBSD uses newsyslog by default to trim files. To trim the
    cidcall.log and the ciddata.log files, add this entry to
    /etc/newsyslog.conf:  
>
          /var/log/cid*.log   root:wheel 644 5 * $M1D0 GN

### <a name="instl_free_note"></a>GMAKE NOTE:

> - The NCID source package requires gmake.

> - The NCID source package and, if available, the install script,
      require GNU getopt. It is installed from /usr/ports/devel/libgnugetopt:  
>
          cd /usr/ports/devel/gmake
          make all install
