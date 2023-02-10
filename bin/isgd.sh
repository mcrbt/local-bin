#!/bin/bash
##
## isgd - shorten URLs on https://is.gd via command line
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

function check_command
{
	local c="${1}"

	if [[ $# -eq 0 || -z "${c}" ]] \
	|| command -v "${c}" &>/dev/null; then
		return 0
	else
		echo "command \"${c}\" not found"
		exit 1
	fi
}

check_command "basename"
check_command "curl"
check_command "grep"
check_command "perl"
check_command "pgrep"

if [[ $# -ne 1 ]]; then
	echo "usage:  $(basename "${0}") <url>"
	exit 2
fi

if [[ -z "$(pgrep tor)" ]]; then
	curl --silent "https://is.gd/create.php?url=${1}" | \
		grep "short_url" | \
		perl -pe 's/.*value="(https:\/\/is\.gd\/.*?)".*/\1/'
else
	curl --silent --socks5 127.0.0.1:9050 \
			"https://is.gd/create.php?url=${1}" | \
		grep "short_url" | \
		perl -pe 's/.*value="(https:\/\/is\.gd\/.*?)".*/\1/'
fi

exit 0
