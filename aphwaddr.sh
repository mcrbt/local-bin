#!/bin/bash

if [ $# -ne 1 ]; then echo "Usage: $0 <interface>"; exit 1
else INTERFACE=$1; fi

which iw &> /dev/null

if [ $? -eq 0 ]; then
	PROFILE=$(netctl list | grep '*' | awk '{print $2}')

	if [ "$PROFILE" == "" ] || [ "$PROFILE" == " " ]; then
		echo "no network connection found"
		exit 2
	else
		HWADDR=$(iw dev $INTERFACE station dump -v | grep "Station" | awk '{print $2}')

		if [ "$HWADDR" != "" ] && [ "$HWADDR" != " " ]; then
			echo "$HWADDR"
			exit 0
		else
			echo "failed to get hardware address of wireless AP on interface $INTERFACE"
			exit 3
		fi
	fi
else echo "command \"iw\" not found"; exit 4; fi
