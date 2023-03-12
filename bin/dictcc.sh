#!/usr/bin/env bash
##
## dictcc - translate a pattern on <https://dict.cc>
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

NAME="dictcc"
VERSION="0.3.1"
BROWSER_COMMAND="${BROWSER_COMMAND:-"firefox --new-tab"}"

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
		      one or more phrases to translate

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

declare -r command_name="${BROWSER_COMMAND%% *}"

if ! command -v "${command_name}" &>/dev/null; then
	echo >&2 "no such command \"${command_name}\""
	exit 1
fi

if [[ $# -ge 1 ]]; then
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
			print_usage >&2
			exit 2
			;;
		*) ;;
	esac
fi

declare url="https://dict.cc"
declare -r query="${*}"
declare expanded_command

expanded_command="$(command -v "${command_name}") "
expanded_command+="${BROWSER_COMMAND/#${command_name} /}"

if [[ $# -gt 0 && -n "${query}" ]]; then
	url="${url}/?s=${query// /+}"
fi

if ! eval "${expanded_command} ${url} &>/dev/null &"; then
	echo >&2 "failed to open browser \"${command_name}\""
	exit 3
fi

exit 0
