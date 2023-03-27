#!/usr/bin/env bash
##
## printers - list network printers and their IP address
## Copyright (C) 2021-2023  Daniel Haase
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

# shellcheck disable=SC2155

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

NAME="printers"
VERSION="0.2.0"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo >&2 "no such command \"${1}\""
		exit 1
	fi
}

function print_version {
	cat <<-EOF
		${NAME} ${VERSION}
		copyright (c) 2021-2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${NAME} [--verbose | --quiet]
		        ${NAME} [--version | --help]

		   -v | --verbose
		      be a little bit more chatty (default)

		   -q | --quiet
		      only print relevant output, if any

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

check_command "cat"
check_command "cut"
check_command "lpstat"
check_command "wc"

declare -i verbose=1

if [[ $# -eq 1 ]]; then
	case "${1}" in
		-v | --verbose)
			verbose=1
			;;
		-q | --quiet)
			verbose=0
			;;
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
			;;
	esac
elif [[ $# -gt 1 ]]; then
	print_usage
	exit 2
fi

declare -r status="$(lpstat -r)"

if [[ "${status,,}" != "scheduler is running" ]]; then
	echo >&2 "CUPS server not running"
	exit 2
fi

declare -ri printer_count="$(lpstat -e 2>/dev/null | wc --lines)"

if [[ ${printer_count} -lt 1 ]]; then
	echo >&2 "no printers found"
	exit 0
fi

if [[ ${verbose} -gt 0 ]]; then
	declare -r indent="   "

	if [[ ${printer_count} -eq 1 ]]; then
		echo "found 1 printer:"
	else
		echo "found ${printer_count} printers:"
	fi
fi

declare name
declare address

while read -r printer; do
	name="$(echo "${printer}" | cut --delimiter=" " --fields=3)"
	address="$(echo "${printer}" | cut --delimiter=" " --fields=4)"

	echo "${indent:-""}${name:0:-1} at ${address#*:\/\/}"
done <<<"$(lpstat -v)"

exit 0
