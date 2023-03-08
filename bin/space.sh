#!/usr/bin/env bash
##
## space - list available storage space of relevant devices
## Copyright (C) 2023  Daniel Haase
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

NAME="space"
VERSION="0.4.0"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo "no such command \"${1}\""
		exit 1
	fi
}

function print_version {
	cat <<-EOF
		${NAME} ${VERSION}
		copyright (c) 2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${NAME} [--version | --help]

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

check_command "awk"
check_command "df"
check_command "grep"
check_command "sed"

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
		*)
			print_usage
			exit 2
			;;
	esac
elif [[ $# -gt 1 ]]; then
	print_usage
	exit 2
fi

expression='/dev/((sd[a-z][0-9]+)|(nvme[0-9]+n[0-9]+)|(mmcblk[0-9]+p[0-9]+))'

df --human-readable --local --output=source,avail,target |
	grep --perl-regexp "${expression}" |
	awk '{print $1" "$0}' |
	sed --expression='s/\(.\+ \+.\+ \+.\+ \+.\+ \+\)\/$/\1 [root]/g' \
		--expression='s/\/home.*/ [home]/' \
		--expression='s/\/\(boot\)\|\(efi\).*$/ [boot]/' \
		--expression='s/\(\/dev\/mmcblk[0-9]p[0-9] \+.\+ \+.\+ \+.\+ \+\)/\1 [sdcard]/' \
		--expression='s/\/mnt.*/ [usb]/' \
		--expression='s/\(.\+ \+.\+ \+.\+ \+.\+ \+\)\/.\+$/\1 [other]/g' |
	awk '{ printf "%-17s  %8s:   %7s\n", $2, $4, $3 }'

exit 0
