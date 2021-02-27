#!/bin/bash
##
## doxystrip - strip documentation and comments from doxygen "Doxyfile"
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

TITLE="doxystrip"
AUTHOR="Daniel Haase"
VERSION="0.1.1"
CRYRS="2020-2021"

KEEP_SECTION_SEPARATORS=0
CREATE_BACKUP=1
file="Doxyfile"
dupl="Doxyfile.bak"

function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
	return 0
}

function version
{
	echo "$TITLE version $VERSION"
	echo "copyright (c) $CRYRS $AUTHOR"
	echo "strip documentation and comments from doxygen's \"Doxyfile\""
}

function usage
{
	echo ""
	version
	echo ""
	echo "usage:  $TITLE [-s | -S] [-b | -B] [<doxyfile>]"
	echo "        $TITLE -V | -h"
	echo ""
	echo "  <doxyfile>"
	echo "    specify alternative Doxyfile filename or prepend a path"
	echo ""
	echo "  -s | --sections"
	echo "    mark configuration sections with a separating line"
	echo ""
	echo "  -S | --no-sections"
	echo "    do not mark configuration sections (default)"
	echo ""
	echo "  -b | --backup"
	echo "    create a backup of the file before stripping it (default)"
	echo "    the backup file will have the extension \".bak\" or an"
	echo "    additional timestamp if the file with only the \".bak\""
	echo "    extension already exists"
	echo ""
	echo "  -B | --no-backup"
	echo "    do not create a backup file"
	echo ""
	echo "  -V | --version"
	echo "    print version information"
	echo ""
	echo "  -h | --help"
	echo "    print this usage information"
	echo ""
	echo ""
	echo "if no arguments are provided, $TITLE looks for a file named"
	echo "\"Doxyfile\" in the current directory"
	echo ""
}

function parse
{
	local len=$#
	if [ $len -eq 0 ]; then return 0; fi

	for arg in "$@"; do
		if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
			if [ $len -eq 1 ]; then usage; exit 0
			else usage; exit 2; fi
		elif [ "$1" == "-V" ] || [ "$1" == "--version" ]; then
			if [ $len -eq 1 ]; then version; exit 0
			else version; exit 2; fi
		elif [ "$1" == "-s" ] || [ "$1" == "--sections" ]; then
			KEEP_SECTION_SEPARATORS=1
		elif [ "$1" == "-S" ] || [ "$1" == "--no-sections" ]; then
			KEEP_SECTION_SEPARATORS=0
		elif [ "$1" == "-b" ] || [ "$1" == "--backup" ]; then CREATE_BACKUP=1
		elif [ "$1" == "-B" ] || [ "$1" == "--no-backup" ]; then CREATE_BACKUP=0
		elif [[ "$1" != "-"* ]]; then file="$1"
		else usage; exit 2; fi
		shift
	done
}

## DEBUG
#function config
#{
#	echo "KEEP_SECTION_SEPARATORS = $KEEP_SECTION_SEPARATORS"
#	echo "CREATE_BACKUP           = $CREATE_BACKUP"
#	echo "file                    = $file"
#	echo "dupl                    = $dupl"
#	exit 255
#}

if [ $# -eq 1 ]; then parse $@
elif [ $# -gt 1 ] && [ $# -lt 4 ]; then parse $@
elif [ $# -ne 0 ]; then usage; exit 2; fi

checkcmd "date"
checkcmd "mv"
checkcmd "rm"

if [ ! -f "$file" ]; then
	echo "file \"$file\" not found"
	exit 3
fi

dupl="${file}.bak"

if [ -f "${file}.bak" ]; then
	stmp=$(date +%s)
	dupl="${file}.bak.${stmp}"
fi

## DEBUG
#config

mv "$file" "$dupl" &> /dev/null
if [ $? -ne 0 ]; then
	if [ $CREATE_BACKUP -eq 0 ]; then echo "opertion failed"
	else echo "failed to create backup file \"$dupl\""; fi
	exit 4
fi

echo -n "" > "$file"

last=""
IFS=
while read -r line; do
	if [ -z "$line" ]; then continue; fi
	if [ "$line" == "#" ]; then continue; fi
	if [[ "$line" == "# "* ]]; then continue; fi
	if [[ "$line" == "#-"* ]]; then
		if [ $KEEP_SECTION_SEPARATORS -gt 0 ]; then
			if [ "$line" == "$last" ]; then continue; fi
		else continue; fi
	fi

	last="$line"
	echo "$line" >> "$file"
done < "$dupl"

if [ $CREATE_BACKUP -eq 0 ]; then
	rm -f "$dupl"
fi

exit 0
