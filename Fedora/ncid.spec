Name:       ncid
Version:    1.6
Release:    1%{?dist}
Summary:    Network Caller ID server, client, and gateways
Group:      Applications/Communications
Requires:   perl
License:    GPLv3+
Url:        http://ncid.sourceforge.net
Source0:    http://sourceforge.net/projects/ncid/files/ncid/%{version}/%{name}-%{version}-src.tar.gz
BuildRoot:  %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%{?systemd_requires}
BuildRequires: libpcap-devel, perl-podlators, man2html, pandoc, systemd

%global _hardened_build 1

%description
NCID is Caller ID (CID) distributed over a network to a variety of
devices and computers.  NCID includes a server, gateways, a client,
client output modules, and command line tools.

The NCID server obtains the Caller ID information from a modem,
a serial device, and from gateways for NCID, SIP, WC, & YAC.

This package contains the server and command line tools.
The gateways are in the ncid-gateways package.
The client is in the ncid-client package.

%package gateways
Summary:    NCID (Network Caller ID) gateways
Group:      Applications/Communications
Requires:   libpcap, perl, nc

%description gateways
NCID is Caller ID (CID) distributed over a network to a variety of
devices and computers.  NCID includes a server, gateways, a client,
client output modules, and command line tools.

This package contains the NCID gateways.

%package client
Summary:    NCID (Network Caller ID) client
Group:      Applications/Communications
BuildArch:  noarch
Requires:   tcl, tk, mailx, nc

%description client
The NCID client obtains the Caller ID from the NCID server and normally
displays it in a GUI window.  It can also display the Called ID in a
terminal window or, using an output module, format the output and send it
to another program.

This package contains the NCID client and output modules that are not
separate packages.

%package kpopup
Summary:    NCID kpopup module displays Caller ID info in a KDE window
Group:      Applications/Communications
BuildArch:  noarch
Requires:   %{name}-client = %{version}-%{release}
Requires:   %{name}-speak = %{version}-%{release}
Requires:   kde-baseapps, kmix

%description kpopup
The NCID kpopup module displays Caller ID information in a KDE pop-up window
and optionally speaks the number via voice synthesis.  The KDE or Gnome
desktop must be running.

%package mysql
Summary:    NCID mysql module inputs Caller ID information into a SQL database
Group:      Applications/Communications
BuildArch:  noarch
Requires:   %{name}-client = %{version}-%{release}, mysql

%description mysql
The NCID mysql module inputs NCID Caller information into a SQL database
using either MariaDB or a MySQL database.

%package mythtv
Summary:    NCID mythtv module sends Caller ID information to MythTV
Group:      Applications/Communications
BuildArch:  noarch
Requires:   %{name}-client = %{version}-%{release}, mythtv-frontend

%description mythtv
The NCID MythTV module displays Caller ID information using mythtvosd

%package samba
Summary:    NCID samba module sends Caller ID information to windows machines
Group:      Applications/Communications
BuildArch:  noarch
Requires:   %{name}-client = %{version}-%{release}, samba-client

%description samba
The NCID samba module sends Caller ID information to a windows machine
as a pop-up.  This will not work if the messenger service is disabled.

%package speak
Summary:    NCID speak module speaks Caller ID information via voice synthesis
Group:      Applications/Communications
BuildArch:  noarch
Requires:   %{name}-client = %{version}-%{release}, festival

%description speak
The NCID speak module announces Caller Id information verbally, using
the Festival text-to-speech voice synthesis system.

%prep

%setup -q -n %{name}

%build
make %{?_smp_mflags} EXTRA_CFLAGS="$RPM_OPT_FLAGS" \
     LOCKFILE=/var/lock/lockdev/LCK.. \
     TTYPORT=/dev/ttyACM0 \
     STRIP= prefix=/usr prefix2= local fedoradir

%install
rm -rf ${RPM_BUILD_ROOT}
make install install-fedora prefix=${RPM_BUILD_ROOT}/%{_prefix} \
                            prefix2=${RPM_BUILD_ROOT} \
                            prefix3=${RPM_BUILD_ROOT}

%clean
rm -rf $RPM_BUILD_ROOT
rm -fr $RPM_BUILD_DIR/%{name}

%files
%defattr(-,root,root)
%doc README VERSION doc/GPL.md
%doc doc/NCID-API.md
%doc doc/NCID-UserManual.md doc/images doc/README.docdir
%doc doc/ReleaseNotes.md man/README.mandir Fedora/README.Fedora
%doc server/README.server attic/README.attic
%doc logrotate/README.logrotate tools/README.tools
%{_datadir}/doc/ncid/recordings/README.recordings
%{_datadir}/doc/ncid/recordings/*.pvf
%{_bindir}/cidcall
%{_bindir}/cidalias
%{_bindir}/cidupdate
%{_bindir}/ncid-setup
%{_bindir}/ncidutil
%{_sbindir}/ncidd
%dir %{_datadir}/ncid
%dir %{_datadir}/ncid/sys
%dir %{_datadir}/ncid/recordings
%dir %{_datadir}/ncid/extensions
%{_datadir}/ncid/sys/ncidrotate
%{_datadir}/ncid/sys/ncid-yearlog
%{_datadir}/ncid/recordings/NumberDisconnected.rmd
%{_datadir}/ncid/recordings/CallingDeposit.rmd
%{_datadir}/ncid/recordings/NotInService.rmd
%{_datadir}/ncid/extensions/hangup-skel
%{_datadir}/ncid/extensions/hangup-message-skel
%{_datadir}/ncid/extensions/hangup-closed-skel
%{_datadir}/ncid/extensions/hangup-calls
%dir /etc/ncid
%config(noreplace) /etc/ncid/ncidd.blacklist
%config(noreplace) /etc/ncid/ncidd.whitelist
%config(noreplace) /etc/ncid/ncidd.conf
%config(noreplace) /etc/ncid/ncidd.alias
%config(noreplace) /etc/ncid/ncidrotate.conf
%config(noreplace) /etc/logrotate.d/ncid
%{_usr}/lib/systemd/system/ncidd.service
%{_mandir}/man1/ncidrotate.1*
%{_mandir}/man1/cidalias.1*
%{_mandir}/man1/cidcall.1*
%{_mandir}/man1/cidupdate.1*
%{_mandir}/man1/ncid-setup.1*
%{_mandir}/man1/ncid-yearlog.1*
%{_mandir}/man1/ncidutil.1*
%{_mandir}/man1/hangup-skel.1*
%{_mandir}/man1/hangup-message-skel.1*
%{_mandir}/man1/hangup-closed-skel.1*
%{_mandir}/man1/hangup-calls.1*
%{_mandir}/man5/ncidd.blacklist.5*
%{_mandir}/man5/ncidd.whitelist.5*
%{_mandir}/man5/ncidd.conf.5*
%{_mandir}/man5/ncidd.alias.5*
%{_mandir}/man5/ncidrotate.conf.5*
%{_mandir}/man7/ncidtools.7*
%{_mandir}/man8/ncidd.8*

%files gateways
%defattr(-,root,root)
%doc README VERSION doc/GPL.md gateway/README.gateways
%{_bindir}/email2ncid
%{_bindir}/ncid2ncid
%{_bindir}/obi2ncid
%{_bindir}/rn2ncid
%{_bindir}/wc2ncid
%{_bindir}/wct
%{_bindir}/yac2ncid
%{_sbindir}/sip2ncid
%dir %{_datadir}/ncid/setup
%{_datadir}/ncid/setup/ncid-email2ncid-setup
%config(noreplace) /etc/ncid/email2ncid.conf
%config(noreplace) /etc/ncid/ncid2ncid.conf
%config(noreplace) /etc/ncid/obi2ncid.conf
%config(noreplace) /etc/ncid/rn2ncid.conf
%config(noreplace) /etc/ncid/sip2ncid.conf
%config(noreplace) /etc/ncid/wc2ncid.conf
%config(noreplace) /etc/ncid/yac2ncid.conf
%{_usr}/lib/systemd/system/ncid2ncid.service
%{_usr}/lib/systemd/system/obi2ncid.service
%{_usr}/lib/systemd/system/rn2ncid.service
%{_usr}/lib/systemd/system/sip2ncid.service
%{_usr}/lib/systemd/system/wc2ncid.service
%{_usr}/lib/systemd/system/yac2ncid.service
%{_mandir}/man1/email2ncid.1*
%{_mandir}/man1/ncid2ncid.1*
%{_mandir}/man1/obi2ncid.1*
%{_mandir}/man1/rn2ncid.1*
%{_mandir}/man1/wc2ncid.1*
%{_mandir}/man1/wct.1*
%{_mandir}/man1/yac2ncid.1*
%{_mandir}/man1/ncid-email2ncid-setup.1*
%{_mandir}/man5/email2ncid.conf.5*
%{_mandir}/man5/ncid2ncid.conf.5*
%{_mandir}/man5/obi2ncid.conf.5*
%{_mandir}/man5/rn2ncid.conf.5*
%{_mandir}/man5/sip2ncid.conf.5*
%{_mandir}/man5/wc2ncid.conf.5*
%{_mandir}/man5/yac2ncid.conf.5*
%{_mandir}/man7/ncidgateways.7*
%{_mandir}/man8/sip2ncid.8*

%files client
%defattr(-,root,root)
%doc README VERSION client/README.client modules/README.modules
%doc doc/GPL.md doc/README.docdir
%{_bindir}/ncid
%dir %{_datadir}/ncid
%dir %{_datadir}/ncid/modules
%{_datadir}/ncid/modules/ncid-alert
%{_datadir}/ncid/modules/ncid-initmodem
%{_datadir}/ncid/modules/ncid-notify
%{_datadir}/ncid/modules/ncid-page
%{_datadir}/ncid/modules/ncid-skel
%{_datadir}/ncid/modules/ncid-wakeup
%{_datadir}/ncid/modules/ncid-yac
%{_datadir}/pixmaps/ncid/ncid.gif
%dir /etc/ncid
%dir /etc/ncid/conf.d
%config(noreplace) /etc/ncid/ncid.conf
%config(noreplace) /etc/ncid/conf.d/ncid-alert.conf
%config(noreplace) /etc/ncid/conf.d/ncid-notify.conf
%config(noreplace) /etc/ncid/conf.d/ncid-page.conf
%config(noreplace) /etc/ncid/conf.d/ncid-skel.conf
%config(noreplace) /etc/ncid/conf.d/ncid-yac.conf
%{_usr}/lib/systemd/system/ncid-initmodem.service
%{_usr}/lib/systemd/system/ncid-notify.service
%{_usr}/lib/systemd/system/ncid-page.service
%{_usr}/lib/systemd/system/ncid-yac.service
%{_mandir}/man1/ncid.1*
%{_mandir}/man1/ncid-alert.1*
%{_mandir}/man1/ncid-initmodem.1*
%{_mandir}/man1/ncid-notify.1*
%{_mandir}/man1/ncid-page.1*
%{_mandir}/man1/ncid-skel.1*
%{_mandir}/man1/ncid-wakeup.1*
%{_mandir}/man1/ncid-yac.1*
%{_mandir}/man5/ncid.conf.5*
%{_mandir}/man7/ncid-modules.7*

%files kpopup
%defattr(-,root,root)
%doc VERSION modules/README.modules
%{_datadir}/ncid/modules/ncid-kpopup
%config(noreplace) /etc/ncid/conf.d/ncid-kpopup.conf
%{_mandir}/man1/ncid-kpopup.1*

%files mysql
%defattr(-,root,root)
%doc VERSION modules/README.modules setup/README.setup
%{_datadir}/ncid/modules/ncid-mysql
%{_datadir}/ncid/setup/ncid-mysql-setup
%config(noreplace) /etc/ncid/conf.d/ncid-mysql.conf
%{_usr}/lib/systemd/system/ncid-mysql.service
%{_mandir}/man1/ncid-mysql.1*
%{_mandir}/man8/ncid-mysql-setup.8*

%files mythtv
%defattr(-,root,root)
%doc VERSION modules/README.modules
%{_datadir}/ncid/modules/ncid-mythtv
%config(noreplace) /etc/ncid/conf.d/ncid-mythtv.conf
%{_usr}/lib/systemd/system/ncid-mythtv.service
%{_mandir}/man1/ncid-mythtv.1*

%files samba
%defattr(-,root,root)
%doc VERSION modules/README.modules
%{_datadir}/ncid/modules/ncid-samba
%config(noreplace) /etc/ncid/conf.d/ncid-samba.conf
%{_usr}/lib/systemd/system/ncid-samba.service
%{_mandir}/man1/ncid-samba.1*

%files speak
%defattr(-,root,root)
%doc VERSION modules/README.modules
%{_datadir}/ncid/modules/ncid-speak
%config(noreplace) /etc/ncid/conf.d/ncid-speak.conf
%{_usr}/lib/systemd/system/ncid-speak.service
%{_mandir}/man1/ncid-speak.1*

%preun
# uninstall package if $1 == 0
%systemd_preun ncidd.service

%preun gateways
# uninstall package if $1 == 0
%systemd_preun ncid2ncid.service obi2ncid.service rn2ncid.service sip2ncid.service wc2ncid.service yac2ncid.service

%preun client
# uninstall package if $1 == 0
# must stop all modules even from different pacakges
%systemd_preun client %{_datadir}/ncid/modules/ncid-*
if [ $1 -eq 0 ] ; then
    # kill ncid GUI client
    pkill -f 'wish.*ncid ' || true
fi

%preun mysql
# uninstall package if $1 == 0
%systemd_preun ncid-mysql.service

%preun mythtv
# uninstall package if $1 == 0
%systemd_preun ncid-mythtv.service

%preun samba
# uninstall package if $1 == 0
%systemd_preun ncid-samba.service

%preun speak
# uninstall package if $1 == 0
%systemd_preun ncid-speak.service

%post
# install package if $1 == 1
%systemd_post ncidd.service
# set NCID port 3333 if firewall installed and running
if [ $1 -eq 1 ]; then
    if type firewall-cmd > /dev/null 2>&1; then
        if firewall-cmd --quiet --state; then
            if ! firewall-cmd --quiet --permanent --query-port=3333/tcp; then
                firewall-cmd --quiet --permanent --add-port=3333/tcp
            fi
        fi
    fi
fi

%post gateways
# install package if $1 == 1
%systemd_post ncid2ncid.service obi2ncid.service rn2ncid.service sip2ncid.service wc2ncid.service yac2ncid.service

%post client
# install package if $1 == 1
%systemd_post ncid-initmodem.service ncid-mysql.service ncid-mythtv.service ncid-notify.service ncid-page.service ncid-yac.service

%post mythtv
# install package if $1 == 1
%systemd_post ncid-mythtv.service

%post mysql
# install package if $1 == 1
%systemd_post ncid-mysql.service

%post samba
# install package if $1 == 1
%systemd_post ncid-samba.service

%post speak
# install package if $1 == 1
%systemd_post ncid-speak.service

%postun
if [ $1 -eq 0 ]; then ### remove package ###
    # remove NCID port 3333 if firewall installed and running
    if type firewall-cmd > /dev/null 2>&1; then
        if firewall-cmd --quiet --state; then
            if  firewall-cmd --quiet --permanent --query-port=3333/tcp; then
                firewall-cmd --quiet --permanent --remove-port=3333/tcp
            fi
        fi
    fi
else
### upgrade package ###
    # move any user recordings to recordings directory
    for RECORDING in %{_datadir}/ncid/*.rmd
    do
        test -f $RECORDING && mv $RECORDING %{_datadir}/ncid/recordings
    done
fi
# restart the server service if running when $1 >= 1
%systemd_postun_with_restart ncidd.service

%postun gateways
# restart gateway services that are running if $1 >= 1
%systemd_postun_with_restart ncid2ncid.service obi2ncid.service rn2ncid.service sip2ncid.service wc2ncid.service yac2ncid.service

%postun client
if [ $1 -ge 1 ]; then ### upgrade package ###
    # move any modules found to the modules directory
    for MODULE in %{_datadir}/ncid/ncid-*
    do
        test -f $MODULE && mv $MODULE %{_datadir}/ncid/modules
    done
fi
# restart module services that are running if $1 >= 1
# a module service could have been installed by another package
%systemd_postun_with_restart %{_datadir}/ncid/modules/ncid-*

%postun mysql
# restart module service if running when $1 >= 1
%systemd_postun_with_restart ncid-mysql.service

%postun mythtv
# restart module service if running when $1 >= 1
%systemd_postun_with_restart ncid-mythtv.service

%postun samba
# restart module service if running when $1 >= 1
%systemd_postun_with_restart ncid-samba.service

%postun speak
# restart module service if running when $1 >= 1
%systemd_postun_with_restart ncid-speak.service

%changelog

* Thu Nov 14 2016 John Chmielewski <jlc@users.sourceforge.net> 1.6-1
- removed retext as a requirement
- New release, see CHANGES file

* Sun Oct 2 2016 John Chmielewski <jlc@users.sourceforge.net> 1.5-1
- added to %build: LOCKFILE=/var/lock/lockdev/LCK.. TTYPORT=/dev/ttyACM0
- %doc /usr/share/doc/ncid/recordings -> %{_defaultdocdir}/ncid/recordings
- moved gateways from the ncid package into the gateways package
- rewrote all pre post preun postun scripts
- removed doc/NCID-SDK.md
- added firewall check in post to add NCID port
- added firewall check in postun to remove NCID port
- added ncid-yearlog and man page to ncid
- added email2ncid, email2ncid.conf, and email2ncid.[15]* to ncid-gateways
  added ncid-setup ncid-email2ncid-setup and man pages to ncid-gateways
- updated for hangup extension name changes and two new hangup extensions
- added new mysql package
- See NCID CHANGES file

* Thu Mar 24 2016 John Chmielewski <jlc@users.sourceforge.net> 1.4-1
- new release
- added hangup-skel, hangup-skel.1*, hangup-message, hangup-message.1*
- added perl-podlators to BuildRequires:
  removed CannotBeCompleted.rmd
- changed recording directory to recordings directory
- removed doc/Makefile

* Wed Dec 23 2015 John Chmielewski <jlc@users.sourceforge.net> 1.3-1
- renamed NCID_Documentation.md to NCID-UserManual.md
- renamed LICENSE to GPL.md and NCID-API.odt to NCID-API.md
- added CallingDeposit.pvf CallingDeposit.rmd CannotBeCompleted.pvf
- added CannotBeCompleted.rmd NotInService.pvf NotInService.rmd
- added ncid/sys ncid/modules ncid/recording directories
- modified %preun, %preun client, postun, postun client

* Sat Sep 12 2015 John Chmielewski <jlc@users.sourceforge.net> 1.2-1
- added Alias.md, Hangup.md NumberDisconnected.wav
- added NumberDisconnected.rmd README.recording

* Mon Aug 24 2015 John Chmielewski <jlc@users.sourceforge.net> 1.1-1
- added obi2ncid, obi2ncid.conf, obi2ncid.service

* Fri Aug 29 2014 John Chmielewski <jlc@users.sourceforge.net> 1.0-1
- new files /NCID-API.odt and NCID-SDK.md, removed file NCID-SDK.odt

* Tue Apr 8 2014 John Chmielewski <jlc@users.sourceforge.net> 0.89-1
- new release

* Wed Nov 20 2013 John Chmielewski <jlc@users.sourceforge.net> 0.88-1
- changed documentation files in doc/

* Thu May 23 2013 John Chmielewski <jlc@users.sourceforge.net> 0.87-1
- Updated lincese file and GNU license headers in files
- fixed ncidd to output a CID line if cidcall.log file not present
- modified cidnoname logic to add "NONMAE" when number was optained
- added rn2ncid, rn2ncid.conf, rn2ncid.service
- enabled _hardened_build

* Mon Feb 11 2013 John Chmielewski <jlc@users.sourceforge.net> 0.86-1
- Updated man pages: ncid*
- Updated and fixed client description
- Fixed typo in mythtv package summary
- New gateway: wc2ncid wc2ncid.conf wc2ncid.1 wc2ncid.conf.5 wc2ncid.service
- New output module: ncid-wakeup ncid-wakeup.1
- New output module: ncid-alert ncid-alert.conf ncid-alert.1
- new tool (wct), new man pages: ncidtools.7 ncidgateways.7
- Removed ncidsip and related ncidsip files

* Thu Oct 18 2012 John Chmielewski <jlc@users.sourceforge.net> 0.85-1
- Added ncidd.whitelist ncid-notify ncid-notify.service
- Added ncidd.whitelist.5 ncid-notify.1 ncid-modules.7
- Added Verbose-ncid to client
- Removed ncidmodules.1 and ncidmodules.conf.5 ncidtools.1
- Renamed scripts/ to logname/ and README.scripts to README.logrotate
- Fixed postun client
- Updated doc files

* Mon Jul 2 2012 John Chmielewski <jlc@users.sourceforge.net> 0.84-1
- Changed from using service & init scripts to systemctl & service scripts

* Fri Sep 2 2011 John Chmielewski <jlc@users.sourceforge.net> 0.83-1
- Removed /usr/share/ncid/ncid-tivo
- Removed ncid-tivo.1

* Thu Mar 17 2011 John Chmielewski <jlc@users.sourceforge.net> 0.82-1
- New release

* Sat Feb 26 2011 John Chmielewski <jlc@users.sourceforge.net> 0.81-1
- Removed: /usr/share/ncid/ncid-hangup
- Removed: _initrddir/ncid-hangup
- Removed: /etc/ncid/ncid.minicom
- Added:   _mandir/man5/ncidd.blacklist.5*
- Removed line: config(noreplace) /etc/ncid/ncid.blacklist
- Added line: config(noreplace) /etc/ncid/ncidd.blacklist
- Added man pages: cidalias.1 cidcall.1 cidupdate.1 ncid-initmodem.1
- Added man pages ncid-kpopup.1 ncid-page.1 ncid-samba.1 ncid-speak.1
- Added man pages: ncid-mythtv.1 ncid-skel.1 ncid-tivo.1 ncid-yac.1

* Sun Oct 10 2010 John Chmielewski <jlc@users.sourceforge.net> 0.80-1
- New release

* Thu Aug 26 2010 John Chmielewski <jlc@users.sourceforge.net> 0.79-1
- Added line: /usr/bin/ncid2ncid
- Added line: config(noreplace) /etc/ncid/ncid2ncid.conf
- Added line: _initrddir/ncid2ncid
- Added line: _mandir/man1/ncid2ncid.1*
- Added line: _mandir/man5/ncid2ncid.conf.5*

* Fri May 14 2010 John Chmielewski <jlc@users.sourceforge.net> 0.78-1
- New release

* Fri Apr 9 2010 John Chmielewski <jlc@users.sourceforge.net> 0.77-1
- Removed line: _initrddir/ncid-kpopup
- Removed section: post kpopup
- Removed section: preun kpopup
- Removed section: postun kpopup
- Added line: _initrddir/ncid-initmodem
- Added line: /usr/share/ncid/ncid-initmodem
- Added line: /etc/ncid/ncid.minicom
- Added line: config(noreplace) /etc/ncid/ncid.blacklist in client section
- Added ncid-initmodem and ncid-hangup to SCRIPT lines in client sections
- Added more comments

* Mon Dec 28 2009 John Chmielewski <jlc@users.sourceforge.net> 0.76-1
- Changed /usr/share/pixmaps/ncid.gif to /usr/share/pixmaps/ncid/ncid.gif

* Mon Oct 19 2009 John Chmielewski <jlc@users.sourceforge.net> 0.75-1
- Client package changed from i386 to noarch
- Added line: _initrddir/ncid-hangup
- Added line: /usr/share/ncid/ncid-hangup

* Fri Jun 19 2009 John Chmielewski <jlc@users.sourceforge.net> 0.74-1
- New release

* Sun Mar 29 2009 Eric Sandeen <sandeen@redhat.com> 0.73-2
- First Fedora build.

* Thu Mar 12 2009 John Chmielewski <jlc@users.sourceforge.net> 0.73-1
- Initial build.
