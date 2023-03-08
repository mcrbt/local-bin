#!/usr/bin/env bash
##
## ddg - search the web with DuckDuckGo from command line
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

NAME="ddg"
VERSION="3.1.0"

BROWSER_COMMAND="${BROWSER_COMMAND:-"firefox --new-tab"}"

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

		usage:  ${NAME} [--version | --help] <phrase>...

		   <phrase>...
		      one or more phrases to search for

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

declare -r command_name="${BROWSER_COMMAND%% *}"

check_command "${command_name}"
check_command "sed"

if [[ $# -eq 0 ]]; then
	print_usage
	exit 2
else
	case "${1}" in
		-V | --version)
			print_version
			exit 0
			;;
		-h | --help)
			print_usage
			exit 0
			;;
		*) ;;
	esac
fi

declare -r expanded_command
declare -r query

expanded_command="$(command -v "${command_name}")" \
	"${BROWSER_COMMAND/#${command_name} /}"
query=$(echo "${*}" | sed --expression='s/\+/%2B/g' --expression='s/ /+/g')

declare url="https://start.duckduckgo.com"

if [[ -n "${query}" ]]; then
	url="${url}/?q=${query}"
fi

if ! eval "${expanded_command} ${url} &>/dev/null &"; then
	echo "failed to open browser \"${command_name}\""
	exit 2
fi

exit 0
