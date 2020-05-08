#!/bin/bash
##
## ifinfo - get addresses registered for current network interface
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
checkcmd "grep"
checkcmd "ip"
checkcmd "wc"

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
