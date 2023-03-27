#!/usr/bin/env bash
##
## invoke - start background process and suppress any output
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

NAME="invoke"
VERSION="4.2.0"

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

		usage:  ${NAME} [<command> [<argument>...]]
		        ${NAME} [--version | --help]

		   <command> [<argument>...]
		      invoke <command>, optionally passing one or more <argument>s

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

check_command "cat"
check_command "nohup"

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
		*) ;;
	esac
fi

while [[ $# -gt 0 && "${1}" == "${0}" ]]; do
	shift
done

if [[ $# -eq 0 || -z "${1}" ]]; then
	exit 0
fi

check_command "${1}"

nohup "${@}" </dev/null &>/dev/null &
disown &>/dev/null

exit 0
