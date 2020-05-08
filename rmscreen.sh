#!/bin/bash
##
## rmscreen - remove last screenshot accidentally taken
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
	which "$c" &> /dev/null &
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
	return 0
}

checkcmd "date"
checkcmd "head"
checkcmd "ls"
checkcmd "rm"

SCREEN_DIR="/home/user/pic/screen"
today=$(date +%y%m%d)

if [ ! -d "$SCREEN_DIR" ]; then
	echo "directory \"$SCREEN_DIR\" not found"
	exit 2
fi

file=$(ls -t $SCREEN_DIR | head -n 1)

if [ -z "$file" ]; then echo "no screenshots found"
elif [[ $file == *$today*'.png' ]]; then
	echo -n "delete $SCREEN_DIR/$file? (Y/n) "
	read resp

	if [ "$resp" == "n" ] || [ "$resp" == "N" ] ||
	   [ "$resp" == "no" ] || [ "$resp" == "NO" ]; then exit 0
	else rm -f "$SCREEN_DIR/$file"; fi
else
	if [ $# -eq 1 ] && [ "$1" == "-f" ]; then
		echo -n "delete $SCREEN_DIR/$file? (y/N) "
		read resp

		if [ "$resp" == "y" ] || [ "$resp" == "Y" ] ||
		   [ "$resp" == "yes" ] || [ "$resp" == "YES" ]; then
			rm -f "$SCREEN_DIR/$file"
		fi
	else echo "the latest screenshot is older than from today"; fi
fi

exit 0
