DIST        = ncidd.init ncid2ncid.init obi2ncid.init rn2ncid.init \
              wc2ncid.init sip2ncid.init yac2ncid.init \
              ncid-initmodem.init ncid-mysql ncid-mythtv.init \
              ncid-notify.init ncid-page.init ncid-samba.init \
              ncid-speak.init ncid-yac.init
DOC         = Makefile.Debain
FILES		= Makefile $(DIST) $(DOC)

prefix		= /usr/local
prefix2		= $(prefix)
prefix3     =

BIN			= $(prefix)/bin
SBIN		= $(prefix)/sbin
ETC			= $(prefix2)/etc
VAR         = $(prefix3)/VAR

INIT        = $(ETC)/init.d
CONFDIR		= $(ETC)/ncid
LOG			= $(VAR)/log
DOCDIR      = $(prefix)/share/doc/lcdncid

PLSCRIPT    = $(PLSOURCE:.pl=)
SHSCRIPT    = $(SHSOURCE:.sh=)
SITE        = $(DIST:.init=)

init: $(SITE)

install: $(SITE)
	@if ! test -d $(INIT); then mkdir -p $(INIT); fi
	install -m 755 $(SITE) $(INIT)

install-doc: $(DOC)
	@if ! test -d $(DOCDIR); then mkdir -p $(DOCDIR); fi
	install -m 644 $(DOC) $(DOCDIR)

clean:

clobber: clean
	rm -f $(SITE)
	rm -f *.zip *.tar.gz *.tgz

distclean: clobber

files:	$(FILES)

.SUFFIXES: .init

.init : *.init
	sed '/ConfigDir/s,/usr/local/etc/ncid,$(CONFDIR),' $< > $@
	chmod +x $@
