.PHONY: all clean

all:
	ooc woot -gcc -D_BSD_SOURCE -driver=sequence -noclean -g -shout -v

clean:
	rm -rf ooc_tmp
