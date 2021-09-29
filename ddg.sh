#!/usr/bin/env -S bash
##
## ddg - search the web with DuckDuckGo from command line
## Copyright (C) 2020-2021 Daniel Haase
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

export VERSION="3.0.0"
BROWSER="firefox --new-tab"

function checkcmd
{
	local c="${1%% *}"
	if [ $# -eq 0 ] || [ -z "${c}" ] \
	|| command -v "${c}" &> /dev/null; then return 0
	else echo "command \"${c}\" not found"; exit 1; fi
}

checkcmd "${BROWSER}"
checkcmd "sed"

QUERY=$(echo "$@" | sed -e 's/\+/%2B/g' -e 's/ /+/g')
URL="https://start.duckduckgo.com"

if [ -n "${QUERY}" ]; then URL="${URL}/?q=${QUERY}"; fi
eval "${BROWSER} ${URL}" &> /dev/null &
exit 0
