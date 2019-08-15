#!/bin/bash

which xinput &> /dev/null
if [ $? -ne 0 ]; then echo "command \"xinput\" not found"; exit 1; fi

PROGRAM_NAME="$0"
#TRACKPAD=$(xinput list | awk '/Synaptics/ {print $3" "$4}')
#TRACKPNT=$(xinput list | awk '/TrackPoint/ {print $3" "$4" "$5}')
TRACKPAD=$(xinput list --name-only | grep "Synaptics")
TRACKPNT=$(xinput list --name-only | grep "TrackPoint")
MOUSE=$(xinput list --name-only | grep -i "USB Optical Mouse")

function disable()
{
	if [ "$TRACKPAD" != "" ]; then
		xinput disable "$TRACKPAD" 2> /dev/null
		if [ $? -ne 0 ]; then echo "failed to disable trackpad"; fi
	fi

	if [ "$TRACKPNT" != "" ]; then
		xinput disable "$TRACKPNT" 2> /dev/null
		if [ $? -ne 0 ]; then echo "failed to disable trackpoint"; fi
	fi
}

function enable()
{
	if [ "$TRACKPAD" != "" ]; then
		xinput enable "$TRACKPAD" 2> /dev/null
		if [ $? -ne 0 ]; then echo "failed to disable trackpad"; fi
	fi

	if [ "$TRACKPNT" != "" ]; then
		xinput enable "$TRACKPNT" 2> /dev/null
		if [ $? -ne 0 ]; then echo "failed to disable trackpoint"; fi
	fi
}

function usage()
{
	echo "usage:  $(basename $PROGRAM_NAME) [on | off | help]"
}

if [ $# -eq 0 ]; then
	if [ "$MOUSE" != "" ]; then
		disable
	else
		enable
	fi
elif [ $# -eq 1 ]; then
	if [ "$1" == "help" ]; then
		usage
		exit 0
	elif [ "$1" == "on" ]; then
		enable
	elif [ "$1" == "off" ]; then
		disable
	else
		usage
		exit 1
	fi
else
	usage
	exit 1
fi

exit 0
