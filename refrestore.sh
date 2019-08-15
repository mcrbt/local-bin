#!/bin/bash

CWD=$(pwd)

function open_link_files
{
	cd $1

	for name in ./*.href; do
		if [ -f $name ]; then
			link=$(cat $name)
			echo "opening \"$link\"..."
			firefox --new-tab "$link" &> /dev/null &
			#if [ $? -ne 0 ]; then echo "failed to open link \"$link\""
			#else sleep 1; fi
			sleep 1
		fi
	done

	cd $CWD
}

function open_file_links
{
	if [ ! -f $1 ] || [ -d $1 ]; then echo "file \"$1\" not found"; exit 1; fi

	while read link; do
		if [ "$link" == "" ] || [[ $link != http* ]]; then continue; fi
		echo "opening \"$link\"..."
		firefox --new-tab "$link" &> /dev/null &
		#if [ $? -ne 0 ]; then echo "failed to open link \"$link\""
		#else sleep 1; fi
		sleep 1
	done < "$1"
}

if [ $# -eq 0 ]; then open_link_files $CWD
elif [ $# -eq 1 ] && [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo ""
	echo "usage:  $(basename $0) <dir1> [<dir2>...]"
	echo "        $(basename $0) -f <filename>"
	echo "        $(basename $0) -h"
	echo "        $(basename $0)"; echo ""
	echo "  <dir1> [<dir2>...]"
	echo "      open all \"*.href\" files contained in <dir1> (<dir2>, ...)"
	echo "  -f <filename>"
	echo "      open every hyperlink contained in file <filename> (one per line)"
	echo "  -h | --help"
	echo "      print this help message and exit"
	echo ""
	echo "  if no parameters are given open every \"*.href\" file in current directory"
	echo ""
elif [ $# -eq 2 ] && [ "$1" == "-f" ]; then open_file_links $2
else
	for arg in $@; do
		if [ ! -d $arg ]; then echo "\"$arg\" is not a directory"
		else open_link_files $arg
		fi
		shift
	done
fi

#echo "done."
exit 0
