<!-- INSTALL-Fedora.md - Removable HEADER Start -->

Last edited: Aug 6, 2016

<!-- Removable HEADER End -->

## <a name="instl_fed_top"></a>Fedora RPM Package Install

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

> [COMPILE:](#instl_fed_comp)  
  [INSTALL or UPGRADE:](#instl_fed_iu)  
  [CONFIGURE:](#instl_fed_conf)  
  [FIRST STARTUP:](#instl_fed_fs)  
  [START/STOP/RESTART/RELOAD/STATUS:](#instl_fed_ss)  
  [AUTOSTART:](#instl_fed_as)

### <a name="instl_fed_comp"></a>COMPILE:

> The following package is required:

         sudo dnf install libpcap-devel

> This package is required to run obi2ncid, rn2ncid, wc2ncid, wct:

        - sudo dnf install perl-Config-Simple

> This additional package is required to run wc2ncid and wct:

        - sudo dnf install perl-Data-HexDump

> See INSTALL for compile instructions

### <a name="instl_fed_iu"></a>INSTALL or UPGRADE:

> NCID requires the server and client RPM packages to function.  The
  server is required on one computer or device, but the client can be
  installed on as many computers as needed.

> The client has a most of the output modules in its RPM package, but there
  are optional output modules in their own RPM packages.

> Download the server and client RPM packages using dnf from the
  Fedora repositories.  You can also download any optional output
  modules you want.

> - List the NCID packages

          sudo dnf list ncid\*

> - the most recent versions may be here:

          sudo dnf install fedora-release-rawhide  
          sudo dnf --enablerepo=rawhide list ncid\*

> - Download the server package:

          sudo dnf install ncid-< rpm package >  

> - Download the gateways package if using a gateway instead of a modem:

          sudo dnf install ncid-gateways-< rpm package >

> - Download the client package if using the client or output modules:

          sudo dnf install ncid-client-< rpm package >

> - Download any optional module packages wanted  
    (most modules are included with the client package):

          sudo dnf install ncid-< module rpm package >

> If the current release is not in the Fedora repositories, download
  the RPM packages from https://sourceforge.net/projects/ncid/


> - Download server (required), gateways (optional), and client (optional)
    RPM Packages from sourceforge:

          ncid RPM Package          (server - required)  
          ncid-gateways RPM Package (gateways - optional)  
          ncid-client RPM Package   (client & default output modules - optional)


> - Download any optional output modules wanted from sourceforge:

          ncid-MODULE RPM Package  (optional client output modules)

> - Install or Upgrade the packages:

         Using the file viewer:
         - Open the file viewer to view the NCID RPM packages
         - Select the RPM packages
         - right click selections and select "Open with Package installer"
         Using YUM:
         - sudo dnf install ncid\*.rpm

### <a name="instl_fed_conf"></a>CONFIGURE:

> The ncidd.conf file is used to configure ncidd.

> - The default modem port in ncidd is /dev/ACM0.  If you need to change it,
    set your modem port in ncidd.conf.  This assumes serial port 0:
>> set ttyport = /dev/ttyS0
> - If you are using a Gateway to get the Caller ID instead of a
    local modem, you need to set noserial to 1:
>> set noserial = 1
> - If you are using a local modem with or without a Gateway:
>> set noserial = 0  (this is the default)

### <a name="instl_fed_fs"></a>FIRST STARTUP:

> - If you are running the server and client on the same computer
    and using a modem:

          sudo systemctl start ncidd  
          ncid &

> - If you are running the server and using a SIP gateway:

          sudo systemctl start ncidd sip2ncid  
          ncid &

> - If you are running the server and using a Whozz Calling gateway:

          sudo systemctl start ncidd wc2ncid  
          ncid &

> - If you are running the server and using a YAC gateway:

          sudo systemctl start ncidd yac2ncid
          ncid &

> - Call yourself and see if it works, if not,

>> stop the gateway and server:  

          sudo systemctl stop sip2ncid ncidd  

>> and continue reading the test sections.

> - If everything is OK, enable the NCID server, gateways, and
    client modules you are using, to autostart at boot.

>> For example, to start ncidd and sip2ncid at boot:

          sudo systemctl enable ncidd sip2ncid

>> The GUI ncid client must be started after login, not boot.

>> NOTE:
>>> ncid normally starts in the GUI mode and there is no
    ncid.service script to start or stop it.  There are
    service scripts for starting ncid with output modules,
    for example: ncid-page, ncid-kpopup, etc.

### <a name="instl_fed_ss"></a>START/STOP/RESTART/RELOAD/STATUS:

> Use the 'systemctl' command to start any of the daemons.  The service
  commands are: start, stop, restart, reload, reload-or-restart, and status.
  The client can also be started using the output module name instead
  of ncid.  All output modules can be run at the same time.

> Here are some examples:

> - start the NCID server:

          sudo systemctl start ncidd.service

> - stop the ncid2sip server:


> - reload the server alias file:

          sudo systemctl reload-or-restart ncidd.service

> - restart ncid using ncid-page:

          sudo systemctl restart ncid-page.service

> - get the status of ncid using ncid-speak:

          sudo systemctl status ncid-speak.service

> Review the man page (man systemctl).

### <a name="instl_fed_as"></a>AUTOSTART:

> Use the 'systemctl' command to enable/disable a service to start at boot.

> Here are some examples:

> - autostart ncidd at boot:

          sudo systemctl enable ncidd

> - autostart ncidd and sip2ncid at boot:

          sudo systemctl enable ncidd sip2ncid

> - remove ncid-speak from starting at boot:

          sudo systemctl disable ncid-speak

> Review the manpage (man systemctl).
