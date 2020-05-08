#!/bin/bash
##
## wikipedia - open specific Wikipedia article from command line
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

LANG="en"
QUERY=""

function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
	return 0
}

function prepare()
{
	NAME=$(for i in $@; do CONV=$(echo -n "${i:0:1}" \
		| tr "[:lower:]" "[:upper:]"); echo -n "${CONV}${i:1}"; done)
	NAME=$(echo "$NAME" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//')
	echo "$NAME"
}

checkcmd "basename"
checkcmd "firefox"
checkcmd "sed"
checkcmd "tr"

if [ $# -eq 0 ]; then echo "usage:  $(basename $0) <en|de> <query>"; exit 0
elif [ $# -eq 1 ]; then
	if [ "$1" == "en" ] || [ "$1" == "de" ]
	then echo "usage:  $(basename $0) <en|de> <query>"; exit 2; fi
	QUERY=$(prepare $1)
else
	if [ "$1" == "en" ] || [ "$1" == "de" ]; then LANG=$1; shift; fi
	QUERY=$(prepare $@)
fi

if [ -z "$QUERY" ]; then URL="https://www.wikipedia.org/"
else URL="https://$LANG.wikipedia.org/wiki/$QUERY"; fi

firefox --new-tab $URL &> /dev/null &
if [ $? -ne 0 ]; then echo "failed to open \"firefox\""; exit 2; fi

exit 0
