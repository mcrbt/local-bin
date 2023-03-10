#!/usr/bin/env bash

## mounts - list only the "interesting" file system mounts
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

# shellcheck disable=SC2310

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

NAME="mounts"
VERSION="0.3.1"

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

		usage:  ${NAME} [--sort | --version | --help]

		   -s | --sort
		      sort output lexicographically by device name

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function print_mounts {
	local -r sort_command="${1}"
	local awkscript="/\/dev\/sd|nvme|mmc/ { "
	awkscript+="printf \"%-16s   as   %-8s   on   %s\n\", "
	awkscript+="\$1, \$5, \$3 }"

	mount | "${sort_command}" | awk "${awkscript}"
} 2>/dev/null

check_command "awk"
check_command "cat"
check_command "mount"
check_command "sort"

sort_command="cat"

if [[ $# -eq 1 ]]; then
	case "${1}" in
		-s | --sort)
			sort_command="sort"
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

if ! print_mounts "${sort_command}"; then
	echo "operation failed"
	exit 3
fi

exit 0
