#!/usr/bin/env bash
##
## dictcc - translate a pattern on <https://dict.cc>
## Copyright (C) 2020, 2023 Daniel Haase
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

BROWSER="firefox --new-tab"

function check_command
{
	local command="${1%% *}"

	if [[ $# -eq 0 || -z "${command}" ]] \
	|| command -v "${command}" &>/dev/null; then
		return 0
	else
		echo "no such command \"${command}\""
		exit 1
	fi
}

check_command "sed"
check_command "${BROWSER}"

if [[ $# -eq 0 || -z "${1}" ]]; then
	eval "${BROWSER} https://dict.cc/ &>/dev/null &"
else
	QUERY="$*"
	eval "${BROWSER} https://dict.cc/?s=${QUERY// /+} &>/dev/null &"
fi

exit 0
