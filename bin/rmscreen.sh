#!/usr/bin/env bash
##
## rmscreen - remove last screenshot accidentally taken
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

# shellcheck disable=SC2012,SC2155,SC2310

set -o errexit
set -o nounset
set -o pipefail

NAME="rmscreen"
VERSION="0.2.0"

SCREENSHOT_DIRECTORY="${SCREENSHOT_DIRECTORY:-""}"

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

		usage:  ${NAME} [--force | --version | --help]

		   -f | --force
		      delete screenshot even if not from today

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function find_subdirectory_by_regex {
	local -r parent_directory="${1}"
	local -r regex="${1}"

	if [[ -z "${parent_directory}" ||
		! -d "${parent_directory}" ||
		-z "${regex}" ]]; then
		return 1
	fi

	for directory in "${parent_directory}"/*; do
		if [[ ! -d "${directory}" ]]; then
			continue
		fi

		if [[ "${directory,,}" =~ ${regex} ]]; then
			echo "${directory}"
			return 0
		fi
	done

	return 1
}

function find_picture_directory {
	local directory="$(xdg-user-dir PICTURES)"

	if [[ -d "${directory}" ]]; then
		echo "${directory}"
		return 0
	fi

	if [[ -z "${HOME}" || ! -d "${HOME}" ]]; then
		return 1
	fi

	local -r regex=".*(pic|image).*"

	find_subdirectory_by_regex "${directory}" "${regex}"
}

function find_screenshot_directory {
	if [[ -n "${SCREENSHOT_DIRECTORY}" &&
		-d "${SCREENSHOT_DIRECTORY}" ]]; then
		echo "${SCREENSHOT_DIRECTORY}"
		return 0
	fi

	local picture_directory="$(find_picture_directory)"
	local directory

	if [[ -z "${picture_directory}" ||
		! -d "${picture_directory}" ]]; then
		return 1
	fi

	find_subdirectory_by_regex "${picture_directory}" ".*screen.*"
}

function find_latest_screenshot {
	local -r directory="${1}"

	if [[ -z "${directory}" || ! -d "${directory}" ]]; then
		return 1
	fi

	ls --almost-all --sort=time "${1}" | head --lines=1
} 2>/dev/null

function get_file_birth {
	local -r filepath="${1}"

	if [[ -z "${filepath}" || ! -f "${filepath}" ]]; then
		return 1
	fi

	local birth="$(stat --format=\"%w\" "${filepath}" |
		cut --delimiter=\" \" --fields=1)"

	if [[ "${birth}" == "-" ]]; then
		birth="$(stat --format=\"%y\" "${filepath}" |
			cut --delimiter=\" \" --fields=1)"
	fi

	echo "${birth}"
}

function is_today {
	if [[ "${1}" == "$(date +%Y-%m-%d)" ]]; then
		return 0
	else
		return 1
	fi
}

function confirm_deletion {
	local -r filepath="${1}"
	local choice

	echo -n "delete \"${filepath}\"? (Y/n) "
	read -r choice

	if [[ "${choice,,}" == "y"* ]]; then
		return 0
	fi

	return 1
}

check_command "date"
check_command "cat"
check_command "cut"
check_command "head"
check_command "ls"
check_command "rm"
check_command "stat"
check_command "xdg-user-dir"

declare force=0

if [[ $# -eq 1 ]]; then
	case "${1}" in
		-f | --force)
			force=1
			;;
		-V | --version)
			print_version
			exit 0
			;;
		-h | --help)
			print_usage
			exit 0
			;;
		*)
			print_usage
			exit 2
			;;
	esac
fi

declare -r directory="$(find_screenshot_directory)"

if [[ ! -d "${directory}" ]]; then
	echo >&2 "failed to locate screenshot directory"
	exit 3
fi

declare -r screenshot="$(find_latest_screenshot "${directory}")"

if [[ -z "${screenshot}" ]]; then
	echo "no screenshots found"
	exit 0
fi

if [[ ! -f "${directory}/${screenshot}" ]]; then
	echo >&2 "failed to locate most recent screenshot"
	exit 3
fi

if [[ "${force}" -lt 1 ]]; then
	declare file_birth="$(get_file_birth "${screenshot}")"

	if ! is_today "${file_birth}"; then
		echo "most recent screenshot is not from today"
		exit 0
	fi
fi

if ! confirm_deletion "${directory}/${screenshot}"; then
	exit 0
fi

if [[ ! -w "${directory}" || ! -x "${directory}" ]]; then
	echo >&2 "insufficient directory permissions to delete screenshot"
	exit 3
fi

if ! rm --force "${directory}/${screenshot}" 2>/dev/null; then
	echo >&2 "operation failed"
	exit 4
fi

cat <<-EOF
	successfully removed screenshot
	   "${directory}/${screenshot}"
EOF

exit 0
