#!/usr/bin/env bash
##
## wikipedia - open specific Wikipedia article from command line
## Copyright (C) 2020-2023 Daniel Haase
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

TITLE="wikipedia"
VERSION="0.3.1"

BROWSER_COMMAND="firefox --new-tab"
DEFAULT_LANGUAGE="en"

function check_command {
	local -r command="${1%% *}"

	if ! command -v "${command}" &>/dev/null; then
		echo "no such command \"${command}\""
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

function prepare_query() {
	local -a phrases=("$@")
	local query="${phrases[*]}"

	query="$(echo -n "${query:0:1}" | tr "[:lower:]" "[:upper:]")${query:1}"
	echo "${query[*]// /_}"
}

check_command "${BROWSER_COMMAND}"
check_command "tr"

language="${DEFAULT_LANGUAGE}"
phrases=()

if [[ $# -eq 0 ]]; then
	print_usage
	exit 1
elif [[ $# -eq 1 ]]; then
	case "${1}" in
		-V|--version)
			print_version
			exit 0
			;;
		-h|--help)
			print_usage
			exit 0
			;;
		-*)
			print_usage
			exit 2
			;;
		*)
			phrases=("${1}")
			;;
	esac
elif [[ $# -eq 2 ]]; then
	case "${1}" in
		-*)
			print_usage
			exit 2
			;;
		*)
			phrases=("$@")
			;;
	esac
elif [[ $# -gt 2 ]]; then
	case "${1}" in
		-l|--language)
			if [[ "${#2}" -lt 2 || "${#2}" -gt 3 ]]; then
				print_usage
				exit 2
			fi

			language="${2}"
			shift
			shift
			;;
		-*)
			print_usage
			exit 2
			;;
		*)
			;;
	esac

	phrases=("$@")
fi

URL="https://www.wikipedia.org/"
query=$(prepare_query "${phrases[@]}")

if [[ -n "${query}" ]]; then
	URL="https://${language}.wikipedia.org/wiki/${query}"
fi

if ! eval "${BROWSER_COMMAND} ${URL} &>/dev/null &"; then
	echo "failed to open browser \"${BROWSER_COMMAND%% }\""
	exit 2
fi

exit 0