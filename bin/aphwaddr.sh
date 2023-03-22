#!/usr/bin/env bash
##
## aphwaddr - determine MAC address of wireless access point
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

# shellcheck disable=SC2155,SC2310

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

NAME="aphwaddr"
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
		      wireless network interface to use
		      (default is first one found)

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function fail_usage {
	print_usage >&2
	exit 2
}

function find_default_interface {
	iw dev |
		awk '/Interface/ { print $2 }' |
		head --lines=1
} 2>/dev/null

function has_interface {
	local -r interface="${1}"

	if [[ -z "${interface}" ]]; then
		return 1
	fi

	ip link show dev "${interface}"
} &>/dev/null

function has_wireless_interface {
	local -r interface="${1}"

	if [[ -z "${interface}" ]]; then
		return 1
	fi

	iw dev "${interface}" info
} &>/dev/null

function is_interface_up {
	local -r interface="${1}"

	if [[ -z "${interface}" ]]; then
		return 1
	fi

	ip link show dev "${interface}" |
		grep --max-count=1 --fixed-strings "UP"
} &>/dev/null

check_command "awk"
check_command "cat"
check_command "grep"
check_command "head"
check_command "ip"
check_command "iw"

declare -r default_interface="$(find_default_interface)"
declare interface="${default_interface}"

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
			fail_usage
			;;
		*)
			interface="${1}"
			;;
	esac
elif [[ $# -gt 1 ]]; then
	fail_usage
fi

if [[ -z "${default_interface}" ]]; then
	echo >&2 "no wireless interfaces found"
	exit 3
fi

if ! has_interface "${interface}"; then
	echo >&2 "no such interface \"${interface}\""
	exit 3
elif ! has_wireless_interface "${interface}"; then
	echo >&2 "\"${interface}\" is not a wireless interface"
	exit 3
fi

if ! is_interface_up "${interface}"; then
	echo >&2 "wireless interface \"${interface}\" is down"
	exit 3
fi

if ! iw dev "${interface}" station dump |
	awk '/Station/ { print $2 }'; then
	echo >&2 "operation failed"
	exit 4
fi

exit 0
