<!-- https://sourceforge.net/adobe/tlf/wiki/markdown_syntax/ -->
# Release Notes for NCID 1.6

## Index

> * NCID Distributions
> * Distribution Changes
> * Server Changes
> * Gateway Changes
> * Client Changes
> * Client Output Module Changes
> * Tool Changes
> * Documentation Changes

## NCID Distributions

> * SourceForge
> * Fedora packages
> * RPM based OS packages
> * Macintosh OS X package
> * FreeBSD package
> * Debian based OS packages

> ### SourceForge

>> The Macintosh, Fedora, FreeBSD, Raspbian, and Ubuntu packages may be included in repositories.

            NCID source package:           ncid-1.6-src.tar.gz

            Cygwin 32 bit Windows package: ncid-1.6-cygwin_install.sh

            Debian packages:               Ubuntu packages should install as-is

            Fedora 64 bit packages:        ncid-1.6-1.fc24.x86_64.rpm
                                           ncid-gateways-1.6-1.fc24.x86_64.rpm

            Fedora no-arch packages:       ncid-client-1.6-1.fc24.noarch.rpm
                                           ncid-kpopup-1.6-1.fc24.noarch.rpm
                                           ncid-mysql-1.6-1.fc24.noarch.rpm
                                           ncid-mythtv-1.6-1.fc24.noarch.rpm
                                           ncid-samba-1.6-1.fc24.noarch.rpm
                                           ncid-speak-1.6-1.fc24.noarch.rpm

            FreeBSD 64 bit package:        ncid-1.6-FreeBSD-10.2_install.sh

            Macintosh 64 bit OS X package: ncid-1.6-mac-osx_install.sh
            (Universal binary, OSX 10.4+)

            Raspbian packages:             ncid_1.6-1_armhf.deb
            (Raspberry Pi)                 ncid-gateways_1.6-1_armhf.deb

            Ubuntu 64 bit packages:        ncid_1.6-1_amd64.deb
                                           ncid-gateways_1.6-1_amd64.deb

            Raspbian and Ubuntu no-arch packages:
                                           ncid-client_1.6-1_all.deb
                                           ncid-kpopup_1.6-1_all.deb
                                           ncid-mysql_1.6-1_all.deb
                                           ncid-mythtv_1.6-1_all.deb
                                           ncid-samba_1.6-1_all.deb
                                           ncid-speak_1.6-1_all.deb

            TiVo Series 2-3 package:       ncid-1.6-mips-tivo_install.sh

            Windows client installer:      ncid-1.6-client_win10_x64_setup.exe

> ### Fedora packages

>> Available at the Fedora repository.
  New release first appears in the rawhide repository.
  There are server, client, and optional output module packages.
  Normally you only need to install the **ncid** rpm package.
  The **ncid-gateways** and **ncid-client** rpm packages may also
  be required.

>> The dnf list command will show you the packages available:
>>
          dnf list ncid\*

>> If the above does not show version 1.6:
>>
          dnf --enablerepo=rawhide list ncid\*

>> If the rawhide repo is not installed:
>>
          dnf install fedora-release-rawhide

>> If you need to build packages for your specific OS release:
>>
          rpmbuild -tb ncid-1.6-src.tar.gz

> ### RPM based OS packages

>> Includes Fedora, Redhat, CentOS, etc.

>> If a dependency can not be resolved, you should try rebuilding packages:
>>
    - Download the latest NCID deb packages from SourceForge:
      ncid RPM Package          - server, extensions, and tools
      ncid-gateways RPM Package - gateways (if using a gateway)
      ncid-client RPM Package   - client and default output modules
                                  (if using this client)
    - Download any optional output modules wanted:
      ncid-MODULE RPM Package  - optional client output modules
    - Install or Upgrade the packages using dnf
          * Install the NCID server and gateways:
            sudo dnf install ncid-<version>.fc24.x86_64.rpm
          * Install the client package and default modules:
            sudo dnf install ncid-client-<version>.fc24.noarch.rpm
          * Install any optional modules wanted:
            sudo dnf ncid-<module>-<version>.fc24.noarch.rpm
>>
    Notes:
        <version> would be something like: 1.6-1
        <module> would be: kpopup, mysql, mythtv, samba, speak

> ### Macintosh OS X package

>> The version available at MacPorts is 0.83 which was released
>> October 2011. It is not currently maintained:  
>>
>>>  http://trac.macports.org/browser/trunk/dports/net/ncid/Portfile
>>  
>> Use the version available at SourceForge.

> ### FreeBSD package

>> Available at FreshPorts.
>> 
>>>    http://www.freshports.org/comms/ncid/

> ### Debian based OS packages

>> Includes Debian, Raspbian, Ubuntu, etc.

>> Install from the files at SourceForge:
>>
    - Download the latest NCID DEB packages from SourceForge:
      ncid DEB Package          - server, extensions, and tools
      ncid-gateways DEB Package - gateways (if using a gateway)
      ncid-client DEB Package   - client and default output modules
                                  (if using this client)
>>
    - Download any optional output modules wanted:
      ncid-MODULE DEB Package  - optional client output modules
>>
    - Install or Upgrade the packages using the gdebi-gtk (GUI):
        * If needed use the the menu item "Add/Remove.." to install the
          GDebi Package Installer.
        * Using the file viewer:
            - Open the file viewer to view the NCID DEB packages
            - Select the DEB packages
            - double-click selections or right-click selections and select
              "Open with GDebi Package installer"
>>
    - Install or Upgrade the packages using gdebi (command line):
        * Install gdebi if needed:
          sudo apt-get install gdebi    
        * Install the NCID server and gateways:
          sudo gdebi ncid-<version>_<processor>.deb
        * Install the client package and default modules:
          sudo gdebi ncid-client-<version>_all.deb
        * Install any optional modules wanted:
          sudo gdebi ncid-<module>-<version>_all.deb
>>
    Notes:
        <version> would be something like: 1.6-1
        <processor> would be: i386, armhf, amd64
        <module> would be: kpopup, mysql, mythtv, samba, speak

>> If you need to build a package for your specific OS or release, the
  build-essential, fakeroot, and libpcap packages must be installed:
>>
        sudo apt-get build-essential fakeroot libpcap0.8-dev
        tar -xzf ncid-1.6-src.tar.gz
        mv ncid ncid-1.6
        cd ncid-1.6
        fakeroot debian/rules build
        fakeroot debian/rules binary
        fakeroot debian/rules clean

## Distribution Changes

> Cygwin:

> Fedora, Redhat, and RPM based systems:

> FreeBSD:

> Mac OS X:

> Ubuntu, Raspbian, Debian based systems:

> TiVo:

> Windows:

## Server Changes

> ncidd:

> - at connect a client or gateway can send: HELLO &lt;label&gt; &lt;string&gt;  
    HELLO: IDENT: &lt;string&gt; is handled as an ident (client/gateway identification)  
    HELLO: CMD: no\_log causes ncidd to not send the call log

> ncidd.conf:

> ncidd Extensions:

## Gateway Changes

> email2ncid:

> - upon initial connection, send ident and tell server not to send call log 
> - default is port 3333 instead of 3334

> ncid2ncid:

> - upon connection, send ident and tell server not to send call log 

> obi2ncid:

> - upon connection, send ident and tell server not to send call log 

> rn2ncid:

> - upon connection, send ident and tell server not to send call log 

> sip2ncid:

> - upon connection, send ident and tell server not to send call log 

> wc2ncid:

> - upon connection, send ident and tell server not to send call log 

> yac2ncid:

> - upon connection, send ident and tell server not to send call log 

## Client Changes

> ncid:

> - added field labels to GUI and a help menu item to explain abbreviations

> - upon connection, send ident, and also tell server not to send call log when using option --no-gui


## Client Output Module Changes

## Tool Changes

> cidalias:

> cidcall:

> cidupdate:

> ncidutil:

> ncid-yearlog:

## Setup Scripts Changes

> ncid-mysql-setup:

> ncid-email2ncid-setup:

> ncid-setup:

## Documentation Changes

> NCID-API.md  
  Message.md  
  ncidd.conf.5,
  ncid2ncid.conf.5

