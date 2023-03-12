#!/usr/bin/env bash
##
## wikipedia - open specific Wikipedia article from command line
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

TITLE="wikipedia"
VERSION="0.3.5"

BROWSER_COMMAND="${BROWSER_COMMAND:-"firefox --new-tab"}"
DEFAULT_LANGUAGE="en"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo >&2 "no such command \"${1}\""
		exit 1
	fi
}

function print_version {
	cat <<-EOF
		${TITLE} ${VERSION}
		copyright (c) 2020-2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${TITLE} [-l <language>] <phrase>...
		        ${TITLE} [-V|-h]

		   <phrase>...
		      arbitrarily many phrases to search for on Wikipedia

		   -l <language> | --language <language>
		      two- or three-digit language code to search Wikipedia in

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

function prepare_query() {
	local -a phrases=("$@")
	local query="${phrases[*]}"

	query="$(echo -n "${query:0:1}" | tr "[:lower:]" "[:upper:]")${query:1}"
	echo "${query[*]// /_}"
}

declare -r command_name="${BROWSER_COMMAND%% *}"

check_command "${command_name}"
check_command "cat"
check_command "tr"

declare language="${DEFAULT_LANGUAGE}"
declare -a phrases=()
declare expanded_command

expanded_command="$(command -v "${command_name}") "
expanded_command+="${BROWSER_COMMAND/#${command_name} /}"

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
			phrases=("${1}")
			;;
	esac
elif [[ $# -eq 2 ]]; then
	case "${1}" in
		-*)
			fail_usage
			;;
		*)
			phrases=("$@")
			;;
	esac
elif [[ $# -gt 2 ]]; then
	case "${1}" in
		-l | --language)
			if [[ "${#2}" -lt 2 || "${#2}" -gt 3 ]]; then
				fail_usage
			fi

			language="${2}"
			shift 2
			;;
		-*)
			fail_usage
			;;
		*) ;;
	esac

	phrases=("$@")
fi

declare url="https://www.wikipedia.org/"
declare query

query="$(prepare_query "${phrases[@]}")"

if [[ -n "${query}" ]]; then
	url="https://${language}.wikipedia.org/wiki/${query}"
fi

if ! eval "${expanded_command} ${url} &>/dev/null &"; then
	echo >&2 "failed to open browser \"${command_name}\""
	exit 3
fi

exit 0
