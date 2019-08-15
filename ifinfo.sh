#!/bin/bash

which ip &> /dev/null
if [ $? -ne 0 ]; then echo "command \"ip\" not found"; fi

IF=$(ip route | awk '/^default/ {print $5}')
IFMAC=$(ip address show dev $IF | awk '/link\/ether/ {print $2}')
IP4no=$(ip address show dev $IF | awk '{print $1}' | awk '/^inet$/' | wc -l)
IP6no=$(ip address show dev $IF | awk '{print $1}' | awk '/^inet6$/' | wc -l)

echo ""
echo "interface $IF (${IFMAC})"

if [ $IP4no -gt 0 ]; then
	echo ""
	echo "ipv4 ($IP4no):"
	IPS=$(ip address show dev $IF | grep inet | grep -v inet6 | awk '{print $2}')
	for i in $IPS; do echo "    $i"; done
fi

if [ $IP6no -gt 0 ]; then
	echo ""
	echo "ipv6 ($IP6no):"
	IPS=$(ip address show dev $IF | grep inet6 | awk '{print $2}')
	for i in $IPS; do echo "    $i"; done
fi

echo ""
exit 0
