#!/usr/bin/env bash
##
## pgplookup - query keyserver for PGP keys
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

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

NAME="pgplookup"
VERSION="0.2.0"

DEFAULT_KEY_SERVER="https://keyserver.ubuntu.com"
KEY_SERVER="${KEY_SERVER:-"${DEFAULT_KEY_SERVER}"}"
URL_PATH="/pks/lookup"
URL_ARGUMENTS="&fingerprint=on&op=index"

BROWSER_COMMAND="${BROWSER_COMMAND:-"firefox --new-tab"}"

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

		usage:  ${NAME} [<query>]
		        ${NAME} [--version | --help]

		   <query>
		      query to search key server for
		      (default key server is "${DEFAULT_KEY_SERVER}")

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

declare -r command_name="${BROWSER_COMMAND%% *}"
declare url="${KEY_SERVER}"
declare query=""

check_command "${command_name}"

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
			query="${1}"
			;;
	esac
elif [[ $# -gt 1 ]]; then
	query="${*}"
fi

if [[ -n "${query}" ]]; then
	url+="${URL_PATH}?search=${query// /+}${URL_ARGUMENTS}"
fi

if ! eval "${BROWSER_COMMAND} \"${url}\" &>/dev/null &"; then
	echo >&2 "failed to open browser \"${command_name}\""
	exit 3
fi

exit 0
