#!/usr/bin/env bash
##
## mirrorgen - generate fresh pacman mirrorlist with reflector
## Copyright (C) 2022-2023 Daniel Haase
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

NAME="mirrorgen"
VERSION="0.4.6"

DATE=$(date +%y%m%d)

PACMAN_PATH="${PACMAN_PATH:-"/etc/pacman.d"}"
MIRROR_FILE="${PACMAN_PATH}/${NAME}${DATE}.list"
MIRROR_LIST="${PACMAN_PATH}/mirrorlist"
BACKUP_FILE="${PACMAN_PATH}/mirrorlist.bak"

COUNTRIES="Germany,Denmark,Netherlands"
MAX_SERVERS=15

function print_version {
	cat <<-EOF
		${NAME} ${VERSION}
		copyright (c) 2022-2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${NAME} [--update | --version | --help]

		   --update
		      directly update the actual mirrorlist file
		      "${MIRROR_LIST}"
		      (a potential backup file will be overridden)

		   --version
		      print version and copyright information and exit

		   --help
		      print this usage description and exit

	EOF
}

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo "no such command \"${1}\""
		exit 1
	fi
}

function rename {
	local -r old_name="${1}"
	local -r new_name="${2}"

	if [[ -f "${old_name}" ]]; then
		mv --interactive "${old_name}" "${new_name}"
	fi
}

update=0

if [[ $# -eq 1 ]]; then
	case "${1}" in
		--update)
			update=1
			;;
		--version)
			print_version
			exit 0
			;;
		--help)
			print_usage
			exit 0
			;;
		*)
			print_usage
			exit 3
			;;
	esac
elif [[ $# -gt 1 ]]; then
	print_usage
	exit 3
fi

check_command "cat"
check_command "date"
check_command "grep"
check_command "mv"
check_command "pacman"
check_command "reflector"
check_command "rm"

if ! reflector \
	--threads 4 \
	--connection-timeout 7 \
	--protocol "https" \
	--country "${COUNTRIES}" \
	--age 1 \
	--completion-percent 100 \
	--fastest "${MAX_SERVERS}" \
	--sort "score" \
	--save "${MIRROR_FILE}" \
	&>/dev/null; then
	echo >&2 "operation failed"
	exit 4
fi

if [[ -f "${MIRROR_FILE}" && -s "${MIRROR_FILE}" ]]; then
	count=$(grep --count 'Server = ' "${MIRROR_FILE}")

	if [[ ${update} -ge 1 ]]; then
		rename "${MIRROR_LIST}" "${BACKUP_FILE}"
		rename "${MIRROR_FILE}" "${MIRROR_LIST}"

		echo "successfully updated mirrorlist with ${count} servers"
	else
		cat <<-EOF
			successfully generated mirrorlist with ${count} servers:
			   "${MIRROR_FILE}"
		EOF
	fi
else
	if [[ -f "${MIRROR_FILE}" ]]; then
		rm --force "${MIRROR_FILE}"
	fi

	echo "failed to generate mirrorlist"
	exit 2
fi

exit 0
