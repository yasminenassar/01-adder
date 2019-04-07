######################################################

COMPILER=adder
EXT=adder

ZIPFILE=$(COMPILER).zip
ZIPCONTENTS=$(COMPILER).cabal LICENSE Makefile stack.yaml bin c-bits lib tests

######################################################

COMPILEREXEC=stack exec -- $(COMPILER) +RTS -M1G -RTS
GHCICOMMAND=stack exec -- ghci

UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
  FORMAT=elf32
else
ifeq ($(UNAME), Darwin)
  FORMAT=macho
endif
endif

.PHONY: all test build clean distclean tags zip ghci ghcid

all: test

test: clean
	stack test

build:
	stack build

tests/output/%.result: tests/output/%.run
	$< > $@

tests/output/%.run: tests/output/%.o c-bits/main.c
	clang -g -m32 -o $@ c-bits/main.c $<

tests/output/%.o: tests/output/%.s
	nasm -f $(FORMAT) -o $@ $<

tests/output/%.s: tests/input/%.$(EXT)
	$(COMPILEREXEC) $< > $@

clean:
	rm -rf tests/output/*.o tests/output/*.s tests/output/*.dSYM tests/output/*.run tests/output/*.log tests/output/*.result

distclean: clean
	stack clean

tags:
	hasktags -x -c lib/

zip:
	rm -f $(ZIPFILE)
	zip -r $(ZIPFILE) $(ZIPCONTENTS) -x '*/\.*' -x@.gitignore

ghci:
	$(GHCICOMMAND)

ghcid:
	ghcid --command="$(GHCICOMMAND)"
