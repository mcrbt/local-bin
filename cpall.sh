#!/bin/bash

ARG0=$(basename $0)

function usage()
{
	echo "usage:  $ARG0 <src> <dst> [prefix <p>] [suffix <s>]"
	echo "        $ARG0 [help]"
}

if [ $# -eq 0 ]; then
	usage
	exit 0
elif [ $# -eq 1 ]; then
	usage
	if [ "$1" == "help" ]; then exit 0
	else exit 1; fi
elif [ $# -eq 2 ]; then
	for i in $1/*; do cp -ri $i $2/$(basename $i); done
elif [ $# -eq 4 ]; then
	if [ "$3" == "prefix" ]; then
		pre=$4
		for i in $1/*; do cp -ri "$i" "$2/${pre}$(basename $i)"; done
	elif [ "$3" == "suffix" ]; then
		suf=$4
		for i in $1/*; do cp -ri "$i" "$2/$(basename $i)${suf}"; done
	else usage; exit 1; fi
elif [ $# -eq 6 ]; then
	if [ "$3" == "prefix" ]; then pre=$4
	elif [ "$3" == "suffix" ]; then suf=$4
	else usage; exit 1; fi

	if [ "$5" == "suffix" ]; then suf=$6
	elif [ "$5" == "prefix" ]; then pre=$6
	else usage; exit 1; fi

	for i in $1/*; do cp -ri "$i" "$2/${pre}$(basename $i)${suf}"; done
else usage; exit 1; fi

echo "done"
exit 0
