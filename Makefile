
build :
	./mkver.pl -e env
	rm ver.env
	mv -f ver.sh doc/ver.sh.default
#	cp mkver.pl patch-epm-list dist/xxx
#	pod2man mkver.pl dist/xxx/mkver.pl.1
#	pod2man patch-epm-list dist/xxx/patch-epm-list.1

clean :
	find * -name '*~' -exec rm {} \;

dist-clean : clean
	cd test; make clean

