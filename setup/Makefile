SHSETUP   = ncid-mysql-setup.sh ncid-email2ncid-setup.sh
SHSCRIPT  = ncid-setup.sh
PLSETUP   =
DIST      = 
CONF      =
FILES     = README.setup Makefile $(SHSETUP) $(PLSETUP) $(DIST) $(CONF)

VERSION := $(shell sed 's/.* //; 1q' ../VERSION)
API := $(shell sed '1d; 2q' ../VERSION)

prefix    = /usr/local
prefix2   = $(prefix)
prefix3   =

setmod    = NONE
setmac    = NONE
unset     = NONE

SHARE     = $(prefix)/share
NCIDDIR   = $(SHARE)/ncid
SETUPDIR  = $(NCIDDIR)/setup

BIN       = $(prefix)/bin
SBIN      = $(prefix)/sbin
ETC       = $(prefix2)/etc

CONFDIR   = $(ETC)/ncid

SETUPS    = $(SHSETUP:.sh=) $(PLSETUP:.pl=)
SCRIPT    = $(SHSCRIPT:.sh=)

CONFFILE  = $(DIST:-in=)

setup: $(SETUPS) $(CONFFILE) $(SCRIPT)

install: setup install-config
	@if test ! -d $(BIN); then mkdir -p $(BIN); fi
	install -m 755 $(SCRIPT) $(BIN)

install-config: $(SHCONFIG)
	@if test ! -d $(SETUPDIR); then mkdir -p $(SETUPDIR); fi
	install -m 755 $(SETUPS) $(SETUPDIR)

install-etc: $(CONFFILE)
	@if test ! -d $(CONFDIR); then mkdir -p $(CONFDIR); fi
	for conf in $(CONFFILE) $(CONF); do \
		test -f $(CONFDIR)/$$conf &&  \
			install -m 644 $$conf $(CONFDIR)/$$conf.new || \
			install -m 644 $$conf $(CONFDIR); \
	done

clean:
	rm -f procmailrc

clobber: clean
	rm -f $(SCRIPT) $(SETUPS) $(CONFFILE)
	rm -f *.zip *.tar.gz *.tgz

distclean: clobber

files:	$(FILES)

.SUFFIXES: .sh .pl

.sh : *.sh
	sed 's,/usr/local,$(prefix),;s/XxXxX/$(VERSION)/' $< > $@
	chmod 755 $@

.pl : *.pl
	sed 's,/usr/local/etc/ncid,$(CONFDIR),' $< > $@
	chmod +x $@
