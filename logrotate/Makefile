SHSCRIPT  = ncidrotate.sh
ETCCONF   = ncidrotate.conf
LOGCONF   = ncid.logrotate
MANSRC1   = ncidrotate.1-in
MANSRC5   = ncidrotate.conf.5
MANSRC    = $(MANSRC1) $(MANSRC5)
FILES     = README.logrotate Makefile \
            $(SHSCRIPT) $(ETCCONF) $(LOGCONF) $(MANSRC)

prefix    = /usr/local
prefix2   = $(prefix)
prefix3   =

SHARE     = $(prefix)/share
ETC       = $(prefix2)/etc
CONFDIR   = $(ETC)/ncid
ROTATEDIR = $(ETC)/logrotate.d

NCIDDIR   = $(SHARE)/ncid
SYSDIR    = $(NCIDDIR)/sys
MODDIR    = $(NCIDDIR)/modules
ANNDIR    = $(NCIDDIR)/recordings
EXTDIR    = $(NCIDDIR)/extensions

MANDIR    = $(SHARE)/man
MAN1      = $(MANDIR)/man1
MAN5      = $(MANDIR)/man5

ROTATE  = $(LOGCONF:.logrotate=)
SCRIPTS = $(SHSCRIPT:.sh=)

DIST1   = $(MANSRC1:-in=)

logrotate: $(ROTATE) $(SCRIPTS) $(DIST1)

%.1 : %.1-in
	sed 's,/etc,$(ETC),;s,/usr/share,$(SHARE),' $< > $@

install: install-etc install-scripts install-logrotate install-man

install-scripts: $(SCRIPTS)
	# The location for the logrotate script changed,
	# This deletes the script from the old directory
	# and installs the current script in the new directory.
	@if test ! -d $(SYSDIR); then mkdir -p $(SYSDIR); fi
	cd $(NCIDDIR); rm -f $(SCRIPTS)
	install -m 755 $(SCRIPTS) $(SYSDIR)

install-etc: $(ETCCONF)
	@if test ! -d $(CONFDIR); then mkdir -p $(CONFDIR); fi
	@if test -f $(CONFDIR)/$(ETCCONF); \
		then install -m 644 $(ETCCONF) $(CONFDIR)/$(ETCCONF).new; \
		else install -m 644 $(ETCCONF) $(CONFDIR); \
	fi

install-logrotate: $(ROTATE)
	@if test ! -d $(ROTATEDIR); then mkdir -p $(ROTATEDIR); fi
	install -m 644 ncid $(ROTATEDIR)

install-man: $(MANSRC1) $(MANSRC5)
	@if ! test -d $(MAN1); then mkdir -p $(MAN1); fi
	cd $(MAN1); rm -f $(MANSRC1)
	install -m 644 $(MANSRC1) $(MAN1)
	@if ! test -d $(MAN5); then mkdir -p $(MAN5); fi
	cd $(MAN5); rm -f $(MANSRC5)
	install -m 644 $(MANSRC5) $(MAN5)

clean:

clobber: clean
	rm -f $(ROTATE) $(SCRIPTS) $(DIST1)
	rm -f *.zip *.tar.gz *.tgz

distclean: clobber

files:	$(FILES)

.SUFFIXES: .sh .logrotate

.sh : *.sh
	sed 's,/usr/local/etc,$(ETC),' $< > $@
	chmod 755 $@

.logrotate : *.logrotate
	sed 's,/usr/local/share,$(SHARE),' $< > $@
