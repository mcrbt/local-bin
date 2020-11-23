#!/bin/bash
##
## ifinfo - get ip addresses registered for default network interface
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
	if [ $? -eq 0 ]; then return 0
	else echo "command \"$c\" not found"; exit 1; fi
}

checkcmd "awk"
checkcmd "head"
checkcmd "ip"
checkcmd "wc"

if [ -z "$(ip route)" ]; then
	echo "no network connection detected"
	exit 2
fi

IF=$(ip route | awk '/^default/ {print $5}' | head -n 1)
if [ -z "$IF" ]; then
	echo "failed to get default network interface"
	exit 2
fi

IFMAC=$(ip address show dev $IF | awk '/link\/ether/ {print $2}')
IP4NO=$(ip address show dev $IF | awk '/inet[^6]/' | wc -l)
IP6NO=$(ip address show dev $IF | awk '/inet6/' | wc -l)

echo ""
echo "interface $IF (${IFMAC})"

if [ $IP4NO -gt 0 ]; then
	echo ""
	echo "ipv4 ($IP4NO):"
	IPS=$(ip address show dev $IF | awk '/inet[^6]/ {print $2}')
	for i in $IPS; do echo "    $i"; done
fi

if [ $IP6NO -gt 0 ]; then
	echo ""
	echo "ipv6 ($IP6NO):"
	IPS=$(ip address show dev $IF | awk '/inet6/ {print $2}')
	for i in $IPS; do echo "    $i"; done
fi

echo ""
exit 0
