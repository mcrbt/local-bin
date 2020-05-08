#!/bin/bash

## mounts - list only the "interesting" file system mounts
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

function checkcmd
{
  local c="$1"
  if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
  which "$c" &> /dev/null
  if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
  return 0
}

checkcmd "awk"
checkcmd "grep"
checkcmd "mount"

mount | grep /dev/sd | awk '{print $1" "$2" "$3" as "$5}' ## partitions, USB drives, ...
if [ $? -ne 0 ]; then echo "failed to list mounts"; exit 2; fi
mount | grep /dev/mmc | awk '{print $1" "$2" "$3" as "$5}' ## SD cards
if [ $? -ne 0 ]; then echo "failed to list SD card mounts"; exit 3; fi

exit 0
