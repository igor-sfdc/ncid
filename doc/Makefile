# makefile to produce html documentation

INDEX = UserManualIndex.md-in

DOCS  = GettingStarted.md \
        InstallIndex.md \
		INSTALL.md \
		INSTALL-Cygwin.md \
		INSTALL-Fedora.md \
		INSTALL-FreeBSD.md \
		INSTALL-Mac.md \
		INSTALL-Raspbian.md \
		INSTALL-Redhat.md \
		INSTALL-TiVo.md \
		INSTALL-Ubuntu.md \
		INSTALL-Win.md \
        Obtain.md \
		Devices.md \
		Modems.md \
		Gateways.md \
		Clients.md \
        Modules.md \
        Use.md \
        Message.md \
		Alias.md \
		Hangup.md \
        Extensions.md \
        Log.md \
		Tools.md \
		FAQ.md \
		Verbose.md \
		CONTRIBUTORS.md \
		TODO.md \
        GPL.md

API    = NCID-API.md
MANUAL = NCID-UserManual.md
HTML   = $(MANUAL:.md=.html) $(API:.md=.html)

FILES  = Makefile $(DOCS) $(API)

prefix   = /usr/local
prefix2  = $(prefix)
prefix3  =

SHARE    = $(prefix)/share

UMINDEX  = $(INDEX:-in=)

%.md : %.md-in
	@bash mk-manual-date $(DOCS)

doc: $(MANUAL)

sdk: $(MANUAL) $(API) test
	tar -czf NCID-SDK.tar.gz $(MANUAL) $(API) test
	touch sdk

$(MANUAL): $(UMINDEX) $(DOCS)
	cp $(UMINDEX) $(MANUAL)
	# Removed the Last Edited Date from the top of the individual files
	sed '/HEADER Start/,/HEADER End/d;s/## <a name="gpl">/# <a name="gpl">/' \
        $(DOCS) >> $@

html: $(MANUAL) $(API)
	# pandoc is required to convert .md files into .html files
	# see README.docdir for more information
	@if type pandoc; then make $(HTML); \
	else echo pandoc is required to convert .md files into .html files; \
	echo see README.docdir for more information; fi

epub: $(MANUAL) $(API)
	bash mk-epub
	touch epub

$(HTML): $(MANUAL) $(API)

NCID-API.pdf: $(API)
	soffice --headless --convert-to pdf $(API)

test:
	cp -Rp ../test .

clean:

clobber: clean
	rm -f $(UMINDEX) $(MANUAL) *.epub *.html *.bak *.pdf *.gz sdk epub
	rm -fr test

distclean: clobber

.SUFFIXES: .md .html

.md.html : *.md
	#markdown $< > $@
	pandoc -s $< > $@
