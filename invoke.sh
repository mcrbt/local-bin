#!/usr/bin/env -S bash
##
## invoke - start background process and suppress any output
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

set -euo pipefail

if [ $# -eq 0 ] || [ -z "$1" ]; then exit 0; fi
while [ "$1" == "invoke" ]; do shift; done

if [ $# -eq 0 ] || [ -z "$1" ]; then exit 0
elif ! command -v "$1" &> /dev/null
then echo "no such command \"$1\""; exit 1; fi

eval "$@" &> /dev/null &
exit 0
