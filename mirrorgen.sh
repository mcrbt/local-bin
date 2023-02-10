#!/usr/bin/env -S bash
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
VERSION="0.4.1"

TZ=Europe/Berlin
DATE=$(TZ="${TZ}" date +%y%m%d)

PACPATH="/etc/pacman.d"
MIRRORFILE="${PACPATH}/${NAME}${DATE}.list"
MIRRORLIST="${PACPATH}/mirrorlist"
BACKUPFILE="${PACPATH}/mirrorlist.bak"

MAX_SERVERS=15

function version
{
	cat <<-EOF
	${NAME} ${VERSION}
	copyright (c) 2022-2023 Daniel Haase
	EOF
}

function usage
{
	version

	cat <<-EOF

	usage:  ${NAME} [--update | --version | --help]

	   --update
	      directly update the actual mirrorlist file
	      "${MIRRORLIST}" (a potential backup file
	      "${BACKUPFILE}" will be overridden)

	   --version
	      print version and copyright information and exit

	   --help
	      print this usage description and exit

	EOF
}

function check_command
{
	local command="${1}"

	if [[ $# -eq 0 ]] \
	|| [[ -z "${command}" ]] \
	|| command -v "${command}" &>/dev/null; then
		return 0
	else
		echo "no such command \"${command}\""
		exit 1
	fi
}

function rename
{
	local old_name="${1}"
	local new_name="${2}"

	if [[ -f "${old_name}" ]]; then
		mv --interactive "${old_name}" "${new_name}"
	fi
}

UPDATE=0

if [[ $# -eq 1 ]]; then
	case "${1}" in
		--update)
			UPDATE=1
			;;
		--version)
			version
			exit 0
			;;
		--help)
			usage
			exit 0
			;;
		*)
			usage
			exit 3
			;;
	esac
elif [[ $# -gt 1 ]]; then
	usage
	exit 3
fi

check_command "pacman"
check_command "reflector"
check_command "grep"
check_command "mv"

reflector \
	--threads 4 \
	--connection-timeout 7 \
	--protocol "https" \
	--country "Germany,Denmark,Netherlands" \
	--age 1 \
	--completion-percent 100 \
	--fastest "${MAX_SERVERS}" \
	--sort "score" \
	--save "${MIRRORFILE}" \
	&>/dev/null

if [[ -f "${MIRRORFILE}" ]] \
&& [[ -s "${MIRRORFILE}" ]]; then
	COUNT=$(grep --count 'Server = ' "${MIRRORFILE}")

	if [[ ${UPDATE} -ge 1 ]]; then
		rename "${MIRRORLIST}" "${BACKUPFILE}"
		rename "${MIRRORFILE}" "${MIRRORLIST}"

		echo "successfully updated mirrorlist with ${COUNT} servers"
	else
		cat <<-EOF
		successfully generated mirrorlist with ${COUNT} servers:
		   "${MIRRORFILE}"
		EOF
	fi
else
	if [[ -f "${MIRRORFILE}" ]]; then
		rm -f "${MIRRORFILE}"
	fi

	echo "failed to generate mirrorlist"
	exit 2
fi

exit 0
