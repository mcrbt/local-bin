#!/bin/bash

TITLE="manline"
AUTHOR="Daniel Haase"
CRYEARS="2020"
COPYRIGHT="copyright (c) $CRYEARS $AUTHOR"
VERSION="0.1.1"
CALL="$0"

function check_command
{
	local C="$1"
	if [ $# -eq 0 ] || [ -z "$C" ]; then return 0; fi
	which "$C" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$C\" not found"; exit 1; fi
	return 0
}

function print_version
{
	if [ -z "$TITLE" ]; then TITLE="$(basename $CALL)"; fi
	echo "$TITLE version $VERSION"
	echo " - open manual pages online at https://linux.die.net"
	echo "$COPYRIGHT"
}

function print_usage
{
	if [ -z "$TITLE" ]; then TITLE="$(basename $CALL)"; fi
	print_version
	echo ""
	echo "show Linux manual pages online under <https://linux.die.net/man>"
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

check_command "basename"
check_command "firefox"

if [ $# -eq 2 ]; then SC="$1"; PG="$2"
elif [ $# -eq 1 ]; then
	if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		print_usage; exit 0
	elif [ "$1" == "-V" ] || [ "$1" == "--version" ]; then
		print_version; exit 0
	else SC="1"; PG="$1"; fi
elif [ $# -eq 0 ]; then print_usage; exit 0
else print_usage; exit 2; fi

firefox "https://linux.die.net/man/$SC/$PG" &> /dev/null &
exit 0
