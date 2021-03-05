#!/bin/bash
##
## monitor - quick information about connected monitors
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

APP="$0"
VERSION="0.1.0"

function checkcmd
{
  local c="$1"
  if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
  which "$c" &> /dev/null
  if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
  return 0
}

function list
{
  xrandr --listmonitors | awk '/\+/ {print $4}'
}

function count
{
  xrandr --listmonitors | awk '/^Monitor/ {print $2}'
}

function version
{
  echo "$APP version $VERSION"
  echo " - quick information about connected monitors"
  echo "copyright (C) 2020 Daniel Haase"
}

function help
{
  version
  echo ""
  echo "usage:  $APP [list | count | version | help]"
  echo ""
  echo "  list | --list | -l"
  echo "    list names of detected monitor interfaces"
  echo ""
  echo "  count | --count | -c"
  echo "    print number of detected monitors"
  echo ""
  echo "  version | --version | -V"
  echo "    print version information"
  echo ""
  echo "  help | --help | -h"
  echo "    print this help message"
  echo ""
}

checkcmd "awk"
checkcmd "basename"
checkcmd "xrandr"

APP="$(basename $APP)"

if [ "$APP" == "monitorlist" ] || [ "$APP" == "monlist" ]
then list; exit 0
elif [ "$APP" == "monitorcount" ] || [ "$APP" == "moncount" ]
then count; exit 0
elif [ "$APP" == "monitor" ] || [ "$APP" == "mon" ]; then
  if [ $# -eq 1 ]; then
    if [ "$1" == "list" ] || [ "$1" == "--list" ] || [ "$1" == "-l" ]
    then list; exit 0
    elif [ "$1" == "count" ] || [ "$1" == "--count" ] || [ "$1" == "-c" ]
    then count; exit 0
    elif [ "$1" == "version" ] || [ "$1" == "--version" ] || [ "$1" == "-V" ]
    then version; exit 0
    elif [ "$1" == "help" ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]
    then help; exit 0; fi
  else help; exit 2; fi
else echo "unkown script name \"$APP\""; exit 3; fi

exit 0
