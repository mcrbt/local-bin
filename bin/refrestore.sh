#!/bin/bash
##
## refrestore - reopen hyperlinks read from ASCII file in firefox
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

VERSION="0.2.0"
CWD=$(pwd)

function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -eq 0 ]; then return 0
	else echo "command \"$c\" not found"; exit 1; fi
}

function open_link_files
{
	cd $1

	for name in ./*.{href,url}; do
		if [ -f $name ]; then
			link=$(cat $name)
			echo "opening \"$link\"..."
			firefox --new-tab "$link" &> /dev/null &
			sleep 1
		fi
	done

	cd $CWD
}

function open_file_links
{
	if [ ! -f $1 ] || [ -d $1 ]
	then echo "file \"$1\" not found"; exit 1; fi

	while read link; do
		if [ -z "$link" ] || [[ $link != http* ]]
		then continue; fi
		echo "opening \"$link\"..."
		firefox --new-tab "$link" &> /dev/null &
		sleep 1
	done < "$1"
}

checkcmd "basename"
checkcmd "cat"
checkcmd "firefox"
checkcmd "sleep"

if [ $# -eq 0 ]; then open_link_files $CWD
elif [ $# -eq 1 ] &&
     [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo ""
	echo "usage:  $(basename $0) <dir1> [<dir2>...]"
	echo "        $(basename $0) -f <filename>"
	echo "        $(basename $0) [-V | -h]"
	echo ""
	echo "  <dir1> [<dir2>...]"
	echo "      open all \"*.href\" and \"*.url\" files contained"
	echo "      the directories provided (<dir1>, <dir2>, ...)"
	echo ""
	echo "  -f <filename>"
	echo "      open every hyperlink contained in file <filename>"
	echo "      (one per line)"
	echo ""
	echo "  -V | --version"
	echo "      print version information and exit"
	echo ""
	echo "  -h | --help"
	echo "      print this help message and exit"
	echo ""
	echo "  if no parameters are given, every \"*.href\" and"
	echo "  \"*.url\" file in current directory is opened"
	echo ""
elif [ $# -eq 1 ] &&
     [[ "$1" == "-V" || "$1" == "--version" ]]; then
	echo "refrestore version $VERSION"
	echo "copyright (c) 2020 Daniel Haase"
elif [ $# -eq 2 ] && [ "$1" == "-f" ]; then open_file_links $2
else
	for arg in $@; do
		if [ ! -d $arg ]
		then echo "\"$arg\" is not a directory"
		else open_link_files $arg; fi
		shift
	done
fi

exit 0
