#!/bin/bash
##
## fdiff - wrapper around the "diff" command
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

FILE1=""
FILE2=""

function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 3; fi
	return 0
}

function print_help()
{
	echo ""
	echo "usage:  $(basename $0) [-n|-u|-a|-r|-i|-d] <file1> <file2>"
	echo "        $(basename $0) <-h|--help>"
	echo ""
	echo "  -n | --no-line-numbers"
	echo "    do not print line numbers of lines changed (default)"
	echo ""
	echo "  -u | --usual"
	echo "    print usual output of \"diff\" command"
	echo ""
	echo "  -a | -2 | --added-only"
	echo "    print only \">\" lines (lines not contained in <file1>"
	echo ""
	echo "  -r | -1 | --removed-only"
	echo "    print only \"<\" lines (lines not contained in <file2>"
	echo ""
	echo "  -i | --identical"
	echo "    test if <file1> and <file2> are identical"
	echo "    returns (and prints to stdout) 0 iff true, 1 iff false"
	echo ""
	echo "  -d | --different"
	echo "    test if <file1> and <file2> differ"
	echo "    returns (and prints to stdout) 0 iff true, 1 iff false"
	echo ""
	echo "  -h | --help"
	echo "    print this help message and exit"
	echo ""; echo ""
	echo "return codes:"
	echo "  0 - success, with -i and -d iff true"
	echo "  1 - with -i and -d iff false"
	echo "  2 - wrong usage"
	echo "  3 - command \"diff\" not found on the system"
	echo "  4 - file (<file1> or <file2>) not found"
	echo "  5 - trouble with command \"diff\""
	echo ""
	exit $1
}

function cmd_n()
{
	diff $FILE1 $FILE2 | awk '/[<>].*/ {print $1" "$2}'
}

function cmd_u()
{
	diff $FILE1 $FILE2
}

function cmd_a()
{
	diff $FILE1 $FILE2 | awk '/[>].*/ {print $2}'
}

function cmd_r()
{
	diff $FILE1 $FILE2 | awk '/[<].*/ {print $2}'
}

function cmd_i()
{
	diff $FILE1 $FILE2 &> /dev/null
	if [ $? -eq 0 ]; then echo "0"; exit 0
	elif [ $? -eq 1 ]; then echo "1"; exit 1
	elif [ $? -eq 2 ]; then exit 5; fi
}

function cmd_d()
{
	diff $FILE1 $FILE2 &> /dev/null
	if [ $? -eq 0 ]; then echo "1"; exit 1
	elif [ $? -eq 1 ]; then echo "0"; exit 0
	elif [ $? -eq 2 ]; then exit 5; fi
}

checkcmd "awk"
checkcmd "basename"
checkcmd "diff"

if [ $# -eq 0 ]; then print_help 2
elif [ $# -eq 1 ]; then
	if [[ "$1" == "-h" || "$1" == "--help" ]]; then print_help 0; fi
elif [ $# -eq 2 ]; then
	FILE1=$1; FILE2=$2
	if [ ! -f $FILE1 ]; then echo "file \"$FILE1\" not found"; exit 4
	elif [ ! -f $FILE2 ]; then echo "file \"$FILE2\" not found"; exit 4
	else cmd_n; fi
elif [ $# -eq 3 ]; then
	FILE1=$2; FILE2=$3
	if [ ! -f $FILE1 ]; then "file \"$FILE1\" not found"; exit 4
	elif [ ! -f $FILE2 ]; then "file \"$FILE2\" not found"; exit 4; fi
	case $1 in
		-n|--no-line-numbers) cmd_n ;;
		-u|--usual) cmd_u ;;
		-a|-2|--added-only) cmd_a ;;
		-r|-1|--removed-only) cmd_r ;;
		-i|--identical) cmd_i ;;
		-d|--different) cmd_d ;;
		*) print_help 2 ;;
	esac
else print_help 2; fi

exit 0
