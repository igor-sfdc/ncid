SHEXT     = hangup-skel.sh hangup-message-skel.sh hangup-closed-skel.sh \
            hangup-calls.sh
PLEXT     =
FILES     = README.extensions Makefile $(SHEXT) $(PLEXT)

prefix    = /usr/local
prefix2   = $(prefix)
prefix3   =

setmod    = NONE
setmac    = NONE
unset     = NONE

SHARE     = $(prefix)/share
NCIDDIR   = $(SHARE)/ncid
EXTDIR    = $(NCIDDIR)/extensions

BIN       = $(prefix)/bin
ETC       = $(prefix2)/etc

EXTENSION = $(SHEXT:.sh=) $(PLEXT:.pl=)

extension: $(EXTENSION)

install: install-extension

install-extension: $(EXTENSION)
	@if test ! -d $(EXTDIR); then mkdir -p $(EXTDIR); fi
	install -m 755 $(EXTENSION) $(EXTDIR)

clean:

clobber: clean
	rm -f $(EXTENSION)
	rm -f *.zip *.tar.gz *.tgz

distclean: clobber

files:	$(FILES)

.SUFFIXES: .sh .pl

.sh : *.sh
	sed 's,/usr/local/etc,$(ETC),' $< > $@
	chmod +x $@

.pl : *.pl
	sed 's,/usr/local/etc,$(ETC),' $< > $@
	chmod +x $@
