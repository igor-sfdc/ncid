PLSOURCE	= cidcall.pl cidalias.pl cidupdate.pl wct.pl ncidutil.pl
SHSOURCE	= ncid-yearlog.sh
ETCFILE     =
FILES		= Makefile $(PLSOURCE) $(SHSOURCE) $(MANSRC)
DIST        =

prefix		= /usr/local
prefix2		= $(prefix)
prefix3		=

BIN			= $(prefix)/bin
SBIN		= $(prefix)/sbin
SHARE       = $(prefix)/share
ETC			= $(prefix2)/etc
VAR         = $(prefix3)/var

INIT        = $(ETC)/rc.d/init.d
CONFDIR		= $(ETC)/ncid
LOG			= $(VAR)/log
MAN         = $(SHARE)/man

NCIDDIR   = $(SHARE)/ncid
SYSDIR    = $(NCIDDIR)/sys

CONF		= $(CONFDIR)/ncidd.conf
ALIAS		= $(CONFDIR)/ncidd.alias
BLACKLIST	= $(CONFDIR)/ncidd.blacklist
WHITELIST	= $(CONFDIR)/ncidd.whitelist
CIDLOG  	= $(LOG)/cidcall.log
DATALOG		= $(LOG)/ciddata.log
MAN1		= $(MAN)/man1

PLSCRIPT    = $(PLSOURCE:.pl=)
SHSCRIPT    = $(SHSOURCE:.sh=)
SITE        = $(DIST:-in=)

VERSION := $(shell sed 's/.* //; 1q' ../VERSION)
API := $(shell sed '1d; 2q' ../VERSION)

tools: $(PLSCRIPT) $(SHSCRIPT) $(SITE)

install: install-script install-sys

install-script: $(PLSCRIPT)
	install -m 755 $(PLSCRIPT) $(BIN)

install-sys: $(SHSCRIPT)
	@if test ! -d $(SYSDIR); then mkdir -p $(SYSDIR); fi
	install -m 755 $(SHSCRIPT) $(SYSDIR)

clean:

clobber: clean
	rm -f $(PLSCRIPT) $(SHSCRIPT) $(SITE)
	rm -f *.zip *.tar.gz *.tgz rm *.log

distclean: clobber

files:	$(FILES)

.SUFFIXES: .pl .sh -in

.pl : *.pl
	sed 's,/etc/ncid/ncidd.alias,$(ALIAS),; s,/etc/ncid/ncidd.blacklist,$(BLACKLIST),; s,/etc/ncid/ncidd.whitelist,$(WHITELIST),; s,/etc/ncid/ncidd.conf,$(CONF),;s/XxXxX/$(VERSION)/;s,/var/log/cidcall.log,$(CIDLOG),' $< > $@
	chmod +x $@

.sh : *.sh
	sed '/ConfigDir/s,/usr/local/etc/ncid,$(CONFDIR),;s/XxXxX/$(VERSION)/' $< > $@
	chmod 755 $@

-in : *-in
	sed '/ConfigDir/s,/usr/local/etc/ncid,$(CONFDIR),' $< > $@
