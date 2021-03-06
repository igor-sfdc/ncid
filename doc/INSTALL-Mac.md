<!-- INSTALL-Mac.md - Removable HEADER Start -->

Last edited: Aug 6, 2016

<!-- Removable HEADER End -->

## <a name="instl_mac_top"></a>Macintosh Install

> If NCID does not work, see [INSTALL](#instl_generic_top) for some simple tests.

> If using the email2ncid gateway, review [email2ncid setup](#gateways_email).  
  If using the ncid2ncid gateway, review [ncid2ncid setup](#gateways_n2n).  
  If using the obi2ncid gateway, review [obi2ncid setup](#gateways_obi).  
  If using the rn2ncid gateway, review [rn2ncid setup](#gateways_rn).  
  If using the sip2ncid gateway, review [sip2ncid setup](#gateways_sip).  
  If using the wc2ncid gateway, review [wc2ncid setup](#gateways_wc).  
  If using the yac2ncid gateway, review [yac setup](#gateways_yac).

> [Table of Contents](#doc_top)

### Sections:

> [SYSTEM REQUIREMENTS:](#instl_mac_sr)  
  [COMPILE REQUIREMENTS:](#instl_mac_case_sensitive)  
  [COMPILE:](#instl_mac_comp)  
  [INSTALL or UPGRADE:](#instl_mac_iu)  
  [CONFIGURE:](#instl_mac_conf)  
  [FIRST STARTUP:](#instl_mac_fs)  
  ([AUTO)START/STOP:](#instl_mac_ss)  
  [CHECKING DAEMON STATUS:](#instl_mac_check)  
  [TRIMMING LOG FILES:](#instl_mac_trim)  

### <a name="instl_mac_sr"></a>SYSTEM REQUIREMENTS:

> NCID should work on Mac OS X 10.4 (Tiger) and later versions, using both 
  PowerPC (PPC) and Intel processors.
     
> In order to use the NCID GUI client on Mac OS X 10.4 (Tiger) and 10.5
  (Leopard), you must install ActiveTcl because the NCID GUI client requires
  the new tcl/tk "tile" package.

> Furthermore, you must install a patch after
  ActiveTcl is installed to prevent a "BGError: bad attribute" error from
  occuring when you try to change the font. See instructions under the
  FIRST STARTUP section.
     
> Mac OS X 10.6 (Snow Leopard) was unavailable for testing.

### <a name="instl_mac_case_sensitive"></a>COMPILE REQUIREMENTS:

> When building NCID from source, you *must* compile on a case-sensitive Mac filesystem.
This requirement is ONLY for compiling NCID. Do not
attempt to put other Mac OS X applications on a
case-sensitive filesystem because they will probably
not work as expected.
          
> Use the diskutil utility to determine the filesystem type.
Assuming you will be installing to the Mac's startup
volume, i.e., the root filesystem:
          
>>`diskutil info / | fgrep -i "file system"`
                    
>The default Mac OS X filesystem type is 'Journaled HFS+' which is not case-sensitive.

>Look for 'Case-sensitive' in the output of the diskutil
command above. If you don't see it, you can create
a small, case-sensitive disk image just so you can 
compile NCID. A 10 megabyte disk image should be
more than adequate.

>>     hdiutil create -size 10m -fs "Case-sensitive HFS+" -volname NCID ~/NCID.dmg

>Next, mount the disk image:
>>`hdiutil attach ~/NCID.dmg`

>and change to its directory where you will copy the source:
>>`cd /Volumes/NCID`



### <a name="instl_mac_comp"></a>COMPILE:

> See INSTALL.

### <a name="instl_mac_iu"></a>INSTALL or UPGRADE:

> NCID requires the server and at least one client to function. The
  server is required on one computer or device, but the client can be
  installed on as many computers as needed.

> #### Install NCID:

>> The NCID package normally installs in /usr/local.

>> - If a tar archive is available:

>>                 
            Copy ncid-VERSION-mac-osx.tgz to the Mac
            sudo tar -xzvf ncid-VERSION-mac-osx.tgz -C /
            EXAMPLE: sudo tar -xzvf ncid-1.2-mac-osx.tgz -C /

>> - If an install script is available:

>>
            Copy ncid-VERSION-mac-osx_install.sh to the Mac
            sudo sh ncid-VERSION-mac-osx_install.sh
            EXAMPLE: sudo sh ncid-1.3-mac-osx_install.sh


>> - Compile and install from source if there is no binary package:

>>          
            Copy ncid-VERSION-src.tar.gz to the Mac
            tar -xzvf ncid-VERSION-src.tar.gz
            cd ncid  
            make mac (compiles for /usr/local, see top of Makefile)
            sudo make mac-install
                        
> #### Upgrade NCID:

>> The NCID package normally installs in /usr/local and configuration
    files are normally in /usr/local/etc/ncid.
          
>> - If a tar archive is available:

>>> Extracting the tar file will REPLACE the contents of all of
   the NCID configuration files. Be sure to back them up first.
   This includes all files in /usr/local/etc/ncid/.

>>
            Copy ncid-VERSION-mac-osx.tgz to the Mac
            sudo tar -xzvf ncid-VERSION-mac-osx.tgz -C /
            EXAMPLE: sudo tar -xzvf ncid-1.2-mac-osx.tgz -C

>>> You will need to manually compare your backed up configuration
    files with the new ones, and manually edit any differences.

>> - If an install script is available:

>>> For an upgrade, the install script will preserve existing configurations, and
   new ones installed will have *.new as the extension.

>>
            Copy ncid-VERSION-mac-osx_install.sh to the Mac
            sudo sh ncid-VERSION-mac-osx_install.sh
            EXAMPLE: sudo sh ncid-1.3-mac-osx_install.sh

>>> You will need to manually compare your current configuration
     files with the ".new" ones, and manually edit any differences.

>> - If there is no binary package, you need to compile the source.

>>>  Your existing configuration files will be preserved, and new ones
    installed will have .new as the extension.
>>            
            Copy ncid-VERSION-src.tar.gz to the Mac:
            tar -xzvf ncid-VERSION-src.tar.gz
            cd ncid
            make mac (compiles for /usr/local, see top of Makefile)
            sudo make mac-install

>>> You will need to manually compare your current configuration
     files with the ".new" ones, and manually edit any differences.
                                
### <a name="instl_mac_conf"></a>CONFIGURE:

> The Makefile preconfigures ncidd.conf for the Mac, but you may
  want to change some of the defaults.

> - If you are using a gateway instead of a local modem,
    you need to set noserial to 1:
>
          set noserial = 1

> - If you are using a local modem with or without a gateway
>
          set noserial = 0  (this is the default)

### <a name="instl_mac_fs"></a>FIRST STARTUP:

> - If you are running Mac OS X 10.4 (Tiger) or 10.5 (Leopard) go to this site
    and download ActiveTcl version 8.4.19.6 for the Mac:
    http://www.activestate.com/activetcl/downloads
      
> - After downloading, double-click on the file:
>
          ActiveTcl8.4.19.6.295590-macosx-universal-threaded.dmg

> - Then double-click on the icon where it says, "ActiveTcl-8.4.pkg"
    and follow the instructions.
      
> - Finally, install the patch for ActiveTcl 8.4.19.6 by launching Terminal
    and typing:
>
          sudo /usr/local/share/doc/ncid/fix-combobox

> - If you are running the server and client on the same computer
    and using a modem:  
>
       + In Terminal, type: sudo /usr/local/sbin/ncidd  
       + In Finder, navigate to the Applications folder and double-click on "ncid-gui".
       + Close the front Terminal window that says, "Completed Command" in the title bar.

> - If you are running the server and using a SIP gateway:
    + In Terminal, type: sudo /usr/local/sbin/ncidd  
    + In Terminal, type: sudo /usr/local/sbin/sip2ncid
    + In Finder, navigate to the Applications folder and double-click on "ncid-gui".
    + Close the front Terminal window that says, "Completed Command" in the title bar.

> - If you are running the server and using a YAC gateway:
    + In Terminal, type: sudo /usr/local/sbin/ncidd
    + In Terminal, type: sudo /usr/local/sbin/yac2ncid
    + In Finder, navigate to the Applications folder and double-click on "ncid-gui".
    + Close the front Terminal window that says, "Completed Command" in the title bar.
    <br><br>

> - Call yourself and see if it works. If not,
      stop the gateway first (if used), and then stop the server,
      using 'sudo kill' and the appropriate process ID.
      Continue by reading the test sections.

> - If everything is OK, enable the NCID server, gateways, and
      client modules you are using, to autostart at boot.

### <a name="instl_mac_ss"></a>(AUTO)START/STOP:
              
> #### SERVER
    
>> Under Mac OS X 10.4 and later, the mechanism used to start the NCID
   server processes is 'launchd' and requires 'plist' files in
   /Library/LaunchDaemons. Appropriate plist files for the NCID server
   processes are created automatically when NCID is installed, however,
   they must be manually activated.
    
>> Once activated, no action is typically required as the plist files are 
   configured to automatically start each time the system boots.
    
>> Here is the complete list of plist files:
>>    
          /Library/LaunchDaemons/net.sourceforge.ncid-initmodem.plist  
          /Library/LaunchDaemons/net.sourceforge.ncid-notify.plist  
          /Library/LaunchDaemons/net.sourceforge.ncid-page.plist  
          /Library/LaunchDaemons/net.sourceforge.ncid-samba.plist  
          /Library/LaunchDaemons/net.sourceforge.ncid-speak.plist  
          /Library/LaunchDaemons/net.sourceforge.ncid-yac.plist  
          /Library/LaunchDaemons/net.sourceforge.ncid2ncid.plist  
          /Library/LaunchDaemons/net.sourceforge.ncidd.plist  
          /Library/LaunchDaemons/net.sourceforge.sip2ncid.plist  
          /Library/LaunchDaemons/net.sourceforge.wc2ncid.plist  
          /Library/LaunchDaemons/net.sourceforge.yac2ncid.plist
    
>> You do not interact with launchd directly, instead you use the 'launchctl'
   command line utility.

>> You should only activate the NCID servers and client modules you need. 
   Activating will also start the process immediately; there is no need
   to reboot.

>> The syntax for stopping the daemons is the same as starting them, except
   you use the 'unload' command instead of the 'load' command. Doing an unload
   stops the daemon immediately and prevents it from starting automatically
   the next time the system is booted.
    
>> Here are some examples:

>> - start the NCID server:  
>
              sudo launchctl load -w /Library/LaunchDaemons/net.sourceforge.ncidd.plist

>> - stop the sip2ncid server:  
>
              sudo launchctl unload -w /Library/LaunchDaemons/net.sourceforge.sip2ncid.plist

>> - start ncid with ncid-page  
>
              sudo launchctl load -w /Library/LaunchDaemons/net.sourceforge.ncid-page.plist
      
>> Review the man page (man launchctl).

> #### CLIENT:
    
>> For the NCID GUI client, no .plist is currently provided because of the 
   requirement that NCID must be installed as root, and the GUI preference file
   is specific to each user. However, a script called "ncid-gui" is installed
   for you automatically to the Applications folder. To have it start when you 
   automatically log in, drag "ncid-gui" to your account's Login Items as
   described here: http://support.apple.com/kb/HT2602
    
>> After you login, you should close the front Terminal window that says, 
    "Completed Command" in the title bar.
        
### <a name="instl_mac_check"></a>CHECKING DAEMON STATUS:

> Use the launchctl 'list' command to show the daemons currently loaded, 
  optionally using fgrep to filter out only NCID related processes.
    
> Daemons currently running will have a process id.
    
> Daemons which were stopped without an error will not be listed at all.
    
> If a daemon has stopped due to an error, it will have no process id but 
  will have a numeric exit status. Examine the contents of the
  /var/log/system.log file to determine the problem. Once you fix the 
  problem, use the launchctl 'unload' command followed by the 'load' command.

> Example:  sudo launchctl list|fgrep net.sourceforge.ncid
    
            PID     Status  Label
            422     -       net.sourceforge.ncid-notify
            419     -       net.sourceforge.ncidd

### <a name="instl_mac_trim"></a>TRIMMING LOG FILES:

> The Mac uses newsyslog to trim files. To trim the cidcall.log and the
  ciddata.log files, add this entry to /etc/newsyslog.conf
>
        /var/log/cid*.log   root:wheel 644 5 * $M1D0 GN
