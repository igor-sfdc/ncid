<!-- INSTALL-Ubuntu.md - Removable HEADER Start -->

Last edited: Oct 2, 2016 

<!-- Removable HEADER End -->

## <a name="instl_ubuntu_top"></a>Ubuntu DEB Package Install

> If NCID does not work, see [INSTALL](#instl_generic_top) for some simple tests.  

> If using the email2ncid gateway, review [email2ncid setup](#gateways_email).  
  If using the ncid2ncid gateway, review [ncid2ncid setup](#gateways_n2n).  
  If using the obi2ncid gateway, review [obi2ncid setup](#gateways_obi).  
  If using the rn2ncid gateway, review [rn2ncid setup](#gateways_rn).  
  If using the sip2ncid gateway, review [sip2ncid setup](#gateways_sip).  
  If using the wc2ncid gateway, review [wc2ncid setup](#gateways_wc).  
  If using the yac2ncid gateway, review [yac2ncid setup](#gateways_yac).

[Table of Contents](#doc_top)

### Sections:

> [COMPILE:](#instl_ubuntu_comp)  
  [INSTALL or UPGRADE:](#instl_ubuntu_iu)  
  [CONFIGURE:](#instl_ubuntu_conf)  
  [FIRST STARTUP:](#instl_ubuntu_fs)  
  [START/STOP/RESTART/RELOAD/STATUS:](#instl_ubuntu_ss)  
  [AUTOSTART:](#instl_ubuntu_as)  
  [PACKAGE REMOVAL:](#instl_ubuntu_rm)  
  [KNOWN ISSUE - MODEM MANAGER MAY HANG NCID AT BOOT TIME:](#instl_ubuntu_mm)

### <a name="instl_ubuntu_comp"></a>COMPILE:

> It's very important to update the latest package info before
> continuing. Don't skip these two steps!

>>     sudo apt-get update
>>     sudo apt-get upgrade

> The following packages are required:  
>
>>     sudo apt-get install build-essential  
>>     sudo apt-get install libpcap0.8-dev
    
> This package is required to run obi2ncid, rn2ncid, wc2ncid and wct:  
>
>>     sudo apt-get install libconfig-simple-perl

> This additional package is required to run wc2ncid (install via cpan, see below):  
>
>>     Data::HexDump

    
> See [INSTALL (generic)](#instl_generic_top) for compile instructions.

### <a name="instl_ubuntu_iu"></a>INSTALL or UPGRADE:

> NCID requires the server and client DEB packages to function.  The
  server is required on one computer or device, but the client can be
  installed on as many computers as needed.

> The client has most of the output modules in its DEB package, but there
  are optional output modules in their own DEB packages.

> It's very important to update the latest package info before
> continuing. Don't skip these two steps!

>>     sudo apt-get update
>>     sudo apt-get upgrade

> - **Install NCID from a Debian repository**

>> The official repository for Debian/Ubuntu has not been updated since NCID
>> version 0.88 was released in January 2014. For this reason you should only
>> install from the files at SourceForge.

> - **Install NCID from DEB packages at SourceForge**

>> - Download the latest NCID Deb packages you want to install from
     SourceForge, as examples:

>>>  Download ncid version 1.5 (required)

>>>>     wget http://sourceforge.net/projects/ncid/files/ncid/1.5/ncid_1.5-1_amd64.deb  

>>>  If using the client, download ncid-client version 1.5 (optional)

>>>>     wget http://sourceforge.net/projects/ncid/files/ncid/1.5/ncid-client_1.5-1_all.deb

>>>  If using a gateway instead of a modem, download ncid-gateways version 1.5 (optional)

>>>>     wget http://sourceforge.net/projects/ncid/files/ncid/1.5/ncid-gateways_1.5-1_all.deb

>>> Download any optional output modules wanted 
    (most modules are included with the client package)
    
>>>>     ncid-<module>_<version>_all.deb

>> - Use gdebi or dpkg to install the local NCID packages and dependent packages.
  If you *only* use apt-get it will not install dependent packages and will fail.


>>> - Method 1: Install or Upgrade the packages using gdebi-gtk (GUI):
>>> 
>>>> - If needed use the menu item "Add/Remove.." to install the GDebi
    Package Installer.
>>>> - Using the file viewer:
     - Open the file viewer to view the NCID DEB packages
     - Select the DEB packages
     - Double-click selections or right-click selections and select
     "Open with GDebi Package installer"

>>> - Method 2: Install or Upgrade the packages using gdebi (command line):
>>> 
>>>> - Install gdebi if needed:  

>>>>>     sudo apt-get install gdebi    

>>>> - Install the NCID server:  

>>>>>     sudo gdebi ncid-<version>_amd64.deb

>>>> - Install the client package and default modules:  

>>>>>     sudo gdebi ncid-client-<version>_all.deb

>>>> - Install the optional gateways:  

>>>>>     sudo gdebi ncid-<version>_amd64.deb

>>>> - Install any optional modules wanted:  

>>>>>     sudo gdebi ncid-<module>-<version>_all.deb

>>> - Method 3: Install or Upgrade the packages using dpkg (command line):

>>>> - Install the NCID server:  

>>>>>     sudo dpkg -i ncid-<version>_amd64.deb

>>>> - Install the client package and default modules:  

>>>>>     sudo dpkg -i ncid-client-<version>_all.deb

>>>> - Install the optional gateways:  

>>>>>     sudo dpkg -i ncid-<version>_amd64.deb

>>>> - Install any optional modules wanted:  

>>>>>     sudo dpkg -i ncid-<module>-<version>_all.deb

>>>> - Force install of all dependencies:

>>>>>     sudo apt-get install -f

> #### Notes:  
   &lt;version&gt; would be something like: 1.0-1  
   &lt;module&gt; would be a module name like: kpopup, mythtv, samba

### <a name="instl_ubuntu_conf"></a>CONFIGURE:

> The ncidd.conf file is used to configure ncidd.

> - The default modem port in ncidd is /dev/ttyACM0.  If you need to change it,
    set your modem port in ncidd.conf.  This assumes serial port 0:

>>     set ttyport = /dev/ttyS0

> - If you are using a SIP or YAC gateway instead of a local modem,
    you need to set noserial to 1:  
    
>>     set noserial = 1

> - If you are using a local modem with or without a SIP or YAC gateway:  

>>     set noserial = 0  (this is the default)

### <a name="instl_ubuntu_fs"></a>FIRST STARTUP:

> - If you are running the server and client on the same computer and 
    using a modem:  
    
>>     sudo invoke-rc.d ncidd start  
>>     ncid &

> - If you are running the server and using a SIP gateway:

>>     sudo invoke-rc.d ncidd start  
>>     sudo invoke-rc.d sip2ncid start  
>>     ncid &

> - If you are running the server and using a Whozz Calling gateway, you 
 need to install the `Data::HexDump` Perl module using cpan:  
 
>>     cpan  
         interactive mode, first use will enter configure
         configure as much as possible automatically
         choose sudo from: (Choose 'local::lib', 'sudo' 
            or 'manual')
         automatically choose some CPAN mirror
         when configure finishes, it displays the cpan 
         prompt: cpan[1]>
>> 
>>     install Data::HexDump
>>     quit (quits cpan)
>>
>>     sudo invoke-rc.d ncidd start  
>>     sudo invoke-rc.d wc2ncid start  
>>     ncid &

> - If you are running the server and using a YAC gateway:  

>>     sudo invoke-rc.d ncidd start  
>>     sudo invoke-rc.d yac2ncid start  
>>     ncid &

> - Call yourself and see if it works, if not:

>> - Stop the gateway used:  

>>>>     sudo invoke-rc.d sip2ncid stop  

>> - Stop the server:  

>>>>     sudo invoke-rc.d ncidd stop

>> - Continue reading the test sections.

> - If everything is OK, enable the NCID server, gateways, and
    client modules you are using to autostart at boot. There 
    are rc.init scripts for starting ncid with output modules, 
    for example: ncid-page, ncid-kpopup, etc.

> #### NOTE:
>> The ncid GUI client must be started after login, not boot.
   There is no ncid.init script to start or stop it.

### <a name="instl_ubuntu_ss"></a>START/STOP/RESTART/RELOAD/STATUS:
START/STOP/STATUS:

> Use the invoke-rc.d command to start any of the daemons.  The invoke-rc.d
  commands are: start, stop, restart, reload, and status.  The client
  can also be started using the output module name instead of ncid.
  All output modules can be run at the same time.

> Here are some examples:

> - Start the NCID server:  

>>     sudo invoke-rc.d ncidd start

> - Stop the sip2ncid server:  

>>     sudo invoke-rc.d sip2ncid stop

> - Reload the server alias file:  

>>     sudo invoke-rc.d ncidd reload

> - Start ncid with ncid-page:    

>>     sudo invoke-rc.d ncid-page start

> - Status of ncid with ncid-speak:  

>>     sudo invoke-rc.d ncid-speak status

> Review the man page: **man invoke-rc.d**

### <a name="instl_ubuntu_as"></a>AUTOSTART:

> Use the update-rc.d command to enable/disable the service at boot.

> Here are some examples:

> - Start ncidd at boot:  

>>     sudo update-rc.d ncidd defaults

> - Start ncid-page at boot:  

>>     sudo update-rc.d ncid-page defaults

> - Remove ncidd startup at boot:  

>>     sudo update-rc.d -f ncidd remove

> Review the man page: **man update-rc.d**

> See also [this section about a known issue where ModemManager may hang NCID at boot time](#instl_ubuntu_mm).

### <a name="instl_ubuntu_rm"></a>PACKAGE REMOVAL:

> Use apt-get to remove any NCID package installed.

> For example, to use apt-get to remove the ncid package:

> - Normal removal without removing configuration files and dependencies:  

>>     sudo apt-get remove ncid

> - Complete removal including configuration files:  

>>     sudo apt-get purge ncid

> - Remove ncid dependencies no longer needed:  

>>     sudo apt-get autoremove

> Review the man page: **man apt-get**

### <a name="instl_ubuntu_mm"></a>KNOWN ISSUE - MODEM MANAGER MAY HANG NCID AT BOOT TIME:

> Symptoms:

> - You are running Ubuntu 14.xx or later with the Modem Manager installed and running.
> - The NCID server is not sending caller ID to clients on your network.
> - Clients are unable to connect to the NCID server.
> - The NCID server log /var/log/ncidd.log indicates modem
>   initialization did not complete and appears to be hung.
>   This also prevents other processes after it from starting until the NCID server is killed.
> - You may see very strange modem responses in the NCID server log.
> - The NCID server problem is fixed by manually restarting it after the Operating System boots.

> ModemManager is attempting to query modems (including
> bluetooth and other serial devices) at boot time by sending
> "AT+GCAP" (the AT command for a modem to "Request Complete
> Capabilities List"). This conflicts with the NCID server
> initializing the modem at the same time.

> The solution is to disable ModemManager completely by issuing
> the following commands:

>     sudo systemctl disable ModemManager
>     sudo systemctl stop ModemManager
>     sudo systemctl status ModemManager

> The **disable** line will prevent ModemManager from starting at boot.

> The **stop** line will terminate the currently running instance of
> ModemManager.

> The **status** lines should look like this:

>     o ModemManager.service - Modem Manager  
>        Loaded: loaded (/lib/systemd/system/ModemManager.service; disabled; vendor pr  
>        Active: inactive (dead)  

> **Loaded:** will show <u>disabled</u> and **Active:** will show 
> <u>inactive (dead)</u>.

> For USB modems, an alternative would be to create a udev rule
> as described [here](http://www.reactivated.net/writing_udev_rules.html) or
> [here](http://ubuntuforums.org/showthread.php?t=2056285) that will
> exclude only the NCID modem from being probed.
