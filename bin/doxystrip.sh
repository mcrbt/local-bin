#!/usr/bin/env bash
##
## doxystrip - strip documentation and comments from doxygen's "Doxyfile"
## Copyright (C) 2020-2023  Daniel Haase
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

# shellcheck disable=SC2155,SC2310

## DEPRECATED: initially use "doxygen -s -g Doxyfile" instead

set -o errexit
set -o nounset
set -o pipefail

TITLE="doxystrip"
VERSION="0.3.0"

DEFAULT_DOXYFILE="${DEFAULT_DOXYFILE:-"Doxyfile"}"
BACKUP_EXTENSION="${BACKUP_EXTENSION:-"bak"}"

declare -i keep_sections=0
declare -i keep_backup=1
declare -i be_verbose=0

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo >&2 "no such command \"${1}\""
		exit 1
	fi
}

function print_version {
	cat <<-EOF
		${TITLE} ${VERSION}
		copyright (c) 2020-2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${TITLE} [-s | -S] [-b | -B] [-v | -q] [<doxyfile>]
		        ${TITLE} [-V | -h]

		   <doxyfile>
		      alternative "Doxyfile" filename/location
		      (default is "./${DEFAULT_DOXYFILE}")

		   -s | --sections
		      separate distinct configuration sections with extra
		      comment line

		   -S | --no-sections
		      do not separate distinct configuration sections with
		      extra comment line (default)

		   -b | --keep-backup
		      keep backup of Doxyfile after stripping (default)

		   -B | --no-keep-backup
		      remove backup of Doxyfile after stripping

		   -v | --verbose | --statistics
		      print brief statistics of operation and strip rate

		   -q | --quiet
		      do not print any statistics (default)

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function fail_usage {
	print_usage >&2
	exit 2
}

function assert_doxyfile_exists {
	local -r file_path="${1}"

	if [[ ! -f "${file_path}" ]]; then
		echo >&2 "Doxyfile not found"
		exit 3
	fi

	return 0
}

function fail_missing_permission {
	echo >&2 "missing ${1} permission for directory \"${2}\""
	exit 3
}

function assert_required_permissions {
	local -r file="${1}"

	if [[ ! -f "${file}" ]]; then
		return 0
	fi

	local -r directory="$(realpath "$(dirname "${file}")")"

	if [[ ! -r "${directory}" ]]; then
		fail_missing_permission "read" "${directory}"
	fi

	if [[ ! -w "${directory}" ]]; then
		fail_missing_permission "write" "${directory}"
	fi

	if [[ ! -x "${directory}" ]]; then
		fail_missing_permission "execute" "${directory}"
	fi

	return 0
}

## TODO: fix
# function calculate_percentage {
# 	local -ri share=${1}
# 	local -ri total=${2}

# 	if [[ ${total} -eq 0 ]]; then
# 		echo "0.0000"
# 		return 0
# 	fi

# 	echo "scale=48; ((${share} / ${total}) * 100)" | bc
# } 2>/dev/null

function print_statistics {
	local -ri read_line_count="${1}"
	local -ri written_line_count="${2}"

	if [[ ${be_verbose} -lt 1 ]]; then
		return 0
	fi

	local -ri strip_count=$((read_line_count - written_line_count))
	# local -ri strip_percentage="$(calculate_percentage \
	#	"${strip_count}" "${read_line_count}")"

	printf "    read %4d lines\n" "${read_line_count}"
	printf "   wrote %4d lines\n\n" "${written_line_count}"
	printf "stripped %4d lines (%6.2f %%)\n" "${strip_count}" \
		"0.0000" # "${strip_percentage}"
} 2>/dev/null

function process_doxyfile {
	local -r doxygen_file="${1}"
	local -r backup_file="${2}"

	if [[ ! -f "${doxygen_file}" ]]; then
		return 1
	fi

	local -r comment_regex="#.*"

	local -ri read_line_count="$(wc --lines --total=only \
		"${backup_file}")"
	local -i written_line_count=0
	local previous_line=""
	IFS=""

	while read -r line; do
		if [[ -z "${line}" ]]; then
			continue
		elif [[ "${line}" == "#-"* &&
			${keep_sections} -lt 1 ||
			"${line}" == "${previous_line}" ]]; then
			continue
		elif [[ "${line}" =~ ${comment_regex} ]]; then
			continue
		fi

		previous_line="${line}"
		echo "${line}" >>"${doxygen_file}" || return 1
		written_line_count=$((written_line_count + 1))
	done <"${backup_file}"

	if ! print_statistics \
		"${read_line_count}" \
		"${written_line_count}"; then
		echo >&2 "failed to print statistics"
	fi

	return 0
}

function revert_operation {
	local -r doxygen_file="${1}"
	local -r backup_file="${2}"

	rm --force "${doxygen_file}"
	mv --force "${backup_file}" "${doxygen_file}"
} 2>/dev/null

check_command "cat"
check_command "date"
check_command "mv"
check_command "pwd"
check_command "rm"
check_command "touch"
check_command "wc"

declare doxygen_file="$(pwd)/${DEFAULT_DOXYFILE}"

while [[ $# -gt 0 ]]; do
	case "${1}" in
		-s | --sections)
			keep_sections=1
			;;
		-S | --no-sections)
			keep_sections=0
			;;
		-b | --keep-backup)
			keep_backup=1
			;;
		-B | --no-keep-backup)
			keep_backup=0
			;;
		-v | --verbose | --statistics)
			be_verbose=1
			;;
		-q | --quiet)
			be_verbose=0
			;;
		-V | --version)
			print_version
			exit 0
			;;
		-h | --help)
			print_usage
			exit 0
			;;
		-*)
			fail_usage
			;;
		*)
			doxygen_file="${1}"
			;;
	esac

	shift
done

if [[ -d "${doxygen_file}" ]]; then
	doxygen_file="${doxygen_file}/Doxyfile"
fi

assert_doxyfile_exists "${doxygen_file}"
assert_required_permissions "${doxygen_file}"

declare backup_file="${doxygen_file}.${BACKUP_EXTENSION}"

if [[ -f "${backup_file}" ]]; then
	if ! rm --force "${backup_file}" &>/dev/null; then
		echo >&2 "failed to removed backup file \"${backup_file}\""
		exit 3
	fi
fi

if ! mv "${doxygen_file}" "${backup_file}" &>/dev/null; then
	echo >&2 "failed to create backup file \"${backup_file}\""
	exit 3
fi

if ! touch "${doxygen_file}" &>/dev/null; then
	echo >&2 "operation failed"
	exit 4
fi

echo "DEBUG: verbose = ${be_verbose}"

if ! process_doxyfile "${doxygen_file}" "${backup_file}"; then
	echo >&2 "operation failed"

	echo "DEBUG: reverting operation..."

	if ! revert_operation "${doxygen_file}" "${backup_file}"; then
		echo >&2 "failed to revert operation"
		exit 5
	fi

	exit 4
fi

if [[ ${keep_backup} -lt 1 ]]; then
	if ! rm --force "${backup_file}" &>/dev/null; then
		echo >&2 "failed to remove backup file \"${backup_file}\""
		exit 3
	fi
fi

exit 0
