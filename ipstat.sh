#!/bin/bash

which ip &> /dev/null
if [ $? -ne 0 ]; then echo "command \"ip\" not found"; exit 1; fi
which curl &> /dev/null
if [ $? -ne 0 ]; then echo "command \"curl\" not found"; exit 1; fi
which ps &> /dev/null
if [ $? -ne 0 ]; then echo "command \"ps\" not found"; exit 1; fi
which grep &> /dev/null
if [ $? -ne 0 ]; then echo "command \"grep\" not found"; exit 1; fi

if [ "$(ip route)" == "" ]; then
	echo "no connection detected"
	exit 0
fi

IF=$(ip route | awk '/^default/ {print $5}')
MD=$(echo $IF | sed 's/\(.\).*/\1/')

LAN=$(ip route show dev $IF | awk '/link/ {print $7}')
WAN=$(curl --silent ipinfo.io/ip)

if [ "$(ps -e | grep tor)" == "" ]; then TOR="tor not running"
else TOR=$(curl --proxy socks5://localhost:9050 --silent ipinfo.io/ip); fi

echo ""
if [ "$MD" == "w" ]; then echo "active default interface: $IF (wireless)"
else echo "active default interface: $IF (wired)"; fi
echo ""
echo "Private LAN IP:      $LAN"
echo "Public WAN IP:       $WAN"
echo "Tor exit node IP:    $TOR"
echo ""
exit 0
