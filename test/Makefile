
test : clean
	touch LICENSE README
	../src/bin/mkver.pl -d ..src/doc/make.ver -e 'env mak'
	if [ ! -f make.env ]; then exit 1; fi
	if [ ! -f make.mak ]; then exit 1; fi
	../src/bin/mkver.pl
	if [ ! -f ver.sh ]; then exit 1; fi
	if [ ! -f ver.env ]; then exit 1; fi

clean :
	-rm ver.* make.* LICENSE README >/dev/null 2>&1
