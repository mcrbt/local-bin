#!/usr/bin/env -S bash
##
## pgplookup - search keyserver for PGP keys
## Copyright (C) 2021, 2023 Daniel Haase
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
BROWSER="firefox --new-tab"
SERVER="https://pgp.key-server.io"

set -o errexit
set -o nounset
set -o pipefail

function checkcmd
{
	local c="${1%% *}"

	if [[ $# -eq 0 ]] \
	|| [[ -z "${c}" ]] \
	|| command -v "${c}" &>/dev/null; then
		return 0
	else
		echo "command \"${c}\" not found"
		exit 1
	fi
}

checkcmd "${BROWSER}"

OPT="search=${*// /+}&fingerprint=on&op=vindex"

if [[ -z "$*" ]]; then
	eval "${BROWSER} ${SERVER} &>/dev/null &"
else
	eval "${BROWSER} '${SERVER}/pks/lookup?${OPT}' &>/dev/null &"
fi

exit 0
