#!/usr/bin/env -S bash
##
## space - list available storage space of relevant devices
## Copyright (C) 2023 Daniel Haase
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

#VERSION="0.2.1"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo "no such command \"${1}\""
		exit 1
	fi
}

check_command "awk"
check_command "df"
check_command "grep"
check_command "sed"

df -h |
	grep '/dev/\(sd\|mmcblk\)..' |
	awk '{print $1" "$0}' |
	sed -e 's/\/dev\/sda6/\[root\]/' \
		-e 's/\/dev\/sda8/\[home\]/' \
		-e 's/\/dev\/sda2/\[boot\]/' \
		-e 's/\/dev\/mmcblk[0-9]p[0-9]/\[sd\]/' \
		-e 's/\/dev\/sdb[0-9]/\[usb\]/' |
	awk '{ printf "%-16s %6s:    %7s\n", $2, $1, $5 }'

exit 0
