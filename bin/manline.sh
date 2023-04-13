#!/usr/bin/env bash
##
## manline - open manual pages online at https://www.man7.org
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

TITLE="manline"
VERSION="0.3.0"

BROWSER_COMMAND="${BROWSER_COMMAND:-"firefox --new-tab"}"
MANUAL_DOMAIN="https://www.man7.org"
DEFAULT_SECTION="1"

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

		usage:  ${TITLE} [<section>] <page>
		        ${TITLE} [--version | --help]

		   <section>
		      manual page section (1-8, L, N)
		      (default 1: \"user commands\")

		   <page>
		      manual page to open
		      (name of command, system call, ...)

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function fail_usage {
	print_usage
	exit 2
}

function is_valid_section {
	local -r regex="^[1-8LN]\$"

	[[ "${1}" =~ ${regex} ]]
}

function is_valid_page {
	[[ -n "${1}" && "${1}" != "-"* ]]
}

declare -r command_name="${BROWSER_COMMAND%% *}"
declare expanded_command

check_command "${command_name}"

expanded_command="$(command -v "${command_name}") "
expanded_command+="${BROWSER_COMMAND/#${command_name} /}"

declare section="${DEFAULT_SECTION}"
declare page

if [[ $# -eq 0 ]]; then
	fail_usage
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
			page="${1}"
			;;
	esac
elif [[ $# -eq 2 ]]; then
	section="${1}"
	page="${2}"
else
	fail_usage
fi

if ! is_valid_page "${page}"; then
	echo >&2 "invalid manual page \"${page}\""
	exit 3
fi

if ! is_valid_section "${section}"; then
	echo >&2 "invalid manual section \"${section}\""
	exit 3
fi

declare url="${MANUAL_DOMAIN}/linux/man-pages/"
url+="man${section}/${page}.${section}.html"

if ! eval "${expanded_command} ${url} &>/dev/null &"; then
	declare message="failed to open browser \"${command_name}\" "
	message+="with manual page \"${page}\""

	echo >&2 "${message}"
	exit 4
fi

exit 0
