#!/usr/bin/env bash
##
## pw - generate password(s) of configurable length(s) using "pwgen"
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

NAME="pw"
VERSION="0.3.0"

DEFAULT_LENGTH="${DEFAULT_LENGTH:-31}"
DEFAULT_COUNT="${DEFAULT_COUNT:-1}"

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

		usage:  ${NAME} [<length>] [<count>]
		        ${NAME} [--version | --help]

		   <length>
		      generate password of <length> characters
		      (defaults to ${DEFAULT_LENGTH})

		   <count>
		      generate <count> different passwords of
		      <length> characters each
			  (defaults to ${DEFAULT_COUNT})

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

function is_number {
	declare -r argument="${1}"
	declare -r number_regex="^[0-9]+$"

	if [[ "${argument}" =~ ${number_regex} ]]; then
		return 0
	else
		return 1
	fi
}

check_command "pwgen"

declare password_length="${DEFAULT_LENGTH}"
declare password_count="${DEFAULT_COUNT}"

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
			password_length="${1}"
			;;
	esac
elif [[ $# -eq 2 ]]; then
	password_length="${1}"
	password_count="${2}"
elif [[ $# -gt 2 ]]; then
	fail_usage
fi

if ! is_number "${password_length}" ||
	! is_number "${password_count}"; then
	fail_usage
fi

if ! pwgen --capitalize --numerals --symbols --secure -1 \
	"${password_length}" "${password_count}" 2>/dev/null; then
	echo >&2 "operation failed"
	exit 3
fi

exit 0
