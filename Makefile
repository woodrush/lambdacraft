# This setting needs to be changed on a Mac to compile tromp.c (make ./bin/tromp, make test-blc-tromp, etc.).
# Please see README.md for details.
CC=cc

ULAMB=./bin/clamb
SBCL=sbcl

ASC2BIN=./bin/asc2bin

target_ulamb=./out/a.ulamb


test: $(ULAMB) $(ASC2BIN)
	sbcl --script examples/ulamb.cl > a.ulamb
	cat a.ulamb | $(ASC2BIN) | $(ULAMB) -u  > a.ulamb.out
	printf 'A' > a.ulamb.out.expected
	diff a.ulamb.out a.ulamb.out.expected || ( exit 1 )
	rm a.ulamb.out a.ulamb.out.expected
	@echo "\n    Test passed.\n"


./build/clamb/clamb.c:
	mkdir -p ./build
	cd build; git clone https://github.com/irori/clamb

$(ULAMB): ./build/clamb/clamb.c
	cd build/clamb; $(CC) -O2 clamb.c -o clamb
	mv build/clamb/clamb ./bin
	chmod 755 $(ULAMB)

.PHONY: clamb
clamb: $(ULAMB)


$(ASC2BIN): ./tools/asc2bin.c
	cd build; $(CC) ../tools/asc2bin.c -O2 -o asc2bin
	mv build/asc2bin ./bin
	chmod 755 $(ASC2BIN)

.PHONY: asc2bin
asc2bin: $(ASC2BIN)
