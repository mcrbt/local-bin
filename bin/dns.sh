#!/usr/bin/env bash
##
## dns - wrapper around "host" for (reverse) domain name lookups
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

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

NAME="dns"
VERSION="0.3.0"

TIMEOUT=4

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo "no such command \"${1}\""
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

		usage:  ${NAME} <address>...
		        ${NAME} [--version | --help]

		   <address>...
		      IP address(es) or domain name(s) to resolve

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function resolve {
	local -ra addresses=("${@}")

	for address in "${addresses[@]}"; do
		if [[ "${address}" == "-"* ]]; then
			continue
		fi

		host -W "${TIMEOUT}" "${address}" |
			grep --extended-regexp "(domain name)|(address)" |
			rev |
			cut --delimiter=" " --fields=1 |
			rev |
			sed --expression='s/\(.\+\)\.$/\1/g'
	done
}

check_command "cut"
check_command "grep"
check_command "host"
check_command "rev"
check_command "sed"

if [[ $# -eq 0 ]]; then
	print_usage
	exit 2
elif [[ $# -eq 1 ]]; then
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
		*) ;;
	esac
elif [[ $# -gt 1 ]]; then
	case "${1}" in
		-*)
			print_usage
			exit 2
			;;
		*) ;;
	esac
fi

resolve "${*}"

exit 0
