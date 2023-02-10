#!/bin/bash
##
## dns - wrapper around "host" for (reverse) domain name lookups
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
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
	return 0
}

checkcmd "awk"
checkcmd "basename"
checkcmd "head"
checkcmd "host"
checkcmd "perl"
checkcmd "sed"

reverse=0

if [ $# -eq 0 ]; then echo "usage:  $(basename $0) [-r] <host>"; exit 0; fi
if [ $# -gt 1 ] && [ $1 == "-r" ]; then reverse=1; shift; fi

if [ $reverse -eq 0 ]; then
	for h in $@; do
		res=$(host $h | head -n 1 -q | awk '{print $4}')
		if [ "$res" == "alias" ]; then
			h2=$(host $h | head -n 1 -q | awk '{print $6}' | sed 's/\(.+\)\.$/\1/')
			res=$(host $h2 | head -n 1 -q | awk '{print $4}')
		fi
		echo "$res"
	done
else
	for h in $@; do
		host $h | head -n 1 -q | awk '{print $5}' | perl -pe 's/(.+)\.$/\1/'
	done
fi

exit 0
