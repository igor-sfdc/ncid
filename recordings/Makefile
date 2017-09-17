# makefile to produce html documentation

RMD  = NumberDisconnected.rmd CallingDeposit.rmd NotInService.rmd
PVF  = NumberDisconnected.pvf CallingDeposit.pvf NotInService.pvf

FILES = Makefile $(RND) $(PVF)

prefix   = /usr/local
prefix2  = $(prefix)
prefix3  =

SHARE    = $(prefix)/share
NCIDDIR  = $(SHARE)/ncid
ANNDIR   = $(NCIDDIR)/recordings
DOCDIR   = $(SHARE)/doc/ncid
RECDIR   = $(DOCDIR)/recordings

recordings: $(RMD) $(PVF)

install: recordings
	# The location for the recordings changed, this deletes any
	# distributed recordings from the old directory and moves
	# any user created recordings to the new directory.
	# It then installs the current recordings.
	@if ! test -d $(ANNDIR); then mkdir -p $(ANNDIR); fi
	cd $(NCIDDIR); rm -f NumberDisconnected.???
	@if ls $(NCIDDIR)/*.??? > /dev/null 2>&1; then mv $(NCIDDIR)/*.??? $(ANNDIR)/.; fi
	install -m 644 $(RMD) $(ANNDIR)
	@if ! test -d $(RECDIR); then mkdir -p $(RECDIR); fi
	install -m 644 README.recordings $(PVF) $(RECDIR)

clean:

clobber: clean

distclean: clobber
