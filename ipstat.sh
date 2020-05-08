#!/bin/bash
##
## ipstat - get private (LAN), public (WAN), and TOR exit node IP address
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
checkcmd "curl"
checkcmd "grep"
checkcmd "ip"
checkcmd "ps"
checkcmd "sed"

if [ -z "$(ip route)" ]; then
	echo "no connection detected"
	exit 0
fi

IF=$(ip route | awk '/^default/ {print $5}')
MD=$(echo $IF | sed 's/\(.\).*/\1/')

LAN=$(ip route show dev $IF | awk '/link/ {print $7}')
WAN=$(curl --silent ipinfo.io/ip)

if [ -z "$(ps -e | grep tor)" ]; then TOR="tor not running"
else TOR=$(curl --proxy socks5://localhost:9050 --silent ipinfo.io/ip); fi

echo ""
## this is little professional but holds in most of the cases:
if [ "$MD" == "w" ]; then echo "active default interface: $IF (wireless)"
else echo "active default interface: $IF (wired)"; fi
echo ""
echo "Private LAN IP:      $LAN"
echo "Public WAN IP:       $WAN"
echo "Tor exit node IP:    $TOR"
echo ""
exit 0
