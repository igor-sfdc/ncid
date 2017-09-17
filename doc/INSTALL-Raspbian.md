<!-- INSTALL-Raspbian.md - Removable HEADER Start -->

Last edited: Oct 2, 2016 

<!-- Removable HEADER End -->

## <a name="instl_rasp_top"></a>Raspbian Install

### [Raspberry Pi][] DEB Package Install using [Raspbian OS][]

[Raspberry Pi]: http://www.raspberrypi.org/
[Raspbian OS]: http://www.raspbian.org/

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

> [COMPILE:](#instl_rasp_comp)  
   [INSTALL or UPGRADE:](#instl_rasp_iu)  
   [CONFIGURE:](#instl_rasp_conf)  
   [FIRST STARTUP:](#instl_rasp_fs)  
   [START/STOP/RESTART/RELOAD/STATUS:](#instl_rasp_ss)  
   [AUTOSTART:](#instl_rasp_as)  
   [PACKAGE REMOVAL:](#instl_rasp_rm)  
   [KNOWN ISSUE - MODEM MANAGER MAY HANG NCID AT BOOT TIME:](#instl_rasp_mm)

### <a name="instl_rasp_comp"></a>COMPILE:

> It's very important to update the latest package info before
> continuing. Don't skip these two steps!

>>     sudo apt-get update
>>     sudo apt-get upgrade


> The following package is required:  
> 
>>     sudo apt-get install libpcap0.8-dev

> This package is required to run obi2ncid, rn2ncid, wc2ncid and wct:  
> 
>>     sudo apt-get install libconfig-simple-perl

> This additional package is required to run wc2ncid (install via cpan, see below):  
> 
>>     Data::HexDump

    
> See [INSTALL (generic)](#instl_generic_top) for compile instructions.

### <a name="instl_rasp_iu"></a>INSTALL or UPGRADE:

> NCID requires the server and client DEB packages to function.  The
  server is required on one computer or device, but the client can be
  installed on as many computers as needed.

> The client has most of the output modules in its DEB package, but there
  are optional output modules in their own DEB packages.

> The latest NCID can be installed from a Raspbian repository using apt-get if it
  is available.
  
> If you cannot find a repository that contains NCID or if the latest packages
  are not available, you can download them from SourceForge and install them
  using gdebi or dpkg.

> It's very important to update the latest package info before
> continuing. Don't skip these two steps!

>>     sudo apt-get update
>>     sudo apt-get upgrade

> - **Install NCID from a Raspbian repository**
          
>> - Install required package  

>>>     sudo apt-get install libpcap0.8-dev          
          
>> - List the available packages:    

>>>     sudo apt-cache search ncid

>> - Install the server (required):

>>>       sudo apt-get install ncid

>> - Install the client (optional):

>>>       sudo apt-get install ncid-client

>> - Install the gateways package (optional):  

>>>     sudo apt-get install ncid-gateways

>> - Install any optional output modules wanted:  

>>>     sudo apt-get install ncid-<module>
          
> - **Install NCID from DEB packages at sourceforge**

>> If the latest packages are not available at the Raspbian repository:

>> - Download the latest NCID Deb packages you want to install from
     SourceForge, as examples:

>>>  Download ncid version 1.5 (required)

>>>>     wget http://sourceforge.net/projects/ncid/files/ncid/1.5/ncid_1.5-1_armhf.deb

>>>  If using the client, download ncid-client version 1.5 (optional)

>>>>     wget http://sourceforge.net/projects/ncid/files/ncid/1.5/ncid-client_1.5-1_all.deb

>>>  If using a gateway instead of a modem, download ncid-gateways version 1.5 (optional)

>>>>     wget http://sourceforge.net/projects/ncid/files/ncid/1.5/ncid-gateways_1.5-1_all.deb

>>> - Download any optional output modules wanted 
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

>>>> - Install gdebi if needed:  

>>>>>     sudo apt-get install gdebi    

>>>> - Install the NCID server:  

>>>>>     sudo gdebi ncid-<version>_armhf.deb

>>>> - Install the client package and default modules:  

>>>>>     sudo gdebi ncid-client-<version>_all.deb

>>>> - Install the optional gateways:  

>>>>>     sudo gdebi ncid-gateways_<version>_all.deb

>>>> - Install any optional modules wanted:  

>>>>>     sudo gdebi ncid-<module>-<version>_all.deb

>>> - Method 3: Install or Upgrade the packages using dpkg (command line):

>>>> - Install the NCID server:  

>>>>>     sudo dpkg -i ncid-<version>_amd64.deb

>>>> - Install the client package and default modules:  

>>>>>     sudo dpkg -i ncid-client-<version>_all.deb

>>>> - Install the optional gateways:  

>>>>>     sudo dpkg -i ncid-gateways_<version>_all.deb

>>>> - Install any optional modules wanted:  

>>>>>     sudo dpkg -i ncid-<module>-<version>_all.deb

>>>> - Force install of all dependencies:

>>>>>     sudo apt-get install -f

> #### Notes:  
   &lt;version&gt; would be something like: 1.0-1  
   &lt;module&gt; would be a module name like: kpopup, mythtv, samba

### <a name="instl_rasp_conf"></a>CONFIGURE:

> The ncidd.conf file is used to configure ncidd.

> - The default modem port in ncidd is /dev/ttyACM0. If you need to change it,
    set your modem port in ncidd.conf.  This assumes USB serial port 1:  
    
>>     set ttyport = /dev/ttyACM1

> - If you are using a SIP or YAC gateway instead of a local modem,
    you need to set noserial to 1:  
    
>>     set noserial = 1

> - If you are using a local modem with or without a SIP or YAC gateway:  

>>     set noserial = 0  (this is the default)

### <a name="instl_rasp_fs"></a>FIRST STARTUP:

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
   There is no ncid.init script to start or stop it. Instead,
   to automatically launch ncid in GUI mode you need to modify the
   `autostart` script for LXDE (Lightweight X11 Desktop 
   Environment). The steps below are partly based on Method 2
   as seen in 
   [this post](http://www.raspberrypi-spy.co.uk/2014/05/how-to-autostart-apps-in-rasbian-lxde-desktop)
   and have been modified to work with the Wheezy and Jessie
   releases of Raspbian. These steps will need to be done for each
   user login where you want the ncid GUI to launch automatically.
   
>> - Login as a user and get to a shell prompt.
>> - Type in:  

>>>     sudo find ~/ -name autostart -exec nano {} \;

>> - Add a new line at the end of the file that corresponds with
     your NCID setup:

>>> - If ncidd is running locally on the RPi:  

>>>>>     @ncid
                  
>>> - If ncidd is on a different server or port, specify the IP
   address or host name, followed by the port number.

>>>>   Examples:

>>>>   ncidd running at 10.0.1.9 on default port 3333:  

>>>>>     @ncid 10.0.1.9
                  
>>>>   ncidd running at 10.0.1.9 on port 3334:  

>>>>>     @ncid 10.0.1.9 3334

>> - Save the changes with these keystrokes:  

>>>     ctrl-x  
>>>     y  
>>>     ENTER  


>> The next time the user(s) login the ncid GUI will start automatically.

### <a name="instl_rasp_ss"></a>START/STOP/STATUS:

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

### <a name="instl_rasp_as"></a>AUTOSTART:

> Use the update-rc.d command to enable/disable the service at boot.

> Here are some examples:

> - Start ncidd at boot:  

>>     sudo update-rc.d ncidd defaults

> - Start ncid-page at boot:  

>>     sudo update-rc.d ncid-page defaults

> - Remove ncidd startup at boot:  

>>     sudo update-rc.d -f ncidd remove

> Review the man page: **man update-rc.d**

> See also [this section about a known issue where ModemManager may hang NCID at boot time](#instl_rasp_mm).

### <a name="instl_rasp_rm"></a>PACKAGE REMOVAL:

> Use apt-get to remove any NCID package installed.

> For example, to use apt-get to remove the ncid package:

> - Normal removal without removing configuration files and dependencies:  

>>     sudo apt-get remove ncid

> - Complete removal including configuration files:  

>>     sudo apt-get purge ncid

> - Remove ncid dependencies no longer needed:  

>>     sudo apt-get autoremove

> Review the man page: **man apt-get**

### <a name="instl_rasp_mm"></a>KNOWN ISSUE - MODEM MANAGER MAY HANG NCID AT BOOT TIME:

> This issue was first reported on a Raspberry Pi 3 running Ubuntu
> Mate. The symptoms and solution are the same as described in the 
> [Install-Ubuntu](#instl_ubuntu_mm) section.
