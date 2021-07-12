#!/usr/bin/env -S bash
##
## printers - list network printers and their IP address
## Copyright (C) 2021 Daniel Haase
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

#VERSION="0.1.1"
VERBOSE=1

set -euo pipefail

function checkcmd
{
	local c="${1%% *}"
	if [ $# -eq 0 ] || [ -z "${c}" ] \
	|| command -v "${c}" &> /dev/null; then return 0
	else echo "command \"${c}\" not found"; exit 1; fi
}

checkcmd "cut"
checkcmd "lpstat"
checkcmd "wc"

CUPS=$(lpstat -r)

if [ -z "${CUPS}" ] \
|| [ "${CUPS}" != "scheduler is running" ]; then
	echo "CUPS server not running"
	exit 1
fi

COUNT=$(lpstat -e | wc -l)

if [ -z "${COUNT}" ] || [ "$COUNT" -lt 2 ]; then
	if [[ "$(lpstat -e)" == "no "* ]]; then
		if [ "$VERBOSE" -gt 0 ]; then
			echo "no printers found"
		fi

		exit 0
	fi
fi

if [ "$VERBOSE" -gt 0 ]; then
	INDENT="  "

	if [ "$COUNT" -eq 1 ]; then
		echo "found ${COUNT} printer:"
	else echo "found ${COUNT} printers:"; fi
fi

while read -r printer; do
	name=$(echo "${printer}" | cut -d ' ' -f 3)
	addr=$(echo "${printer}" | cut -d ' ' -f 4)
	echo "${INDENT:-""}${name:0:-1} at ${addr#*:\/\/}"
done <<< "$(lpstat -v)"

exit 0
