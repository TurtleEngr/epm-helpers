
build :
	./mkver.pl -e env
	rm ver.env
	mv -f ver.sh doc/ver.sh.default

clean :
	find * -name '*~' -exec rm {} \;

dist-clean : clean
	cd test; make clean

