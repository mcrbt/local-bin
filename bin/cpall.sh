#!/bin/bash
##
## cpall - copy multiple files at once while optionally renaming them
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

function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 2; fi
	return 0
}

checkcmd "basename"
checkcmd "cp"

ARG0=$(basename $0)

function usage()
{
	echo "usage:  $ARG0 <src> <dst> [prefix <p>] [suffix <s>]"
	echo "        $ARG0 [help]"
}

if [ $# -eq 0 ]; then
	usage; exit 0
elif [ $# -eq 1 ]; then
	usage
	if [ "$1" == "help" ]; then exit 0
	else exit 1; fi
elif [ $# -eq 2 ]; then
	for i in $1/*; do
		cp -ri $i $2/$(basename $i)
	done
elif [ $# -eq 4 ]; then
	if [ "$3" == "prefix" ]; then
		pre=$4

		for i in $1/*; do
			cp -ri "$i" "$2/${pre}$(basename $i)"
		done
	elif [ "$3" == "suffix" ]; then
		suf=$4

		for i in $1/*; do
			cp -ri "$i" "$2/$(basename $i)${suf}"
		done
	else usage; exit 1; fi
elif [ $# -eq 6 ]; then
	if [ "$3" == "prefix" ]; then pre=$4
	elif [ "$3" == "suffix" ]; then suf=$4
	else usage; exit 1; fi

	if [ "$5" == "suffix" ]; then suf=$6
	elif [ "$5" == "prefix" ]; then pre=$6
	else usage; exit 1; fi

	for i in $1/*; do
		cp -ri "$i" "$2/${pre}$(basename $i)${suf}"
	done
else usage; exit 1; fi

echo "done"
exit 0
