MANSRC1  = ncid.1-in hangup-calls.1-in hangup-closed-skel.1-in \
           hangup-message-skel.1-in hangup-skel.1-in \
           ncid2ncid.1-in yac2ncid.1-in \
           ncid-initmodem.1-in ncid-kpopup.1-in ncid-notify.1-in \
           ncid-page.1-in ncid-alert.1-in ncid-samba.1-in ncid-speak.1-in \
           ncid-mythtv.1-in ncid-skel.1-in ncid-mysql.1-in ncid-wakeup.1-in \
           ncid-yac.1-in ncid-yearlog.1-in ncid-email2ncid-setup.1-in \
           ncid-setup.1-in
MANSRC5  = ncidd.blacklist.5 ncidd.whitelist.5 ncid.conf.5 \
           ncidd.conf.5 ncidd.alias.5 \
           email2ncid.conf.5 ncid2ncid.conf.5 obi2ncid.conf.5 rn2ncid.conf.5 \
           sip2ncid.conf.5 wc2ncid.conf.5 yac2ncid.conf.5
MANSRC7  = ncid-modules.7-in ncidtools.7-in ncidgateways.7-in
MANSRC8  = ncidd.8-in sip2ncid.8-in ncid-mysql-setup.8-in
PERLMAN1 = cidalias.1 cidcall.1 cidupdate.1 obi2ncid.1 rn2ncid.1 wc2ncid.1 \
           wct.1 ncidutil.1 email2ncid.1
INDEX    = index.md
INDEXADD = index-add.md
IMAGE    = ncid.gif
MANSRC   = $(MANSRC1) $(MANSRC5) $(MANSRC7) $(MANSRC8) $(PERLMAN1)
FILES    = Makefile $(MANSRC) $(MARKDOWN)

prefix   = /usr/local
prefix2  = $(prefix)
prefix3  =

SHARE    = $(prefix)/share
MODULE   = $(SHARE)/module
ETC      = $(prefix2)/etc

MANMD    = man.md

MAN      = $(SHARE)/man
MAN1     = $(MAN)/man1
MAN5     = $(MAN)/man5
MAN7     = $(MAN)/man7
MAN8     = $(MAN)/man8

DIST1    = $(MANSRC1:-in=)
DIST7    = $(MANSRC7:-in=)
DIST8    = $(MANSRC8:-in=)

man: $(DIST1) $(DIST7) $(DIST8) $(PERLMAN1)
	touch man

%.1 : %.1-in
	sed 's,/etc,$(ETC),;s,/usr/share,$(SHARE),' $< > $@

%.7 : %.7-in
	sed 's,/etc,$(ETC),;s,/usr/share,$(SHARE),' $< > $@

%.8 : %.8-in
	sed 's,/etc,$(ETC),;s,/usr/share,$(SHARE),' $< > $@

epub: all-html
	sh mk-epub
	touch epub

html: man index $(DIST1:.1=.1.html) $(MANSRC5:.5=.5.html) $(DIST7:.7=.7.html) $(DIST8:.8=.8.html) $(PERLMAN1:.1=.1.html)
	cd ../logrotate; make logrotate prefix=/usr prefix2=
	man2html -M man.html ../logrotate/ncidrotate.1 > ncidrotate.1.html
	man2html -M man.html ../logrotate/ncidrotate.conf.5 > ncidrotate.conf.5.html
	man2html -M man.html ../TiVo/ncid-tivo.1 > ncid-tivo.1.html
	touch html

html-all: html index-big
	pod2man ../../lcdncid/lcdncid.pl | man2html -M man.html > lcdncid.1.html
	man2html -M man.html ../../lcdncid/lcdncid.conf.5 > lcdncid.conf.5.html
	man2html -M man.html ../../out2osd/out2osd.1 > out2osd.1.html
	touch html-all

$(IMAGE):
	cp -p ../client/ncid.gif .

$(MANMD): $(INDEX) $(IMAGE)
	cat $(INDEX) $(INDEXADD) > $(MANMD)

index: $(INDEX) $(IMAGE)
	cat $(INDEX) > $(MANMD)
	@if type pandoc; then make md2html; \
	else echo pandoc is required to convert .md files into .html files; \
	echo see README.docdir for more information; fi
	touch index

index-big: $(INDEX) $(INDEXADD) $(IMAGE)
	cat $(INDEX) $(INDEXADD) > $(MANMD)
	@if type pandoc; then make md2html; \
	else echo pandoc is required to convert .md files into .html files; \
	echo see README.docdir for more information; fi
	touch index-big

md2html: $(MANMD:.md=.html)

install: install-man

email2ncid.1:
	pod2man ../gateway/email2ncid.pl | sed 's,/etc,$(ETC),' > $@

obi2ncid.1:
	pod2man ../gateway/obi2ncid.pl | sed 's,/etc,$(ETC),' > $@

rn2ncid.1:
	pod2man ../gateway/rn2ncid.pl | sed 's,/etc,$(ETC),' > $@

wc2ncid.1:
	pod2man ../gateway/wc2ncid.pl | sed 's,/etc,$(ETC),' > $@

cidalias.1:
	pod2man ../tools/cidalias.pl | sed 's,/etc,$(ETC),' > $@

cidcall.1:
	pod2man ../tools/cidcall.pl | sed 's,/etc,$(ETC),' > $@

cidupdate.1:
	pod2man ../tools/cidupdate.pl | sed 's,/etc,$(ETC),' > $@

ncidutil.1:
	pod2man ../tools/ncidutil.pl | sed 's,/etc,$(ETC),' > $@

wct.1:
	pod2man ../tools/wct.pl | sed 's,/etc,$(ETC),' > $@

install-man: $(MANSRC) dirs
	cd $(MAN1); rm -f $(DIST1) $(PERLMAN1)
	cd $(MAN5); rm -f $(MANSRC5)
	cd $(MAN7); rm -f $(DIST7)
	cd $(MAN8); rm -f $(DIST8)
	install -m 644 $(DIST1) $(PERLMAN1) $(MAN1)
	install -m 644 $(MANSRC5) $(MAN5)
	install -m 644 $(DIST7) $(MAN7)
	install -m 644 $(DIST8) $(MAN8)

dirs:
	@if ! test -d $(MAN1); then mkdir -p $(MAN1); fi
	@if ! test -d $(MAN5); then mkdir -p $(MAN5); fi
	@if ! test -d $(MAN7); then mkdir -p $(MAN7); fi
	@if ! test -d $(MAN8); then mkdir -p $(MAN8); fi

clean:

clobber: clean
	rm -f txt *.man *.txt *.html *.epub *.zip *.tar.gz *.tgz
	rm -f $(PERLMAN1) $(IMAGE) $(MANMD) $(DIST1) $(DIST7) $(DIST8)
	rm -f man html html-all epub index index-big
	cd ../logrotate; make clobber

distclean: clobber

files: $(FILES)

.SUFFIXES: .1 .5 .7 .8 .1.txt .5.txt .7.txt .8.txt .1.html .5.html .7.html .8.html .md .html

.1.1.txt : *.1
	nroff -man $< | col -bx > $@

.5.5.txt : *.5
	nroff -man $< | col -bx > $@

.7.7.txt : *.7
	nroff -man $< | col -bx > $@

.8.8.txt : *.8
	nroff -man $< | col -bx > $@

.1.1.html : *.1
	man2html -M man.html $< > $@

.5.5.html : *.5
	man2html -M man.html $< > $@

.7.7.html : *.7
	man2html -M man.html $< > $@

.8.8.html : *.8
	man2html -M man.html $< > $@

.md.html : *.md
	pandoc -s $< > $@
