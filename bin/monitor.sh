#!/usr/bin/env bash
##
## monitor - brief information about connected monitors
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

APP="$(basename "${0}")"
VERSION="0.1.0"

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
	cat <<-EOF
	${APP} version ${VERSION}
	 - brief information about connected monitors
	copyright (C) 2020, 2023 Daniel Haase
	EOF
}

function usage
{
	version

	cat <<-EOF

	usage:  ${APP} [list | count | version | help]

	   list | --list | -l
	      list names of detected monitor interfaces

	   count | --count | -c
	      print number of detected monitors

	   version | --version | -V
	      print version information and exit

	   help | --help | -h
	      print this help message and exit

	EOF
}

check_command "awk"
check_command "basename"
check_command "cat"
check_command "xrandr"

case "${APP}" in
	monitorlist|monlist|monitorlist.sh|monlist.sh)
		list
		;;
	monitorcount|moncount|monitorcount.sh|moncount.sh)
		count
		;;
	monitor|mon|monitor.sh|mon.sh)
		if [[ $# -eq 1 ]]; then
			case "${1}" in
				list|--list|-l)
					list
					;;
				count|--count|-c)
					count
					;;
				version|--version|-V)
					version
					;;
				help|--help|-h)
					usage
					;;
				*)
					usage
					exit 2
					;;
			esac
		fi
		;;
	*)
		echo "unknown script name \"${APP}\""
		exit 3
		;;
esac

exit 0
