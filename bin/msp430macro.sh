#!/usr/bin/env bash
##
## msp430macro - grep MSP430 macros/registers in device-specific header file
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

TITLE="msp430macro"
VERSION="0.3.5"

DEFAULT_DEVICE_NAME="msp430f5529"
DEVICE_NAME="${DEVICE_NAME:-"${DEFAULT_DEVICE_NAME}"}"
INCLUDE_PATH="${INCLUDE_PATH:-"/opt/ti/mspgcc/include"}"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		>&2 echo "no such command \"${1}\""
		exit 1
	fi
}

function print_version {
	cat <<-EOF
		${TITLE} version ${VERSION}
		copyright (c) 2020-2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${TITLE} [<device>] <pattern>
		        ${TITLE} [--version | --help]

		   <device>
		      full MSP430 device name (e.g., \"msp430f2013\")
		      (defaults to \"${DEFAULT_DEVICE_NAME}\")

		   <pattern>
		      pattern to search for (e.g., macro, register, comment, ...)

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

check_command "grep"

declare pattern

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
		*)
			pattern="${1}"
			;;
	esac
elif [[ $# -ge 2 ]]; then
	DEVICE_NAME="${1}"
	shift
	pattern="${*}"
fi

if [[ ! -d "${INCLUDE_PATH}" ]]; then
	>&2 echo "no such include directory \"${INCLUDE_PATH}\""
	exit 3
fi

declare -r filepath="${INCLUDE_PATH}/${DEVICE_NAME}.h"

if [[ ! -f "${filepath}" ]]; then
	>&2 echo "no such header file \"${filepath}\""
	exit 3
fi

if [[ ! -r "${filepath}" ]]; then
	>&2 echo "no read permission for file \"${filepath}\""
	exit 3
fi

if ! grep --color=auto "${pattern}" "${filepath}" 2>/dev/null; then
	>&2 echo "no matches found for pattern \"${pattern}\""
	exit 4
fi

exit 0
