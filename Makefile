
include ver.mak

# --------------------
first : ver.mak
	which epm
	which epminstall

build epm.list : ver.mak doc/ver.sh.default
	-rm -rf dist >/dev/null 2>&1
	mkdir -p dist/usr/local/bin
	mkdir -p dist/usr/local/man/man1
	mkdir -p dist/usr/local/share/doc/epm-helpers
	chmod a+rx mkver.pl patch-epm-list
	cp mkver.pl patch-epm-list dist/usr/local/bin
	pod2man mkver.pl dist/usr/local/man/man1/mkver.pl.1
	pod2man patch-epm-list dist/usr/local/man/man1/patch-epm-list.1
	gzip dist/usr/local/man/man1/*
	cp doc/* dist/usr/local/share/doc/epm-helpers
	cp README.md dist/usr/local/share/doc/epm-helpers
	find dist -executable -exec chmod a+rx {} \;
	mkepmlist -u root -g root --prefix / dist | ./patch-epm-list -f ./epm.patch >epm.list

clean :
	-rm ver.cs ver.env ver.epm ver.h ver.java ver.mak ver.pl ver.xml >/dev/null 2>&1
	-rm -rf dist tmp >/dev/null 2>&1
	-find * -name '*~' -exec rm {} \; >/dev/null 2>&1

dist-clean : clean
	-cd test; make clean
	-rm -rf pkg >/dev/null 2>&1

package : epm.list ver.epm epm.require epm.patch patch-epm-list
	-rm -rf pkg >/dev/null 2>&1
	mkdir pkg
	epm -v -f native -m linux-noarch --output-dir pkg epm-helpers ver.epm
	epm -v -f portable -m linux-noarch --output-dir pkg epm-helpers ver.epm

# --------------------
ver.mak ver.epm ver.env : ver.sh mkver.pl patch-epm-list
	./mkver.pl -d ver.sh -e 'mak env epm' >/dev/null 2>&1

doc/ver.sh.default : mkver.pl
	-mkdir tmp
	cd tmp; ../mkver.pl -e env >/dev/null 2>&1
	mv -f tmp/ver.sh doc/ver.sh.default
