#!/bin/bash

which ip &> /dev/null
if [ $? -ne 0 ]; then echo "command \"ip\" not found"; exit 2; fi

which iw &> /dev/null
if [ $? -ne 0 ]; then echo "command \"iw\" not found"; exit 2; fi

if [ $# -eq 0 ]; then INTERFACE=$(ip route | awk '/^default/ {print $5}')
elif [ $# -eq 1 ]; then INTERFACE=$1
else
	echo "usage:  $(basename $0) [<interface>]"
	exit 1
fi

HWADDR=$(iw dev $INTERFACE station dump | grep "Station" | awk '{print $2}')

if [ "$HWADDR" != "" ] && [ "$HWADDR" != " " ]; then
	echo "$HWADDR"
	exit 0
else
	echo "failed to get hardware address of wireless AP on interface $INTERFACE"
	exit 3
fi

exit 0



