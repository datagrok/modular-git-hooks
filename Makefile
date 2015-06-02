#!/usr/bin/make -rf

#
# GNU Makefile for modular-git-hooks
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

# This Makefile merely enables the command "make && make test" to behave as
# expected.


default:
	# Nothing to compile.

test:
	cd tests/ && $(MAKE) -rj
