<!-- INSTALL.md - Removable HEADER Start -->

Last edited: Aug 6, 2016

<!-- Removable HEADER End -->

## <a name="instl_generic_top"></a>Generic INSTALL and Overview

> If using the email2ncid gateway, review [email2ncid setup](#gateways_email).  
  If using the ncid2ncid gateway, review [ncid2ncid setup](#gateways_n2n).  
  If using the obi2ncid gateway, review [obi2ncid setup](#gateways_obi).  
  If using the rn2ncid gateway, review [rn2ncid setup](#gateways_rn).  
  If using the sip2ncid gateway, review [sip2ncid setup](#gateways_sip).  
  If using the wc2ncid gateway, review [wc2ncid setup](#gateways_wc).  
  If using the yac2ncid gateway, review [yac2ncid setup](#gateways_yac).

> [Table of Contents](#doc_top)

### Sections

> * [Layout](#instl_generic_layout)  
> * [Compile](#instl_generic_compile)  
> * [Install](#instl_generic_install)  
> * [Test Using a Modem](#instl_generic_modem)  
> * [Test Using a Device (like the NetCallerID box)](#instl_generic_device)  
> * [Test Using `sip2ncid`](#instl_generic_sip)  
> * [Test Using `wc2ncid`](#instl_generic_wc)  
> * [Test Using `yac2ncid`](#instl_generic_yac)

### <a name="instl_generic_layout"></a>Layout

> * The programs go into `$prefix/bin` and `$prefix/sbin`.
> * The config file goes into `$prefix2/etc`.
> * The modem device is expected in `$prefix3/dev`.
> * The LOG file is expected in `$prefix3/var/log`.
> * The man pages go into `$MAN` which is `$prefix/share/man`.
> * The defaults are `prefix=/usr/local`, `prefix2=$prefix` and `prefix3=`.

> ####Fedora####
* The init scripts go into `$prefix2/etc/rc.d/init.d`.

> ####Debian, Ubuntu or Raspberry Pi (RPi)####
* The init scripts go into `$prefix2/etc/init.d`.

> ####FreeBSD####
* The rc scripts go into `$prefix2/etc/rc.d`.

> ####Macintosh OSX####
* The plist scripts go into `$(prefix3)/Library/LaunchDaemons`.

### <a name="instl_generic_compile"></a>Compile

>**Note:** The Makefile requires GNU make.
See the top of the Makefile for more information on targets.

> * The `libpcap` library and header files must be installed
    to compile the `sip2ncid` gateway.

> * Obtain `libpcap` from [TCPDUMP & LIBPCAP](http://www.tcpdump.org/)
  or the package repository of your Linux distribution.
  For example, if your distribution uses dnf try:
>
      dnf install libpcap libpcap-devel

> * To configure programs and config file for /usr/local:
>
      make local

> * To compile programs for /usr, and the config file for /etc:
>
      make package

> * To compile programs for Fedora:
>
      make fedora

> * To compile programs for RHEL (Red Hat Enterprise Linux):
>
      make redhat

> * To compile programs for Debian:
>
      make debian

> * To compile programs for Ubuntu:
>
      make ubuntu

> * To compile programs for Raspbian (Raspberry Pi):
>
      make raspbian

> * To compile programs for Macintosh OSX:  
>
>>     make mac  
>
>> or
>
>>     make mac-fat

> * To cross-compile for the TiVo:
> 
>> *  Series 1 requires TiVo PPC cross-development to be
>>    installed at /usr/local/tivo/ before executing the following:  
>>
       make tivo-s1  

>> *  Series 2 and 3 require TiVo MIPS cross-development and uses
>>    `$(MIPSXCOMPILE)` prefix. The same `make` command is used
>> for Series 2 and 3.
>>    
       make tivo-s2  
      

### <a name="instl_generic_install"></a>Install

>**Note:** See the top of the Makefile for more information on targets.

> * To install in `/usr/local` (man pages go into `/usr/local/share/man`):
>
      make install

> * To install in `/usr/local` (man pages go into `/usr/local/man`):
>
      make install MAN=/usr/local/man

> * To install programs in `/usr`,  
  config file in `/etc`,  
  and man pages in `/usr/share/man`:
 
>>     make package-install  
> or
  
>>     make install prefix=/usr prefix2=

> * To install programs for Fedora:
>
      make fedora-install

> * To install programs for RHEL (Red Hat Enterprise Linux):
>
      make redhat-install

> * To install programs for Debian:
>
      make debian-install

> * To install programs for Ubuntu:
>
      make ubuntu-install

> * To install programs for Raspberry Pi:
>
      make raspbian-install

> * To install programs for Macintosh OSX
>
      make mac-install

### <a name="instl_generic_modem"></a>Test Using a Modem

> * Start in this order:  
>
      ncidd  
      ncid

> * Call yourself.

> * If you have problems, start `ncidd` in debug mode:  
>
      ncidd -D

> * To get more information, add the verbose flag:  
>
      ncidd -Dv3

> * To also look at the alias, blacklist and whitelist structure:  
>
      ncidd -Dv9

> * The last three lines will be similar to:  
>
      Network Port: 3333  
      Wrote pid 20996 in pidfile: /var/run/ncidd.pid  
      End of startup: 04/01/2016 20:28:06

> * If `ncidd` aborts when you call yourself with something like:  

>>>      Modem set for CallerID.  
>>>      Modem Error Condition. (Phone rang here)  
>>>      /dev/ttyS1: No such file or directory  
> 
>> You need to set `ncidd` to ignore modem signals.
>     
>> Uncomment the following line in `ncidd.conf`:
>>
>>>     # set ttyclocal = 1
>
> * You should see the Caller ID lines between the first and second RING.

> * If Caller ID is not received from the modem, and if *gencid* is not set
  you will only see RING for each ring.

> * If *gencid* is set (the default), you will get a CID at RING number 2:
>
          07/13/2010 15:21  RING No Caller ID

>> This indicates one of three problems:

>> * The modem is not set for Caller ID.  
>> * The modem does not support Caller ID.  
>> * The Telco is not providing Caller ID.

> * Once you solve the problems, restart `ncidd` normally.

### <a name="instl_generic_device"></a>Test Using a Device (like the NetCallerID box)

> * Start in this order:
>
      ncidd  
      ncid

> * Call yourself.

> * If you have problems, start `ncidd` in debug mode:
>
      ncidd -D

> * To get more information, add the verbose flag:
>
      ncidd -Dv3

> * To also look at the alias, blacklist and whitelist structure:  
>
      ncidd -Dv9

> * The last three lines will be similar to:
>
      Network Port: 3333  
      Wrote pid 20996 in pidfile: /var/run/ncidd.pid  
      End of startup: 04/01/2016 20:28:06

> * Once you solve any problems, restart `ncidd` normally.

### <a name="instl_generic_sip"></a>Test Using sip2ncid

> * You may need to configure options, review [sip2ncid setup](#gateways_sip).  

> * Start in this order:
>
      ncidd  
      sip2ncid  
      ncid

> * Call yourself.

> * If you have problems, start `ncidd` in debug mode:
>
      ncidd -D

> * To get more information, add the verbose flag:
>
      ncidd -Dv3

> * To also look at the alias, blacklist and whitelist structure:  
>
      ncidd -Dv9

> * The last three lines will be similar to:
>
      Network Port: 3333  
      Wrote pid 20996 in pidfile: /var/run/ncidd.pid  
      End of startup: 04/01/2016 20:28:06

> * Once you solve any problems, restart `ncidd` normally.

### <a name="instl_generic_wc"></a>Test Using wc2ncid

> * You may need to configure options, review [wc2ncid setup](#gateways_wc).  

> * Start in this order:
>
      ncidd  
      wc2ncid  
      ncid  

> * Call yourself.

> * If you have problems, start `ncidd` in debug mode:
>
      ncidd -D

> * To get more information, add the verbose flag:
>
      ncidd -Dv3

> * To also look at the alias, blacklist and whitelist structure:  
>
      ncidd -Dv9

> * The last three lines will be similar to:
>
      Network Port: 3333  
      Wrote pid 20996 in pidfile: /var/run/ncidd.pid  
      End of startup: 04/01/2016 20:28:06

> * Once you solve any problems, restart `ncidd` normally.

### <a name="instl_generic_yac"></a>Test Using yac2ncid

> * You may need to configure options, review [yac2ncid setup](#gateways_yac).  

> * Start in this order:
>
      ncidd  
      yac2ncid  
      ncid

> * Call yourself.

> * If you have problems, start `ncidd` in debug mode:
>
      ncidd -D

> * To get more information, add the verbose flag:
>
      ncidd -Dv3

> * To also look at the alias, blacklist and whitelist structure:  
>
      ncidd -Dv9

> * The last three lines will be similar to:
>
      Network Port: 3333  
      Wrote pid 20996 in pidfile: /var/run/ncidd.pid  
      End of startup: 04/01/2016 20:28:06

> * Once you solve any problems, restart `ncidd` normally.
