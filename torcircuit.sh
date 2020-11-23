#!/bin/bash
##
## torcircuit - open a new TOR circuit
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
## along with this program. If not, see
## <http://www.gnu.org/licenses/gpl.txt>.
##

## script title
TITLE="torcircuit"
## script version
VERSION="0.3.0"

## test if command "$1" is installed; exit otherwise
function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 1; fi
	which "$c" &> /dev/null
	if [ $? -eq 0 ]; then return 0
	else echo "command \"$c\" not found"; exit 1; fi
}

## print version and copyright notice
function version
{
	echo "$TITLE version $VERSION"
	echo "copyright (c) 2020 Daniel Haase"
}

## print a brief usage description
function usage
{
	echo ""
	echo "open a new TOR circuit"
	echo ""
	echo "  usage: $TITLE [-h | -V]"
	echo ""
	echo "  -h | --help"
	echo "     print this usage description and exit"
	echo ""
	echo "  -V | --version"
	echo "     print version and copyright notice and exit"
	echo ""
}

## check dependencies
checkcmd "awk"
checkcmd "curl"
checkcmd "grep"
checkcmd "ip"
checkcmd "ps"
checkcmd "systemctl"
checkcmd "tor"

## parse command line arguments
if [ $# -ge 1 ]; then
	if [ "$1" == "-V" ] || [ "$1" == "--version" ]; then
		version; exit 0
	elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
		version; usage; exit 0
	fi
fi

## test for an active network connection
if [ -z "$(ip route)" ]; then
	echo "no network connection detected"
	exit 2
fi

## test whether TOR daemon is running
if [ -z "$(ps -e | grep tor)" ]; then
	echo "tor daemon not running"
	exit 2
fi

## test whether TOR service is active and running
ACTIVE=$(systemctl status tor | awk '/Active/ {print $2" "$3}')
if [ "$ACTIVE" != "active (running)" ]; then
	echo "tor service not running"
	exit 2
fi

## get old TOR exit node IP address by querying ipinfo.io through TOR
TOR_OLD=$(curl --proxy socks5://localhost:9050 --silent ipinfo.io/ip)
if [ $? -ne 0 ]; then
	echo "failed to get old tor exit node ip address"
fi

## restart TOR service
systemctl restart tor &> /dev/null
if [ $? -ne 0 ]; then
	echo "failed to open new tor circuit"
	exit 2
fi

## wait until new TOR circuit is established
sleep 2

## get new TOR exit node IP address by querying ipinfo.io through TOR
TOR_NEW=$(curl --proxy socks5://localhost:9050 --silent ipinfo.io/ip)
if [ $? -ne 0 ]; then echo "failed to get new tor exit node ip address"; fi

## print old and new public IP addresses
echo "old exit node ip: $TOR_OLD"
echo "new exit node ip: $TOR_NEW"
exit 0
