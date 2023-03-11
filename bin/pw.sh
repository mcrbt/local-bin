#!/usr/bin/env bash
##
## pw - generate password of configurable length using secpwgen
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

NAME="pw"
VERSION="0.2.0"

DEFAULT_LENGTH="${DEFAULT_LENGTH:-31}"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		>&2 echo "no such command \"${1}\""
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

		usage:  ${NAME} [--raw] [<length>]
		        ${NAME} [--version | --help]

		   <length>
		      generate password of at least <length> characters
		      (defaults to ${DEFAULT_LENGTH})

		   -r | --raw
		      generate password of (<length> * 8) arbitrary bits
		      (BASE64-encoded)

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function fail_usage {
	>&2 print_usage
	exit 2
}

check_command "cut"
check_command "head"
check_command "secpwgen"
check_command "tail"

declare password_length="${DEFAULT_LENGTH}"
declare generation_mode="-Aads"

if [[ $# -eq 1 ]]; then
	case "${1}" in
		-r | --raw)
			generation_mode="-r"
			;;
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
			password_length="${1}"
			;;
	esac
elif [[ $# -eq 2 ]]; then
	case "${1}" in
		-r | --raw)
			generation_mode="-r"
			;;
		*)
			fail_usage
			;;
	esac

	if [[ "${2}" == "-"* ]]; then
		fail_usage
	fi

	password_length="${2}"
elif [[ $# -gt 2 ]]; then
	fail_usage
fi

declare -r number_regex="^[0-9]+$"

if ! [[ "${password_length}" =~ ${number_regex} ]]; then
	fail_usage
fi

if [[ "${generation_mode}" == "-r" ]]; then
	password_length=$((password_length * 8))
fi

if ! secpwgen "${generation_mode}" "${password_length}" 2>/dev/null |
	head --lines=-3 |
	tail --lines=-1 |
	cut --delimiter=" " --fields=1 2>/dev/null; then
	>&2 echo "operation failed"
	exit 3
fi

exit 0
