project=xc-firmware
implementation=xc8

all: erase program

erase:
	./flash.sh $(project) $(implementation) erase

program:
	./flash.sh $(project) $(implementation) program

verify:
	./flash.sh $(project) $(implementation) verify

test:
	./flash.sh $(project) $(implementation) fast_program

xc8:
	implementation=xc8 make
