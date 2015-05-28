#!/usr/bin/make -rf

# A homegrown test runner for modular-git-hooks.
#
# TODO FIXME: replace this with a proper unit testing framework or something.
# TODO FIXME: incorporate git's unit test shell libraries?

testscripts=$(wildcard t[0-9][0-9][0-9][0-9]*)
testresults=$(patsubst %,test-results/%.out,$(testscripts))
dispatch=$(shell readlink -f ../dispatch)
installdispatch=$(shell readlink -f ../install-dispatch)
export dispatch
export installdispatch

tests: tests_preamble $(testresults)
	# All tests completed successfully.

tests_preamble:
	# Tests beginning. Tests have failed unless you see the text "all tests
	# completed successfully" at the end of execution.

test-results/%.out: ./% test-results $(dispatch) $(installdispatch) Makefile
	./$< >$@ 2>$(@:.out=.err)

test-results:
	mkdir test-results

clean:
	# Cleaning up any previous execution.
	rm -rf test-results
