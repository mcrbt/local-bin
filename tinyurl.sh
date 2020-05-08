#!/bin/bash
##
## tinyurl - shorten URLs on https://tinyurl.com via command line
## Copyright (C) 2020 Daniel Haase
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

function checkcmd
{
  local c="$1"
  if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
  which "$c" &> /dev/null
  if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
}

checkcmd "curl"
checkcmd "basename"
checkcmd "grep"
checkcmd "perl"

if [ $# -ne 1 ]; then echo "usage:  $(basename 0) <url>"; exit 1; fi

curl --silent "https://tinyurl.com/create.php?url=$1" | \
  grep "<b>https://tinyurl.com/" | \
  perl -pe 's/.*<b>(https:\/\/tinyurl\.com\/.*?)<\/b>.*/\1/'

if [ $? -ne 0 ]; then echo "operation failed"; exit 2; fi

exit 0
