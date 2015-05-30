#!/usr/bin/make -rf

#
# A GNU Make-based homebrew test runner for modular-git-hooks.
#
# Copyright 2015 Michael F. Lamb <http://datagrok.org>
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# License: GPLv3 http://www.gnu.org/licenses/gpl.html
#

# This Makefile implements a testing script harness for modular-git-hooks. It
# is similar to, and takes many ideas from the similar test runner [used by the
# 'git' project itself][1], but it's not a direct fork of that code.
#
# [1]: https://github.com/git/git/tree/master/t

# TODO FIXME: replace this with a proper unit testing framework or something.
# TODO FIXME: incorporate git's unit test shell libraries?


testscripts=$(wildcard t[0-9][0-9][0-9][0-9]*)
testresults=$(patsubst %,test-results/%.success,$(testscripts))

# keep an absolute reference to the top level of this project
export mgh_build_dir=$(shell cd ..; pwd -P)

tests: tests_preamble $(testresults)
	# All tests completed successfully.

tests_preamble:
	# Tests beginning. Watch for the text "all tests completed."

# Run each test that has been modified since the last output; capture their
# output to files. If any fail, re-run with a DEBUG flag set and don't capture
# output (for use with Travis CI, etc.)
test-results/%.success: ./% test-results $(mgh_build_dir)/dispatch $(mgh_build_dir)/install-dispatch Makefile
	./test-wrapper ./$< && touch $@

test-results:
	mkdir test-results

clean:
	# Cleaning up any previous execution.
	rm -rf test-results
