#!/usr/bin/env -S bash
##
## aphwaddr - get MAC address of wireless access point
## Copyright (C) 2020-2021 Daniel Haase
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

set -euo pipefail

#VERSION="0.2.1"

## check if command "$1" is installed
function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "${c}" ] \
	|| command -v "${c}" &> /dev/null; then return 0
	else echo "command \"${c}\" not found"; exit 1; fi
}

checkcmd "awk"
checkcmd "basename"
checkcmd "grep"
checkcmd "head"
checkcmd "ip"
checkcmd "iw"

if [ $# -eq 0 ]; then iface=""
elif [ $# -eq 1 ]; then
	if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
		echo "usage:  $(basename "$0") [<interface>]"
		exit 0
	elif [[ "$1" == "-"* ]]; then
		echo "usage:  $(basename "$0") [<interface>]"
		exit 1
	else iface="$1"; fi
else
	echo "usage:  $(basename "$0") [<interface>]"
	exit 1
fi

phy=$(iw dev)

if [ -z "$phy" ]; then
	echo "no wireless interfaces found"
	exit 4
fi

phy=$(echo "$phy" | awk '/Interface/ {print $2}' | head -n 1)

if [ -z "$phy" ]; then
	echo "no wireless interface available"
	exit 6
fi

if [ -n "$iface" ]; then
	iswl=$(iw "$iface" info | awk '/Interface/ {print $2}')

	if [ -z "$iswl" ]; then
		echo "interface \"$iface\" is not a wireless interface"
		exit 7
	fi
else iface="$phy"; fi

if [ -z "$iface" ]; then
	echo "no wireless interface available"
	exit 6
else
	isup=$(ip link show dev "$iface" | awk '{print $3}' | grep "UP")

	if [ -z "$isup" ]; then
		echo "wireless interface \"$iface\" is down"
		exit 9
	fi
fi

HWADDR=$(iw dev "$iface" station dump | grep "Station" \
	| awk '{print $2}')

if [ -n "$HWADDR" ] && [ "$HWADDR" != " " ]; then
	echo "$HWADDR"
	exit 0
else
	echo "failed to get hardware address of wireless access" \
		"point on interface $iface"
	exit 3
fi

exit 0
