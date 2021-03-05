#!/bin/bash
##
## mspmacro - search for preprocessor macros in specific MSP430 header files
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

## application constants
TITLE="mspmacro"
VERSION="0.1.0"

## configuration constants
DEVICE="msp430f5529"
INCLUDE="/opt/ti/mspgcc/include"
PATTERN=""

## check if command "$1" is installed
function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "${c}" ] \
	|| command -v "${c}" &> /dev/null; then return 0
	else echo "command \"${c}\" not found"; exit 1; fi
}

## print version and copyright notice
function version
{
	echo "${TITLE} version ${VERSION}"
	echo "copyright (c) 2020 Daniel Haase"
}

## print usage information
function usage
{
	version
	echo ""
	echo "usage:  ${TITLE} [<device>] <register>"
	echo "        ${TITLE} [-V | -h]"
	echo ""
	echo "  <device>"
	echo "    the full MSP430 device name (e.g. \"msp430f5529\")"
	echo "    (defaults to \"${DEVICE}\")"
	echo ""
	echo "  <register>"
	echo "    the name of the register, constant, or macro to search"
	echo ""
	echo "  -V | --version"
	echo "    print version and copyright notice and exit"
	echo ""
	echo "  -h | --help"
	echo "    print this usage information and exit"
	echo ""
}

## parse command line arguments
function parse
{
	if [ $# -eq 0 ]; then usage; exit 0
	elif [ $# -eq 1 ]; then
		if [ "${1}" == "-V" ] || [ "${1}" == "--version" ]
		then version; exit 0
		elif [ "${1}" == "-h" ] || [ "${1}" == "--help" ]
		then usage; exit 0
		else PATTERN="${1}"; fi
	elif [ $# -eq 2 ]; then PATTERN="${2}"; DEVICE="${1}"
	else usage; exit 2; fi
}

## check dependencies
checkcmd "grep"

## parse command line argument
parse "$@"

## assemble header file path
FILE="${INCLUDE}/${DEVICE}.h"

## check if file exists
if [ ! -f "${FILE}" ]; then
	echo "file \"${FILE}\" not found"
	exit 3
fi

## retrieve result
RESULT="$(grep "${PATTERN}" < "${INCLUDE}"/"${DEVICE}".h)"

## print result
if [ -z "${RESULT}" ]; then echo "nothing found"
else echo "${RESULT}"; fi

## exit successfully
exit 0
