#!/usr/bin/env bash
##
## ifinfo - get ip addresses registered for default network interface
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

NAME="ifinfo"
VERSION="0.3.0"

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
	local -r address_info="${1}"

	echo "${address_info}" |
		grep --max-count=1 --fixed-strings "state UP"
} &>/dev/null

check_command "awk"
check_command "cat"
check_command "head"
check_command "ip"
check_command "wc"

declare interface=""

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
		-*)
			print_usage
			exit 2
			;;
		*)
			interface="${1}"
			;;
	esac
elif [[ $# -gt 1 ]]; then
	print_usage
	exit 2
fi

declare default_interface

default_interface="$(ip route 2>/dev/null |
	awk '/^default/ { print $5 }' |
	head --lines=1)" || {
	echo >&2 "default network interface not found"
	exit 2
}
interface="${interface:-"${default_interface}"}"

declare address_info

address_info="$(ip address show dev "${interface}" 2>/dev/null)" || {
	echo >&2 "no such interface \"${interface}\""
	exit 3
}

if ! is_interface_up "${address_info}"; then
	echo >&2 "interface \"${interface}\" is down"
	exit 2
fi

declare mac_address
declare -i ip4_count
declare -i ip6_count

mac_address="$(echo "${address_info}" | awk '/link\/ether/ { print $2 }')"
ip4_count="$(echo "${address_info}" | grep --count 'inet[^6]')"
ip6_count="$(echo "${address_info}" | grep --count --fixed-strings 'inet6')"

cat <<-EOF

	interface ${interface} (${mac_address})
EOF

if [[ ${ip4_count} -gt 0 ]]; then
	cat <<-EOF

		ip4 (${ip4_count}):
	EOF

	echo "${address_info}" |
		awk '/inet[^6]/ { print "    "$2 }'
fi

if [[ ${ip6_count} -gt 0 ]]; then
	cat <<-EOF

		ip6 (${ip6_count}):
	EOF

	echo "${address_info}" |
		awk '/inet6/ { print "    "$2 }'
fi

echo ""
exit 0
