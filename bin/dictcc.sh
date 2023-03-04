#!/usr/bin/env bash
##
## dictcc - translate a pattern on <https://dict.cc>
## Copyright (C) 2020-2023 Daniel Haase
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

export VERSION="0.2.0"
BROWSER_COMMAND="firefox --new-tab"

url="https://dict.cc"
query="${*}"
browser="${BROWSER_COMMAND%% *}"

if ! command -v "${browser}" &>/dev/null; then
	echo "no such command \"${browser}\""
	exit 1
fi

if [[ $# -gt 0 && -n "${query}" ]]; then
	url="${url}/?s=${query// /+}"
fi

if ! eval "${BROWSER_COMMAND} ${url} &>/dev/null &"; then
	echo "failed to open browser \"${browser}\""
	exit 2
fi

exit 0
