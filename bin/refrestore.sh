#!/usr/bin/env bash
##
## refrestore - reopen hyperlinks read from ASCII file in firefox
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

NAME="refrestore"
VERSION="0.3.0"

BROWSER_COMMAND="${BROWSER_COMMAND:-"firefox --new-tab"}"
VERBOSE="${VERBOSE:-0}"

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

		usage:  ${NAME} [--verbose] [<resource>...]
		        ${NAME} [--version | --help]

		   <resource>...
		      TODO: file, directory, URL

		   -v | --verbose
		      TODO

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function is_link {
	local -r regex="^https?://.+"

	if [[ "${1}" =~ ${regex} ]]; then
		return 0
	fi

	return 1
}

function open_link {
	local -r link="${1}"

	if ! is_link "${link}"; then
		return 1
	fi

	if [[ ${VERBOSE} -gt 0 ]]; then
		echo "opening \"${link}\"..."
	fi

	if ! eval "${expanded_command} ${link} &>/dev/null &"; then
		return 1
	fi

	sleep 1
}

function open_link_files {
	local -r directory="${1}"

	if [[ ! -d "${directory}" || ! -r "${directory}" ]]; then
		echo >&2 "failed to read directory \"${directory}\""
		exit 3
	fi

	local link

	for file in "${directory}/"*.{href,url}; do
		if [[ -f "${file}" ]]; then
			open_link "$(< "${file}")"
		fi
	done
}

function open_file_links {
	local -r file="${1}"

	if [[ ! -f "${file}" ]]; then
		echo >&2 "failed to read file \"${file}\""
		exit 3
	fi

	while read -r link; do
		open_link "${link}"
	done <"${file}"
}

function process_argument {
	local -r argument="${1}"

	if is_link "${argument}"; then
		open_link "${argument}"
	elif [[ -f "${argument}" ]]; then
		if [[ -r "${argument}" ]]; then
			open_file_links "${argument}"
		else
			echo >&2 "file \"${argument}\" is not readable"
			exit 3
		fi
	elif [[ -d "${argument}" ]]; then
		if [[ -r "${argument}" ]]; then
			open_link_files "${argument}"
		else
			echo >&2 "directory \"${argument}\" is not readable"
			exit 3
		fi
	else
		echo >&2 "invalid argument \"${argument}\""
		exit 3
	fi
}

declare -r command_name="${BROWSER_COMMAND%% *}"

check_command "${command_name}"

declare expanded_command

expanded_command="$(command -v "${command_name}") "
expanded_command+="${BROWSER_COMMAND/#${command_name} /}"

check_command "cat"
check_command "pwd"
check_command "sleep"

if [[ $# -eq 0 ]]; then
	process_argument "$(pwd)"
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
		-v | --verbose)
			VERBOSE=1
			process_argument "$(pwd)"
			;;
		*)
			process_argument "${1}"
			;;
	esac
else
	while [[ $# -gt 0 ]]; do
		process_argument "${1}"
		shift
	done
fi

exit 0
