<!-- Modules.md - Removable HEADER Start -->

Last edited: Jul 9, 2016

<!-- Removable HEADER End -->

## <a name="modules_top"></a> Client Output Modules

> [Table of Contents](#doc_top)

> [Description](#modules_des) 

> [Usage](#modules_usage)

### <a name="modules_des"></a> Description

> The ncid client supports output modules.

> An output module receives the Caller ID information from the ncid 
  client and gives the client new functionality.  For example, one 
  module sends the Caller ID or message to a smart phone as an SMS 
  message or sends it as an email message. Another module speaks the 
  Caller ID or message.

> There are various output modules included with NCID. See the
  [ncid-modules](http://ncid.sourceforge.net/man/ncid-modules.7.html) 
  man page for a current list of the distributed modules. Each module is
  described in the [man pages](http://ncid.sourceforge.net/man/man.html).

> There are also third party client modules. Some third party modules 
  can be found at [NCID Addons](http://ncid.sourceforge.net/addon.html).

### <a name="modules_usage"></a> Usage

> Modules are called by the client using a command line of this form:

>            ncid --no-gui --program ncid-<name>

> Most modules have a configuration file normally at /etc/ncid/conf.d:

>            /etc/ncid/conf.d/ncid-<name>.conf


> As an example, if the &lt;name&gt; is **page** and you want to run the 
> command in the background, then the command line would be:

>            ncid --no-gui --program ncid-page &

> All distributed modules have a boot script that contains the proper command line to start and
  stop the module as well as giving its status.  The boot scripts differ by operating systems.
  See the [INSTALL](http://ncid.sourceforge.net/doc/NCID-UserManual.html#install_top)
  document for more information on this for your operating system.

> The boot script name is always the same name as the module name.  Use the AUTOSTART link for
  your operating system on how to start the module at boot.  Use the START/STOP/RESTART/RELOAD/STATUS
  link for how to start and stop the module.  Normally you would enable the module to start at
  boot after you configure it.

> Fedora: [AUTOSTART](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_fed_as)
  [START/STOP/RESTART/RELOAD/STATUS](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_fed_ss)

> FreeBSD: [AUTOSTART](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_free_as)
  [START/STOP/RESTART/RELOAD/STATUS](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_free_ss)

> Raspbian: [AUTOSTART](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_rasp_as)
  [START/STOP/RESTART/RELOAD/STATUS](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_rasp_ss)

> Ubuntu: [AUTOSTART](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_ubuntu_as)
  [START/STOP/RESTART/RELOAD/STATUS](http://ncid.sourceforge.net/doc/NCID-UserManual.html#instl_ubuntu_ss)
