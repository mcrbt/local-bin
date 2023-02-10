#!/usr/bin/env bash
##
## tinyurl - shorten URLs on https://tinyurl.com via command line
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
## dependencies: basename, curl, grep, perl
##
## possible exit codes:
##    0 - success
##    1 - command not found
##    2 - operation failed
##

set -o errexit
set -o nounset
set -o pipefail

function check_command
{
	local command="${1}"

	if [[ $# -eq 0 || -z "${command}" ]] \
	|| command -v "${command}" &>/dev/null; then
		return 0
	else
		echo "no such command \"${command}\""
		exit 1
	fi
}

check_command "curl"
check_command "basename"
check_command "grep"
check_command "perl"

if [[ $# -ne 1 ]]; then
	echo "usage:  $(basename "${0}") <url>"
	exit 2
fi

curl --silent "https://tinyurl.com/create.php?url=${1}" | \
	grep "<b>https://tinyurl.com/" | \
	perl -pe 's/.*<b>(https:\/\/tinyurl\.com\/.*?)<\/b>.*/\1/' \
	|| exit 3

exit 0
