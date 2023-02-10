#!/bin/bash
##
## trackpad - quickly enable/disable trackpad (using "xinput")
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

checkcmd "basename"
checkcmd "grep"
checkcmd "xinput"

PROGRAM_NAME="$0"
TRACKPAD=$(xinput list --name-only | grep "Synaptics")
TRACKPNT=$(xinput list --name-only | grep "TrackPoint")
MOUSE=$(xinput list --name-only | grep -i "Mouse")

function disable()
{
	if [ ! -z "$TRACKPAD" ]; then
		xinput disable "$TRACKPAD" 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "failed to disable trackpad"
			exit 3
		fi
	fi

	if [ ! -z "$TRACKPNT" ]; then
		xinput disable "$TRACKPNT" 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "failed to disable trackpoint"
			exit 3
		fi
	fi
}

function enable()
{
	if [ ! -z "$TRACKPAD" ]; then
		xinput enable "$TRACKPAD" 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "failed to disable trackpad"
			exit 3
		fi
	fi

	if [ ! -z "$TRACKPNT" ]; then
		xinput enable "$TRACKPNT" 2> /dev/null
		if [ $? -ne 0 ]; then
			echo "failed to disable trackpoint"
			exit 3
		fi
	fi
}

function usage()
{
	echo "usage:  $(basename $PROGRAM_NAME) [on | off | help]"
}

if [ $# -eq 0 ]; then
	if [ ! -z "$MOUSE" ]; then disable
	else enable; fi
elif [ $# -eq 1 ]; then
	if [ "$1" == "help" ]; then usage; exit 0
	elif [ "$1" == "on" ]; then enable
	elif [ "$1" == "off" ]; then disable
	else usage; exit 2; fi
else usage; exit 2; fi

exit 0
