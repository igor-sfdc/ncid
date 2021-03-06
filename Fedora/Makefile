INIT        = ncidd.init \
              ncid2ncid.init \
              obi2ncid.init \
              rn2ncid.init \
              sip2ncid.init \
              wc2ncid.init \
              yac2ncid.init \
              ncid-mysql.init \
              ncid-mythtv.init \
              ncid-notify.init \
              ncid-page.init \
              ncid-samba.init \
              ncid-speak.init \
              ncid-yac.init \
              ncid-initmodem.init
SERVICE     = ncidd.service \
              ncid2ncid.service \
              obi2ncid.service \
              rn2ncid.service \
              sip2ncid.service \
              wc2ncid.service \
              yac2ncid.service \
              ncid-mysql.service \
              ncid-mythtv.service \
              ncid-notify.service \
              ncid-page.service \
              ncid-samba.service \
              ncid-speak.service \
              ncid-yac.service \
              ncid-initmodem.service
DOC         = README.Fedora
SPEC        = ncid.spec
FILES		= Makefile $(INIT) $(SERVICE) $(DOC) $(SPEC)

VERSION := $(shell sed 's/.* //; 1q' ../VERSION)
API := $(shell sed '1d; 2q' ../VERSION)

prefix		= /usr/local
prefix2		= $(prefix)
prefix3     =
prefix4     =

#SHARP      = ;/\# Source networking/,/NETWORKING.*exit/{N;d}

BIN			= $(prefix)/bin
SBIN		= $(prefix)/sbin
ETC			= $(prefix2)/etc
VAR         = $(prefix3)/VAR
FUN         = $(prefix4)/etc/rc.d/init.d/functions

RCDIR       = $(ETC)/rc.d
INITDIR     = $(RCDIR)/init.d
SERVICEDIR  = $(prefix)/lib/systemd/system
CONFDIR		= $(ETC)/ncid
LOG			= $(VAR)/log
DOCDIR      = $(prefix)/share/doc/ncid

PLSCRIPT    = $(PLSOURCE:.pl=)
SHSCRIPT    = $(SHSOURCE:.sh=)
INITSITE    = $(INIT:.init=)

service: $(SERVICE)

init: $(INITSITE)

install: $(SERVICE) dirs
	install -m 644 $(SERVICE) $(SERVICEDIR)

install-redhat: install-init

install-init: $(INITSITE) initdirs
	install -m 755 $(INITSITE) $(INITDIR)

install-doc:
	@if ! test -d $(DOCDIR); then mkdir -p $(DOCDIR); fi
	install -m 644 $(DOC) $(DOCDIR)

dirs:
	@if ! test -d $(SERVICEDIR); then mkdir -p $(SERVICEDIR); fi

initdirs:
	@if ! test -d $(INITDIR); then mkdir -p $(INITDIR); fi

clean:

clobber: clean
	rm -f $(INITSITE)
	rm -f *.zip *.tar.gz *.tgz

distclean: clobber

files:	$(FILES)

.SUFFIXES: .init

.init : *.init
	sed 's,.*/functions,. $(FUN),$(SHARP)' $< > $@
	chmod +x $@
