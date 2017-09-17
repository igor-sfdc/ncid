SHMOD     = ncid-page.sh ncid-samba.sh ncid-speak.sh \
            ncid-alert.sh ncid-initmodem.sh ncid-kpopup.sh ncid-mysql.sh \
            ncid-mythtv.sh ncid-notify.sh ncid-skel.sh ncid-wakeup.sh \
            ncid-yac.sh
PLMOD     =
DIST      = ncid-mysql.conf-in ncid-notify.conf-in ncid-speak.conf-in
CONF      = ncid-kpopup.conf ncid-mythtv.conf ncid-page.conf \
            ncid-alert.conf ncid-samba.conf ncid-skel.conf ncid-yac.conf
FILES     = README.modules Makefile $(SHMOD) $(PLMOD) $(DIST)

prefix    = /usr/local
prefix2   = $(prefix)
prefix3   =

setmod    = NONE
setmac    = NONE
unset     = NONE

SHARE     = $(prefix)/share
NCIDDIR   = $(SHARE)/ncid
MODDIR    = $(NCIDDIR)/modules

BIN       = $(prefix)/bin
ETC       = $(prefix2)/etc

CONFDIR   = $(ETC)/ncid
CONFMOD   = $(ETC)/ncid/conf.d

MODULES   = $(SHMOD:.sh=) $(PLMOD:.pl=)

CONFFILE  = $(DIST:-in=)

modules: $(MODULES) $(CONFFILE)

install: install-etc install-modules

install-modules: $(MODULES)
	# The location for the modules changed, this deletes any
	# distributed modules from the old directory and moves
	# any user created modules to the new directory.  It
	# then installs the current modules.
	@if test ! -d $(MODDIR); then mkdir -p $(MODDIR); fi
	for i in $(MODULES); do rm -f $(NCIDDIR)/$$i; done
	@if ls $(NCIDDIR)/ncid-* > /dev/null 2>&1; then \
		mv $(NCIDDIR)/ncid-* $(MODDIR); fi
	install -m 755 $(MODULES) $(MODDIR)

install-etc: $(CONFFILE)
	@if test ! -d $(CONFMOD); then mkdir -p $(CONFMOD); fi
	for conf in $(CONFFILE) $(CONF); do \
		test -f $(CONFMOD)/$$conf &&  \
			install -m 644 $$conf $(CONFMOD)/$$conf.new || \
			install -m 644 $$conf $(CONFMOD); \
	done

clean:

clobber: clean
	rm -f $(MODULES) $(CONFFILE)
	rm -f *.zip *.tar.gz *.tgz

distclean: clobber

files:	$(FILES)

.SUFFIXES: .sh .pl -in

.sh : *.sh
	sed 's,/usr/local/etc,$(ETC),; s,/usr/local/share,$(SHARE),' $< > $@
	chmod 755 $@

.pl : *.pl
	sed 's,/usr/local/etc/ncid,$(CONFDIR),' $< > $@
	chmod +x $@

-in : *-in
	sed '/$(setmod)/s/https/http/; s,/usr/local/bin,$(BIN),; s,/usr/local/etc,$(ETC),; s,/usr/local/share/ncid,$(MOD),; /$(unset)/s,^,#,; /$(setmac)/s,^#,,' $< > $@
