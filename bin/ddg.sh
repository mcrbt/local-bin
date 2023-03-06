#!/usr/bin/env bash
##
## ddg - search the web with DuckDuckGo from command line
## Copyright (C) 2020-2021, 2023 Daniel Haase
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

#VERSION="3.0.2"
BROWSER_COMMAND="${BROWSER_COMMAND:-"firefox --new-tab"}"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo "no such command \"${1}\""
		exit 1
	fi
}

command_name="${BROWSER_COMMAND%% *}"
declare -r expanded_command

check_command "${command_name}"
check_command "sed"

expanded_command="$(command -v "${command_name}")" \
	"${BROWSER_COMMAND/#${command_name} /}"

query=$(echo "${@}" | sed -e 's/\+/%2B/g' -e 's/ /+/g')
url="https://start.duckduckgo.com"

if [[ -n "${query}" ]]; then
	url="${url}/?q=${query}"
fi

if ! eval "${expanded_command} ${url} &>/dev/null &"; then
	echo "failed to open browser \"${command_name}\""
	exit 2
fi

exit 0
