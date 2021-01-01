#!/bin/bash
##
## pdfalign - align all pages of a PDF file to DIN A4 using "pdfjam"
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
## along with this program.
## If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>.
##

SCRIPT="pdfalign"
VERSION="0.4.2"

META=1
PDFTITLE=""
PDFAUTHOR=""
BACKUP=0

## exit with code 1 if command "$1" is not found
function checkcmd
{
	if [ $# -eq 0 ] || [ -z "$1" ] \
	|| command -v "$1" &> /dev/null; then return 0
	else echo "command \"$1\" not found"; exit 1; fi
}

## print version and copyright notice
function version
{
	echo "${SCRIPT} version ${VERSION}"
	echo "copyright (c) 2020 Daniel Haase"
}

## print usage information
function usage
{
	version
	echo ""
	echo "usage:  ${SCRIPT} [-t <title>] [-a <author>] [-M] [-k | -K] <filename>"
	echo "        ${SCRIPT} [-M] <filename>"
	echo "        ${SCRIPT} [-V | -h]"
	echo ""
	echo "  <filename>"
	echo "    the name of the PDF file to align to DIN A4"
	echo ""
	echo "  -t <title> | --title <title>"
	echo "    write PDF title <title> to document meta data"
	echo ""
	echo "  -a <author> | --author <author>"
	echo "    write PDF author <author> to document meta data"
	echo ""
	echo "  -M | --no-meta"
	echo "    do not write any meta data to PDF document"
	echo ""
	echo "  -k | --keep-backup"
	echo "    do not remove backup file after operation"
	echo ""
	echo "  -K | --remove-backup"
	echo "    remove backup file after operation"
	echo ""
	echo "  -V | --version"
	echo "    print version and copyright notice and exit"
	echo ""
	echo "  -h | --help"
	echo "    print this usage information and exit"
	echo ""
}

## test if input file "$1" is a PDF file
function ispdf
{
	local f="$1"
	if [ $# -eq 0 ] || [ -z "${f}" ]; then return 1; fi
	if [ ! -f "${f}" ]; then return 1; fi ## failure

	local ext="${f#*.}"
	ext=$(echo "${ext}" | tr "[:upper:]" "[:lower:]")
	if [ "$(file "${f}" | awk '{print $2}')" == "PDF" ] \
	&& [ "${f#*.}" == "pdf" ]; then return 0 ## success
	else return 1; fi ## failure
}

## check dependencies
checkcmd "awk"
checkcmd "cp"
checkcmd "file"
checkcmd "grep"
checkcmd "mv"
checkcmd "pdfjam"
checkcmd "pdflatex" ## required by pdfjam
checkcmd "rm"
checkcmd "sed"
checkcmd "tr"

if [ $# -eq 0 ]; then usage; exit 0; fi

is_title=0
is_author=0

## parse command line arguments
for arg in "$@"; do
	if [ $is_title -gt 0 ]; then
		if [[ "${arg}" == "-"* ]]; then usage; exit 2
		else PDFTITLE="${arg}"; is_title=0; fi
	elif [ $is_author -gt 0 ]; then
		if [[ "${arg}" == "-"* ]]; then usage; exit 2
		else PDFAUTHOR="${arg}"; is_author=0; fi
	else
		if [ "${arg}" == "-V" ] || [ "${arg}" == "--version" ]
		then version; exit 0
		elif [ "${arg}" == "-h" ] || [ "${arg}" == "--help" ]
		then usage; exit 0
		elif [ "${arg}" == "-t" ] || [ "${arg}" == "--title" ]
		then is_title=1
		elif [ "${arg}" == "-a" ] || [ "${arg}" == "--author" ]
		then is_author=1
		elif [ "${arg}" == "-M" ] || [ "${arg}" == "--no-meta" ]
		then META=0
		elif [ "${arg}" == "-k" ] || [ "${arg}" == "--keep-backup" ]
		then BACKUP=1
		elif [ "${arg}" == "-K" ] || [ "${arg}" == "--remove-backup" ]
		then BACKUP=0
		elif [[ "${arg}" == "-"* ]]; then usage; exit 2
		else FILE="${arg}"; fi
	fi
done

## test if input file is present
if [ -z "${FILE}" ] || [ ! -f "${FILE}" ]; then
	echo "input file \"${FILE}\" does not exist"
	exit 3
fi

## validate input file
if ! ispdf "${FILE}"; then
	echo "input file \"${FILE}\" is not a PDF file"
	exit 3
fi

## create backup of input file
BACK="${FILE}.bak"
INPUT="${FILE%%.*}_old.${FILE#*.}"
cp -u "${FILE}" "${BACK}" &> /dev/null
mv "${FILE}" "${INPUT}" &> /dev/null

## get PDF title and author
if [ $META -eq 0 ]; then PDFTITLE=""; PDFAUTHOR=""
else
	## get title if not already set
	if [ -z "${PDFTITLE}" ]; then
		PDFTITLE=$(echo "${FILE%%.*}" | sed 's/[^ ._-]*/\u&/g' | tr "._-" " ")
	fi

	## get author if not already set
	if [ -z "${PDFAUTHOR}" ] && [ "${USER}" != "root" ] && [ $EUID -ne 0 ]; then
		PDFAUTHOR=$(echo "${USER}" | sed 's/[^ ._-]*/\u&/g' | tr "._-" " ")
	fi
fi

## perform operation
MESSAGE=$({ pdfjam --outfile "${FILE}" --papersize '{210mm,297mm}' \
--no-landscape --pdftitle "${PDFTITLE}" --pdfauthor "${PDFAUTHOR}" \
-- "${INPUT}"; } 2>&1)
## grep pdfjam exit code
CODE=$?

## print message and exit on error
if [ $CODE -ne 0 ] && [ -n "${MESSAGE}" ]; then
	ERROR=$(echo "${MESSAGE}" | grep 'pdfjam ERROR' | sed 's/\s*pdfjam ERROR:\s*//')

	if [ -n "${ERROR}" ]; then
		echo "failed to align PDF file \"${FILE}\": ${ERROR}"

		## roll-back changes
		if [ -f "${BACK}" ]; then
			if [ -f "${FILE}" ] || [ -f "${INPUT}" ]
			then rm -f "${FILE}" "${INPUT}" &> /dev/null; fi

			if [ $BACKUP -eq 0 ]; then
				mv "${BACK}" "${FILE}" &> /dev/null
			else
				cp -u "${BACK}" "${FILE}" &> /dev/null
				mv "${BACK}" "${INPUT}" &> /dev/null
			fi
		elif [ -f "${INPUT}" ]; then
			if [ -f "${FILE}" ]; then rm -f "${INPUT}" &> /dev/null; fi
			mv "${INPUT}" "${FILE}" &> /dev/null
		fi

		## exit with code >= 4
		if [ $CODE -le 4 ]; then exit 4
		else exit $CODE; fi
	else
		echo "failed to align PDF file \"${FILE}\""
		exit 4
	fi
fi

if [ $BACKUP -eq 0 ]; then rm -f "${BACK}" "${INPUT}" &> /dev/null
else
	if [ -f "${BACK}" ]; then
		if [ -f "${INPUT}" ]; then rm -f "${INPUT}" &> /dev/null; fi
		mv "${BACK}" "${INPUT}" &> /dev/null
	fi
fi

## exit successfully
exit 0
