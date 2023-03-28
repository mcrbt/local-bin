#!/usr/bin/env bash
##
## ipinfo - get private (LAN), public (WAN), and Tor exit relay IP address
## Copyright (C) 2020-2023  Daniel Haase
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

# shellcheck disable=SC2310

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

NAME="ipinfo"
VERSION="0.2.1"

SOCKS_PROXY="${SOCKS_PROXY:-"localhost:9050"}"
IP_LOOKUP_URL="${IP_LOOKUP_URL:-"https://api.ipify.org"}"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo >&2 "no such command \"${1}\""
		exit 1
	fi
}

function print_version {
	cat <<-EOF
		${NAME} ${VERSION}
		copyright (c) 2020-2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${NAME} [<interface>]
		        ${NAME} [--version | --help]

		   <interface>
		      network interface to print information about

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function is_interface_up {
	local -r interface="${1}"

	if [[ -z "${interface}" ]]; then
		return 1
	fi

	ip link show dev "${interface}" |
		grep --max-count=1 --fixed-strings "state UP"
} &>/dev/null

function is_wireless_interface {
	local -r interface="${1}"

	if [[ -z "${interface}" ]]; then
		return 1
	fi

	iw dev "${interface}" info
} &>/dev/null

function get_lan_address {
	local -r interface="${1}"

	if [[ -z "${interface}" ]]; then
		return 1
	fi

	ip route show dev "${interface}" |
		awk '/link/ { print $7 }'
} 2>/dev/null

function get_wan_address {
	curl --silent "${IP_LOOKUP_URL}"
} 2>/dev/null

function get_tor_address {
	if ! pgrep '^tor$' &>/dev/null; then
		echo ""
		return 0
	fi

	local tor_status
	local proxy_url

	tor_status="$(systemctl status tor |
		awk '/Active/ { print $2" "$3 }')" || {
		echo ""
		return 0
	}

	if [[ "${SOCKS_PROXY}" != "socks5://"* ]]; then
		proxy_url="socks5://${SOCKS_PROXY}"
	else
		proxy_url="${SOCKS_PROXY}"
	fi

	if [[ "${tor_status}" != "active (running)" ]]; then
		echo ""
		return 0
	fi

	curl --proxy "${proxy_url}" --silent "${IP_LOOKUP_URL}"
} 2>/dev/null

function print_formatted_address {
	printf "  %25s:    %s\n" "${1}" "${2}"
}

check_command "awk"
check_command "cat"
check_command "curl"
check_command "grep"
check_command "head"
check_command "ip"
check_command "iw"
check_command "pgrep"
check_command "systemctl"

if [[ $# -eq 1 ]]; then
	case "${1}" in
		-V | --version)
			print_version
			exit 0
			;;
		-h | --help)
			print_usage
			exit 0
			;;
		*)
			print_usage
			exit 2
	esac
elif [[ $# -gt 1 ]]; then
	print_usage
	exit 2
fi

declare interface

interface="$(ip route 2>/dev/null |
	awk '/^default/ { print $5 }' |
	head --lines=1)" || {
	echo >&2 "default network interface not found"
	exit 3
}

if ! is_interface_up "${interface}"; then
	echo >&2 "default network interface is down"
	exit 3
fi

declare lan_address
declare wan_address
declare tor_address

lan_address="$(get_lan_address "${interface}")" || {
	echo >&2 "failed to get private IP address"
	exit 4
}

wan_address="$(get_wan_address)" || {
	echo >&2 "failed to get public IP address"
	exit 4
}

tor_address="$(get_tor_address)" || {
	echo >&2 "failed to get Tor exit relay IP address"
	exit 4
}

declare interface_type

if is_wireless_interface "${interface}"; then
	interface_type="wireless"
else
	interface_type="wired"
fi

cat <<-EOF

	active default interface: ${interface} (${interface_type})

EOF

print_formatted_address "private LAN IP address" "${lan_address}"
print_formatted_address "public WAN IP address" "${wan_address}"

if [[ -n "${tor_address}" ]]; then
	print_formatted_address "Tor exit relay IP address" "${tor_address}"
fi

echo ""
exit 0
