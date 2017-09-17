# This Makefile requires either GNU make or BSD make
# Last Modified by jlc on Thu Oct 11, 2012

###########################################################################
# make local             - builds for /usr/local and /var                 #
# make install           - installs files in /usr/local and /var          #
#                                                                         #
# make package           - builds for /usr, /etc, and /var                #
# make package-install   - installs files in /usr, /etc, and /var         #
#                                                                         #
# make fedora            - builds for Fedora|Redhat with service files    #
# make fedora-install    - installs in /usr, /etc, and /var               #
#                                                                         #
# make redhat            - builds for Redhat|Fedora with init files       #
# make redhat-install    - installs in /usr, /etc, and /var               #
#                                                                         #
# make debian            - builds for debian with init files)             #
# make debian-install    - installs in /usr, /etc, and /var               #
#                                                                         #
# make raspbian          - builds for Raspbian with init files)           #
# make raspbian-install  - installs in /usr, /etc, and /var               #
#                                                                         #
# make ubuntu            - builds for Ubuntu with init files)             #
# make ubuntu-install    - installs in /usr, /etc, and /var               #
#                                                                         #
# make tivo-mips         - builds for a mips TiVo in /usr/local or prefix #
#                          can also prefix and prefix[234]                #
# make tivo-install      - installs in /usr/local                         #
#                          can also prefix and prefix[234]                #
# make tivo-s1           - builds for a ppc TiVo for /var/hack            #
# make tivo-s2           - builds for a mips TiVo for /var/hack           #
# make tivo-hack-install - basic install into /var/hack                   #
#                          uses the cross compilers at:                   #
#                          http://tivoutils.sourceforge.net/              #
#                          usr.local.powerpc-tivo.tar.bz2                 #
#                          (x86 cross compiler for Series1)               #
#                          usr.local.mips-tivo.tar.bz2                    #
#                          (x86 cross compiler for Series2)               #
#                                                                         #
# make freebsd           - builds for FreeBSD in /usr/local               #
# make freebsd-install   - installs in /usr/local                         #
#                                                                         #
# make mac               - builds for Macintosh OS X in /usr/local        #
# make mac-fat           - builds universal OS X binaries in /usr/local   #
# make mac-install       - installs in /usr/local                         #
#                                                                         #
# make cygwin            - builds for Windows using cygwin                #
#                          (does not function with modem or comm port)    #
# make cygwin-install    - installs files in /usr/local, and /var         #
###########################################################################

subdirs      = server client gateway modules setup extensions logrotate \
               tools man test doc debian Fedora FreeBSD Mac TiVo

Version := $(shell sed 's/.* //; 1q' VERSION)
API := $(shell sed '1d; 2q' VERSION)

# the prefix must end in a - (if part of a name) or a / (if part of a path)
MIPSXCOMPILE = mips-TiVo-linux-
PPCXCOMPILE  = /usr/local/tivo/bin/

# prefix and prefix2 are used on a make, install, and making a package
# prefix3 is used on install to make a package
prefix       = /usr/local
prefix2      = $(prefix)
prefix3      =

settag       = NONE
setname      = NONE
setmod       = NONE
setmac       = NONE
unset        = NONE

RECORDING    = NumberDisconnected.rmd
HUPEXTENSION = hangup-skel

BIN          = $(prefix)/bin
SBIN         = $(prefix)/sbin
SHARE        = $(prefix)/share
ETC          = $(prefix2)/etc
DEV          = $(prefix3)/dev
VAR          = $(prefix3)/var

CONFDIR      = $(ETC)/ncid
NCIDDIR      = $(SHARE)/ncid
MODDIR       = $(SHARE)/ncid/modules
SYSDIR       = $(SHARE)/ncid/sys
EXTDIR       = $(SHARE)/ncid/extensions
ANNDIR       = $(SHARE)/ncid/recordings

DOCDIR       = $(SHARE)/doc/ncid
IMAGEDIR	 = $(SHARE)/pixmaps/ncid
MAN          = $(SHARE)/man
LOG          = $(VAR)/log
RUN          = $(VAR)/run

MANDIR       = $(DOCDIR)/man

CONF         = $(CONFDIR)/ncidd.conf
ALIAS        = $(CONFDIR)/ncidd.alias
BLACKLIST    = $(CONFDIR)/ncidd.blacklist
WHITELIST    = $(CONFDIR)/ncidd.whitelist

TTYPORT      = $(DEV)/modem
CIDLOG       = $(LOG)/cidcall.log
DATALOG      = $(LOG)/ciddata.log
LOGFILE      = $(LOG)/ncidd.log
PIDFILE      = $(RUN)/ncidd.pid

NCIDUPDATE   = $(BIN)/cidupdate
NCIDUTIL     = $(BIN)/ncidutil

WISH         = wish
TCLSH        = tclsh

# local additions to CFLAGS
MFLAGS  = -Wmissing-declarations -Wunused-variable -Wparentheses \
          -Wreturn-type -Wpointer-sign -Wformat

# Documentation for Cygwin, FreeBSD, Mac, and TiVo
# doc/images also is needed and is installed by install-doc
DOC     = doc/NCID-UserManual.md doc/README.docdir \
          doc/ReleaseNotes.md attic/README.attic \
          server/README.server gateway/README.gateways test/README.test \
          client/README.client modules/README.modules tools/README.tools \
          logrotate/README.logrotate

default:
	@echo "make requires an argument, see top of Makefile for description:"
	@echo
	@echo "    make local              # builds for /usr/local and /var"
	@echo "    make install            # installs into /usr/local and /var"
	@echo "    make package            # builds for /usr and /var"
	@echo "    make package-install    # installs into for /usr and /var"
	@echo "    make fedora             # builds for Fedora|Redhat with service files"
	@echo "    make fedora-install     # installs in /usr, /etc, and /var"
	@echo "    make redhat             # builds for Redhat|Fedora, with init files"
	@echo "    make redhat-install     # installs in /usr, /etc, and /var"
	@echo "    make debian             # builds for debian with init files"
	@echo "    make debian-install     # installs in /usr, /etc, and /var"
	@echo "    make raspbian           # builds for Raspbian with init files"
	@echo "    make raspbian-install   # installs in /usr, /etc, and /var"
	@echo "    make ubuntu             # builds for Ubuntu with init files"
	@echo "    make ubuntu-install     # installs in /usr, /etc, and /var"
	@echo "    make tivo-mips          # builds for TiVo in /usr/local, /var"
	@echo "    make tivo-install       # installs in /usr/local, /var"
	@echo "    make tivo-s1            # builds for a series1 in /var/hack"
	@echo "    make tivo-s2            # builds for a series[23] in /var/hack"
	@echo "    make tivo-hack-install  # installs in /var/hack, /var"
	@echo "    make freebsd            # builds for FreeBSD in /usr/local, /var"
	@echo "    make freebsd-install    # installs in /usr/local, /var"
	@echo "    make mac                # builds for Mac in /usr/local, /var"
	@echo "    make mac-fat            # builds for Mac in /usr/local, /var"
	@echo "    make mac-install        # installs in /usr/local, /var"
	@echo "    make cygwin             # builds for windows using Cygwin"
	@echo "    make cygwin-install     # installs in /usr/local"

local-base: serverdir clientdir moduledir extdir recorddir gatewaydir \
	        setupdir tooldir docdir mandir

local: local-base logrotatedir

version.h: VERSION version.h-in
	sed "s/XXX/$(Version)/; s/api/$(API)/" $< > $@

fedoradir:
	cd Fedora; $(MAKE) service service prefix=$(prefix) prefix2=$(prefix2) \
                       prefix3=$(prefix3)

redhatdir:
	cd Fedora; $(MAKE) init service prefix=$(prefix) prefix2=$(prefix2) \
                       prefix3=$(prefix3)

freebsddir:
	cd FreeBSD; $(MAKE) rcd prefix=$(prefix) prefix2=$(prefix2) \
                       prefix3=$(prefix3)

debiandir:
	cd debian; $(MAKE) init prefix=$(prefix) prefix2=$(prefix2) \
                       prefix3=$(prefix3)

tivodir:
	cd TiVo; $(MAKE) prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3) \
                     OSDCLIENT=$(OSDCLIENT)

macdir:
	cd Mac; $(MAKE) prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

moduledir:
	cd modules; $(MAKE) modules prefix=$(prefix) prefix2=$(prefix2) \
                        prefix3=$(prefix3) setmod="$(setmod)" \
                        unset="$(unset)" setmac="$(setmac)"

extdir:
	cd extensions; $(MAKE) extension prefix=$(prefix) prefix2=$(prefix2) \
                        prefix3=$(prefix3)

setupdir:
	cd setup; $(MAKE) setup prefix=$(prefix) prefix2=$(prefix2) \

gatewaydir:
	cd gateway; $(MAKE) gateway prefix=$(prefix) prefix2=$(prefix2) \
                        prefix3=$(prefix3) BIN=$(BIN) SBIN=$(SBIN) \
                        MFLAGS="$(MFLAGS)" STRIP=$(STRIP)

serverdir:
	cd server; $(MAKE) server prefix=$(prefix) prefix2=$(prefix2) \
                       prefix3=$(prefix3) BIN=$(BIN) SBIN=$(SBIN) \
                       MFLAGS="$(MFLAGS)" STRIP=$(STRIP) \
                       RECORDING=$(RECORDING) HUPEXTENSION=$(HUPEXTENSION)

clientdir:
	cd client; $(MAKE) client prefix=$(prefix) prefix2=$(prefix2) \
                       prefix3=$(prefix3) BIN=$(BIN) SBIN=$(SBIN) \
                       MFLAGS="$(MFLAGS)" STRIP=$(STRIP)

tooldir:
	cd tools; $(MAKE) tools prefix=$(prefix) prefix2=$(prefix2) \
                      prefix3=$(prefix3) BIN=$(BIN)

logrotatedir:
	cd logrotate; $(MAKE) logrotate prefix=$(prefix) prefix2=$(prefix2) \
                          prefix3=$(prefix3)

docdir:
	cd doc; $(MAKE) doc prefix=$(prefix) prefix2=$(prefix2) \
                    prefix3=$(prefix3)

mandir:
	cd man; $(MAKE) man prefix=$(prefix) prefix2=$(prefix2) MAN=$(MAN)

recorddir:
	cd recordings ; $(MAKE) recordings prefix=$(prefix) prefix2=$(prefix2) \
                           prefix3=$(prefix3)

package:
	$(MAKE) local prefix=/usr prefix2=

package-install:
	$(MAKE) install prefix=/usr prefix2=

fedora:
	$(MAKE) local fedoradir prefix=/usr prefix2= \
            LOCKFILE=/var/lock/lockdev/LCK.. \
            TTYPORT=$(DEV)/ttyACM0

fedora-install:
	$(MAKE) install install-fedora prefix=/usr prefix2=

redhat:
	$(MAKE) local redhatdir prefix=/usr prefix2= \
            LOCKFILE=/var/lock/lockdev/LCK.. \
            TTYPORT=$(DEV)/ttyACM0

redhat-install:
	$(MAKE) install install-redhat prefix=/usr prefix2=

debian:
	$(MAKE) local debiandir prefix=/usr prefix2= \
            LOCKFILE=/var/lock/LCK.. \
            TTYPORT=$(DEV)/ttyACM0

debian-install:
	$(MAKE) install install-debian prefix=/usr prefix2=

raspbian:
	$(MAKE) local debiandir prefix=/usr prefix2= \
            LOCKFILE=/var/lock/LCK.. \
            TTYPORT=$(DEV)/ttyACM0

raspbian-install:
	$(MAKE) install install-debian prefix=/usr prefix2=

ubuntu:
	$(MAKE) local debiandir prefix=/usr prefix2= \
            LOCKFILE=/var/lock/LCK.. \
            TTYPORT=$(DEV)/ttyACM0

ubuntu-install:
	$(MAKE) install install-debian prefix=/usr prefix2=

tivo-s1:
	$(MAKE) tivo-ppc prefix=/var/hack

tivo-ppc:
	$(MAKE) local-base tivodir \
            CC=$(PPCXCOMPILE)gcc \
            MFLAGS="-DTIVO_S1 -D__need_timeval" \
            LD=$(PPCXCOMPILE)ld \
            RANLIB=$(PPCXCOMPILE)ranlib \
            TTYPORT=/dev/ttyS1 \
            LOCKFILE=/var/tmp/modemlock \
            setname="TiVo requires CLOCAL" \
            setmod="TiVo" OSDCLIENT=tivocid

tivo-s2:
	$(MAKE) tivo-mips prefix=/var/hack

tivo-hack-install:
	$(MAKE) install-server install-client install-record install-doc \
            install-modules install-gateway install-tivo  install-extensions \
            install-tools setmod=TiVo
	@if ! test -d $(MANDIR); then mkdir -p $(MANDIR); fi
	cd man; make index html
	install -m 644 man/README.mandir man/*.html $(DOCDIR)/man

tivo-mips:
	$(MAKE) local-base tivodir fedoradir \
            CC=$(MIPSXCOMPILE)gcc \
            MFLAGS="-std=gnu99" \
            LD=$(MIPSXCOMPILE)ld \
            RANLIB=$(MIPSXCOMPILE)ranlib \
            TTYPORT=/dev/ttyS3 \
            LOCKFILE=/var/tmp/modemlock \
            setname="TiVo requires CLOCAL" \
            setmod="TiVo" OSDCLIENT=tivoncid

tivo-install:
	$(MAKE) install-server install-client install-modules install-record \
              install-doc install-gateway install-man install-logrotate \
              install-extensions setmod=TiVo

freebsd:
	$(MAKE) local-base logrotatedir freebsddir prefix=/usr/local prefix2=$(prefix) \
            LOCKFILE=/var/spool/lock/LCK.. \
            WISH=/usr/local/bin/wish*.* TCLSH=/usr/local/bin/tclsh*.* \
            TTYPORT=/dev/cuaU0 \
            BASH=/usr/local/bin/bash

freebsd-install:
	$(MAKE) install-base install-logrotate install-doc MAN=$(prefix)/man
	cd FreeBSD; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3) \
       MAN=$(prefix)/man

mac-fat: mac-fs
	$(MAKE) local-base macdir \
            unset="tts default" setmac="Mac default" \
            LOCKFILE=/var/spool/uucp/LCK.. \
            TTYPORT=/dev/cu.usbmodem24680241 \
            MFLAGS="-mmacosx-version-min=10.3.9 -arch ppc" STRIP=
	mv server/ncidd server/ncidd.ppc-mac
	mv gateway/sip2ncid gateway/sip2ncid.ppc-mac
	mv gateway/ncid2ncid gateway/ncid2ncid.ppc-mac
	$(MAKE) clean
	$(MAKE) local \
            LOCKFILE=/var/spool/uucp/LCK.. \
            TTYPORT=/dev/cu.usbmodem24680241 \
            MFLAGS="-mmacosx-version-min=10.4 -arch i386 -isysroot /Developer/SDKs/MacOSX10.4u.sdk" STRIP=
	mv server/ncidd server/ncidd.i386-mac
	mv gateway/sip2ncid gateway/sip2ncid.i386-mac
	mv gateway/ncid2ncid gateway/ncid2ncid.i386-mac
	lipo -create server/ncidd.ppc-mac server/ncidd.i386-mac \
         -output server/ncidd
	lipo -create gateway/sip2ncid.ppc-mac gateway/sip2ncid.i386-mac \
         -output gateway/sip2ncid
	lipo -create gateway/ncid2ncid.ppc-mac gateway/ncid2ncid.i386-mac \
         -output gateway/ncid2ncid

mac-fs:
	@if [ -d Mac -a -d mac ]; then \
	echo ; echo ; \
	echo "You must run 'make $(MAKECMDGOALS)' on a case-sensitive Mac OS X filesystem."; \
	echo "Refer to the INSTALL-Mac documentation on how to do this."; \
	echo ;echo ;  \
	exit 2; \
	fi

mac: mac-fs
	$(MAKE) local-base macdir \
            unset="tts default" setmac="Mac default" \
            LOCKFILE=/var/spool/uucp/LCK.. \
            TTYPORT=/dev/cu.usbmodem24680241  \
            MFLAGS="-mmacosx-version-min=10.4" STRIP=

mac-install: mac-fs
	$(MAKE) install-base install-doc install-mac MAN=$(MAN)

cygwin:
	$(MAKE) local \
            MFLAGS=-I/cygdrive/c/WpdPack/Include \
            LDLIBS="-s -L/cygdrive/c/WpdPack/Lib -lwpcap" \
            SBIN=$(prefix)/bin \
            settag="set noserial" \
            TTYPORT=$(DEV)/com1

cygwin-install:
	$(MAKE) install install-doc \
            SBIN=$(prefix)/bin \
            settag="set noserial" \
            TTYPORT=$(DEV)/com1

install-base: install-server install-client install-modules install-record \
	          install-man install-gateway install-setup install-tools \
	          install-extensions

install-doc:
	@if ! test -d $(DOCDIR)/images; then mkdir -p $(DOCDIR)/images; fi
	install -m 644 $(DOC) $(DOCDIR)
	install -m 644 doc/images/* $(DOCDIR)/images

install: install-base install-logrotate

install-fedora:
	cd Fedora; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-redhat:
	cd Fedora; \
       $(MAKE) install-init prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-mac:
	cd Mac; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-debian:
	cd debian; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-tivo:
	cd TiVo; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-gateway:
	cd gateway; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-modules:
	cd modules; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3) \
       setmod="$(setmod)"

install-setup:
	cd setup; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-extensions:
	cd extensions; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-logrotate:
	cd logrotate; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-tools:
	cd tools; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3) \
       ALIAS=$(ALIAS)

install-man:
	cd man; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3) \
       MAN=$(MAN) setmod="$(setmod)"

install-server:
	cd server; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-client:
	cd client; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

install-record:
	cd recordings; \
       $(MAKE) install prefix=$(prefix) prefix2=$(prefix2) prefix3=$(prefix3)

clean:
	for i in $(subdirs); do cd $$i; $(MAKE) clean; cd ..; done

clobber: clean
	rm -f version.h a.out *.log *.zip *.tar.gz *.tgz
	for i in $(subdirs); do cd $$i; $(MAKE) clobber; cd ..; done

distclean: clobber

files: $(FILES)

.PHONY: local ppc-tivo mips-tivo install install-proc \
        install-logrotate install-man install-var clean clobber files
