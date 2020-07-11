#!/bin/bash
##
## manline - open manual pages online at https://www.man7.org
## Copyright (C) 2020 Daniel Haase
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/gpl.txt>.
##

TITLE="manline"
AUTHOR="Daniel Haase"
CRYEARS="2020"
COPYRIGHT="copyright (c) $CRYEARS $AUTHOR"
VERSION="0.2.0"
CALL="$0"

function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
	return 0
}

function print_version
{
	if [ -z "$TITLE" ]; then TITLE="$(basename $CALL)"; fi
	echo "$TITLE version $VERSION"
	echo " - open manual pages online at https://www.man7.org"
	echo "$COPYRIGHT"
}

function print_usage
{
	if [ -z "$TITLE" ]; then TITLE="$(basename $CALL)"; fi
	print_version
	echo ""
	echo "show Linux manual pages online under <https://www.man7.org>"
	echo "for man pages not installed locally"
	echo ""
	echo "usage:  $TITLE [<section>] <page>"
	echo "        $TITLE [-V | -h]"
	echo ""
	echo "  <section>"
	echo "    the manual page section (1-8, L, N)"
	echo "    (optional, defaults to 1 - \"user commands\")"
	echo ""
	echo "  <page>"
	echo "    the manual page (name of command, system call, ...)"
	echo ""
	echo "  -V | --version"
	echo "    print version information"
	echo ""
	echo "  -h | --help"
	echo "    print this help message"
	echo ""
}

checkcmd "basename"
checkcmd "firefox"

if [ $# -eq 2 ]; then SC="$1"; PG="$2"
elif [ $# -eq 1 ]; then
	if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		print_usage; exit 0
	elif [ "$1" == "-V" ] || [ "$1" == "--version" ]; then
		print_version; exit 0
	else SC="1"; PG="$1"; fi
elif [ $# -eq 0 ]; then print_usage; exit 0
else print_usage; exit 2; fi

if [ -z "$PG" ] || [[ "$PG" == "-"* ]]; then
	echo "invalid manual page \"$PG\""
	exit 2
fi

if [ -z "$SC" ]; then SC=1
elif [[ "$SC" == "-"* ]]; then
	echo "invalid manual section \"$SC\""
	exit 2
fi

firefox "https://www.man7.org/linux/man-pages/man${SC}/${PG}.${SC}.html" &> /dev/null &
if [ $? -ne 0 ]; then echo "failed to open manual page of \"$PG\""; exit 3; fi

exit 0
