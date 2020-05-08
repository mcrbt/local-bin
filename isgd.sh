#!/bin/bash
##
## isgd - shorten URLs on https://is.gd via command line
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
	if [ $# eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 2; fi
	return 0;
}

checkcmd "basename"
checkcmd "curl"
checkcmd "grep"
checkcmd "perl"
checkcmd "ps"

if [ $# -ne 1 ]; then echo "usage:  $(basename $0) <url>"; exit 1; fi

if [ -z "$(ps -e | grep tor)" ]; then
	curl --silent "https://is.gd/create.php?url=$1" | grep "short_url" \
		| perl -pe 's/.*value="(https:\/\/is\.gd\/.*?)".*/\1/'
else
	curl --silent --socks5 127.0.0.1:9050 "https://is.gd/create.php?url=$1" \
		| grep "short_url" | perl -pe 's/.*value="(https:\/\/is\.gd\/.*?)".*/\1/'
fi

exit 0
