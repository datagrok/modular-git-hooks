#!/usr/bin/make -rf

# A homegrown test runner for modular-git-hooks.
#
# TODO FIXME: replace this with a proper unit testing framework or something.
# TODO FIXME: incorporate git's unit test shell libraries?

testscripts=$(wildcard t[0-9][0-9][0-9][0-9]*)
testresults=$(patsubst %,test-results/%.success,$(testscripts))

# Work around lack of 'readlink -f' in OSX.
ifeq ($(shell uname -s), Darwin)
	canonicalize:=python -c 'import sys,os;print(os.path.realpath(sys.argv[1]))'
else
	canonicalize:=readlink -f
endif
export mgh_build_dir=$(shell $(canonicalize) ..)

tests: tests_preamble $(testresults)
	# All tests completed successfully.

tests_preamble:
	# Tests beginning. Tests have failed unless you see the text "all tests
	# completed successfully" at the end of execution.

# Run each test that has been modified since the last output; capture their
# output to files. If any fail, re-run with a DEBUG flag set and don't capture
# output (for use with Travis CI, etc.)
test-results/%.success: ./% test-results $(mgh_build_dir)/dispatch $(mgh_build_dir)/install-dispatch Makefile
	./$< >$(@:.success=.out) 2>$(@:.success=.err) && touch $@ || DEBUG=1 ./$<

test-results:
	mkdir test-results

clean:
	# Cleaning up any previous execution.
	rm -rf test-results
