#!/bin/bash

## ap - bash script to start/stop a software access point automatically
## Copyright (C) 2018 Daniel Haase
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

## filename:    ap.sh
## author:      Daniel Haase <prjctntfctn@web.de>
## version:     1.0.0
## release:     February 7, 2018
## description: bash script to start/stop a software access point automatically

## dependencies:
##    grep, gawk, (iw), netctl, ip, (iptables), dhcpd, hostapd, sysctl

## possible exit codes:
##    0 - success
##    1 - invalid command line syntax
##    2 - command not found
##    3 - restore session error
##    4 - dhcpd error
##    5 - hostapd error
##    6 - specified interface not capable of access point mode

CMD=""
INTERFACE="wlp3s0"
AP_IP="192.168.204.1/24"
DHCPD_CONF="/etc/dhcpd.conf"
HOSTAPD_CONF="/etc/hostapd/hostapd.conf"
SESSION_FILE=".ap.session"
PROFILE_FILE=".current.profile"
VERSION="1.0.0"
RELEASE="February 7, 2018"

function save_session()
{
	echo "$INTERFACE;$AP_IP;$DHCPD_CONF;$HOSTAPD_CONF" > "$SESSION_FILE"
}

function load_session()
{
	if [ -e "$SESSION_FILE" ]; then
		if [ -s "$SESSION_FILE" ]; then
			SESSION=`cat $SESSION_FILE`
			INTERFACE=$(echo "$SESSION" | awk -F ";" '{print $1}')
			AP_IP=$(echo "$SESSION" | awk -F ";" '{print $2}')
			DHCPD_CONF=$(echo "$SESSION" | awk -F ";" '{print $3}')
			HOSTAPD_CONF=$(echo "$SESSION" | awk -F ";" '{print $4}')
			rm "$SESSION_FILE"
		else
			echo "empty session file, operation aborted."
			rm "$SESSION_FILE"
			exit 3
		fi
	else echo "no session found, operation aborted."; exit 3; fi
}

function usage()
{
	echo "Usage: $0 <start [options] | stop | -h | -V>"
	echo ""
	echo "command:"
	echo "  start          - start wireless access point"
	echo "  stop           - stop wireless access point"
	echo "  -h | --help    - print this help message and exit"
	echo "  -V | --version - print version information and exit"
	echo ""
	echo "options:"
	echo "  -i <interface> | --interface <interface>"
	echo "    wireless network interface (default: \"$INTERFACE\")"
	echo ""
	echo "  -ip <ip_address> | --ip-address <ip_address>"
	echo "    ip address of wireless access point (default: \"$AP_IP\")"
	echo ""
	echo "  -dc <dhcpd_config> | --dhcpd-config <dhcpd_config>"
	echo "    filename of dhcpd config file (default: \"$DHCPD_CONF\")"
	echo ""
	echo "  -hc <hostapd_config> | --hostapd-config <hostapd_config>"
	echo "    filename of hostapd config file (default: \"$HOSTAPD_CONF\")"
	echo ""
}

function version()
{
	echo "ap.sh - Bash script to start/stop software access point automatically"
	echo "Copyright (C) 2018 Daniel Haase - <prjectntfctn@web.de>"
	echo "Version $VERSION - $RELEASE"
	echo ""
}

function parse()
{
	while [[ $# -gt 0 ]]; do
		local key=$1

		case $key in
			start)
				CMD="START"; shift
				;;
			stop)
				CMD="STOP"; shift; load_session; break
				;;
			-h|--help)
				usage; exit 0
				;;
			-V|--version)
				version; exit 0
				;;
			-i|--interface)
				INTERFACE="$2"; shift; shift
				;;
			-ip|--ip-address)
				AP_IP="$2"; shift; shift
				;;
			-dc|--dhcpd-config)
				DHCPD_CONF="$2"; shift; shift
				;;
			-hc|--hostapd-config)
				HOSTAPD_CONF="$2"; shift; shift
				;;
			*)
				usage; exit 1
				;;
		esac
	done

	if [ "$CMD" == "" ]; then usage; exit 1
	elif [ "$CMD" == "START" ]; then save_session; fi
}

function current_profile()
{
	local active_profile=$(netctl list | grep '*' | awk '{print $2}')

	if [[ "$active_profile" == "" || "$active_profile" == " " ]]; then
		local active_profile=$(netctl list | grep '+' | awk '{print $2}')
	fi

	if [[ "$active_profile" == "" || "$active_profile" == " " ]]; then echo ""
	elif [[ "$active_profile" != "" && "$active_profile" != " " ]]; then
		local netctl_name="/etc/netctl/$active_profile"
		local netctl_file=`cat $netctl_name`
		local active_interface=$(echo "$netctl_file" | grep "Interface" | awk -F "=" '{print $2}')

		if [ "$active_interface" == "$INTERFACE" ]; then echo "$active_profile"
		else echo ""; fi
	fi
}

which netctl &> /dev/null
if [ $? -eq 1 ]; then
	echo "command \"netctl\" not found."
	exit 2
fi

which ip &> /dev/null
if [ $? -eq 1 ]; then
	echo "command \"ip\" not found."
	exit 2
fi

if [[ $# -eq 3 || $# -eq 5 || $# -eq 7 || $# -eq 9 ]]; then parse $@
elif [ $# -eq 1 ]; then
	if [[ "$1" == "-h" || "$1" == "--help" ]]; then usage; exit 0
	elif [[ "$1" == "-V" || "$1" == "--version" ]]; then version; exit 0
	elif [ "$1" == "start" ]; then CMD="START"; save_session
	elif [ "$1" == "stop" ]; then CMD="STOP"; load_session
	else usage; exit 1; fi
else usage; exit 1; fi

if [ "$CMD" == "START" ]; then
	echo "starting access point..."

	which iw &> /dev/null
	if [ $? -eq 0 ]; then
		isCapable=$(iw list | grep "* AP\$" | awk '{print $2}')
		if [ "$isCapable" != "AP" ]; then
			echo "the interface \"$INTERFACE\" is not AP-enabled."
			exit 6
		fi
	else echo "\"iw\" is not installed: the interface \"$INTERFACE\" may not be AP-enabled."; fi

	which dhcpd &> /dev/null
	if [ $? -eq 1 ]; then
		echo "command \"dhcpd\" not found."
		exit 2
	fi

	#which iptables &> /dev/null
	#if [ $? -eq 1 ]; then
	#	echo "command \"iptables\" not found."
	#	exit 2
	#fi

	which hostapd &> /dev/null
	if [ $? -eq 1 ]; then
		echo "command \"hostapd\" not found."
		exit 2
	fi

	if [ -e "dhcpd.err" ]; then rm "dhcpd.err"; fi
	if [ -e "hostapd.err" ]; then rm "hostapd.err"; fi
	if [ -e "hostapd.log" ]; then rm "hostapd.log"; fi

	PROFILE=$(current_profile)
	if [ "$PROFILE" != "" ]; then echo "$PROFILE" > "$PROFILE_FILE"; fi
	netctl stop-all
	ip link set $INTERFACE up
	ip addr add $AP_IP dev $INTERFACE
	sleep 3

	if [ "$(ps -e | grep dhcpd)" == "" ]; then
		dhcpd -4 -q -cf $DHCPD_CONF $INTERFACE 2> "dhcpd.err" 1> /dev/null &

		if [[ -e "dhcpd.err" && -s "dhcpd.err" ]]; then
			echo "failed to start \"dhcpd\" on interface \"$INTERFACE\"."
			exit 4
		fi
	fi

	## enable NAT routing when providing internet connection
	#iptables --flush
	#iptables --table nat --flush
	#iptables --delete-chain
	#iptables --table nat --delete-chain
	#iptables --table nat --append POSTROUTING --out-interface enp0s31f6 -j MASQUERADE
	#iptables --append FORWARD --in-interface $INTERFACE -j ACCEPT
	#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

	sysctl -w net.ipv4.ip_forward=1 &> /dev/null

	if [ "$(ps -e | grep hostapd)" == "" ]; then
		hostapd $HOSTAPD_CONF 1> "hostapd.log" 2> "hostapd.err" &

		if [[ -e "hostapd.err" && -s "hostapd.err" ]]; then
			echo "failed to start \"hostapd\"."
			exit 4
		fi
	fi

	sleep 2
elif [ "$CMD" == "STOP" ]; then
	echo "stopping access point..."
	if [ "$(ps -e | grep hostapd)" != "" ]; then kill $(ps -e | grep hostapd | awk '{print $1}'); fi
	if [ "$(ps -e | grep dhcpd)" != "" ]; then kill $(ps -e | grep dhcpd | awk '{print $1}'); fi
	if [[ -e "dhcpd.err" && ! -s "dhcpd.err" ]]; then rm "dhcpd.err"; fi
	if [[ -e "hostapd.err" && ! -s "hostapd.err" ]]; then rm "hostapd.err"; fi
	if [[ -e "hostapd.log" && ! -s "hostapd.log" ]]; then rm "hostapd.log"; fi

	sysctl -w net.ipv4.ip_forward=0 &> /dev/null
	ip addr del $AP_IP dev $INTERFACE
	ip link set $INTERFACE down
	sleep 2

	if [[ -e "$PROFILE_FILE" && -s "$PROFILE_FILE" ]]; then
		PROFILE=`cat $PROFILE_FILE`
		echo "restarting previous netctl profile \"$PROFILE\"..."
		netctl start $PROFILE
		rm "$PROFILE_FILE"
	fi
fi

echo "done."
exit 0
