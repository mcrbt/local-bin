#!/usr/bin/env bash
##
## cfgsync - copy configuration files of root to all local user directories
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

set -o errexit
set -o nounset
set -o pipefail

TITLE="cfgsync"
VERSION="0.4.0"

declare -r ROOT_PREFIX="${ROOT_PREFIX:-"/root"}"
declare -r HOME_PREFIX="${HOME_PREFIX:-"/home"}"
declare -r -a DEFAULT_SYNCHRONIZATION_LIST=(
	".bashrc"
	".xinitrc"
)

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

		usage:  ${TITLE} [--verbose | --quiet] [<file>...]
		        ${TITLE} [--version | --help]

		   <file>...
		      file or directory name(s)

		   -v | --verbose
		      print what is being done

		   -q | --quiet
		      suppress (verbose and) summary message(s)

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function assert_root {
	if [[ ${EUID} -ne 0 ]]; then
		echo >&2 "please run this script as user \"root\""
		exit 3
	fi
}

function print_message {
	local -r message="${1}"

	if [[ -n "${message}" && ${verbose} -gt 0 ]]; then
		echo "${message}"
	fi
}

function print_skip {
	local -r file="${1}"

	if [[ -z "${file}" ]]; then
		return 0
	fi

	local type

	if [[ -f "${file}" ]]; then
		type=" file "
	elif [[ -d "${file}" ]]; then
		type=" directory "
	else
		type=""
	fi

	print_message "skipping${type}\"${file}\"..."
}

function copy_to_user {
	local -r source="${1}"
	local -r source_parent="${2}"
	local -r file="${3}"
	local -r user="${4}"

	local -r destination_parent="${user}/${source_parent}"

	if [[ ! -d "${destination_parent}" &&
		"${source_parent}" != "." &&
		"${source_parent}" != ".." ]]; then
		print_message "creating directory \"${destination_parent}\"..."

		if ! mkdir --parents "${destination_parent}" &>/dev/null; then
			echo >&2 "failed to create directory \"${destination_parent}\""
			return 1
		fi
	fi

	local -r destination="${user}/${file}"

	print_message "copying \"${source}\" to \"${destination}\"..."

	cp --recursive --update --force "${source}" "${destination}" \
		&>/dev/null || {
		echo >&2 "failed to copy \"${source}\" to \"${destination}\""
		return 1
	}

	local -i file_count=0
	local -i directory_count=0

	file_count="$(find "${source}" -type f -print | wc --lines)"
	directory_count="$(find "${source}" -type d -print | wc --lines)"
	total_file_count=$((total_file_count + file_count))
	total_directory_count=$((total_directory_count + directory_count))
}

function synchronize_file {
	local file="${1}"

	if [[ -z "${file}" ]]; then
		return 1
	fi

	if [[ "${file}" == "${ROOT_PREFIX}/"* ]]; then
		file="${file:6}"
	fi

	local -r source="${ROOT_PREFIX}/${file}"

	if [[ "${file}" == ".."* ]]; then
		echo >&2 "accessing filesystem root is prohibited"
		print_skip "${source}"
		return 1
	fi

	if [[ ! -e "${source}" ]]; then
		echo >&2 "no such file or directory \"${source}\""
		print_skip "${source}"
		return 1
	fi

	local source_parent

	source_parent="$(dirname "${source}")" || {
		echo >&2 "failed to get parent directory of path \"${source}\""
		return 1
	}

	if [[ "${source_parent}" == "${ROOT_PREFIX}" ]]; then
		source_parent="."
	fi

	for user in "${HOME_PREFIX}/"*; do
		copy_to_user "${source}" "${source_parent}" "${file}" "${user}"
	done
}

function synchronize_all {
	local -r -a files=("${@}")

	if [[ ${#files[@]} -eq 0 ]]; then
		return 0
	fi

	for file in "${files[@]}"; do
		if [[ "${file}" == "-"* ]]; then
			continue
		fi

		print_message "synchronizing \"${file}\"..."
		synchronize_file "${file}"
	done
}

check_command "cat"
check_command "cp"
check_command "dirname"
check_command "mkdir"

assert_root

declare -i verbose=0
declare -i quiet=0

declare -a synchronization_list=()
declare -i total_file_count=0
declare -i total_directory_count=0

while [[ $# -gt 0 ]]; do
	case "${1}" in
		-V | --version)
			print_version
			exit 0
			;;
		-h | --help)
			print_usage
			exit 0
			;;
		-v | --verbose)
			verbose=1
			;;
		-q | --quiet)
			quiet=1
			;;
		-*)
			print_usage
			exit 2
			;;
		*)
			synchronization_list+=("${1}")
			;;
	esac

	shift
done

if [[ "${#synchronization_list[@]}" -lt 1 ]]; then
	synchronization_list=("${DEFAULT_SYNCHRONIZATION_LIST[@]}")
fi

if [[ ${quiet} -gt 0 ]]; then
	verbose=0
fi

synchronize_all "${synchronization_list[@]}"

if [[ ${quiet} -eq 0 ]]; then
	declare message="${total_file_count} "

	if [[ ${total_file_count} -eq 1 ]]; then
		message+="file "
	else
		message+="files "
	fi

	message+="and ${total_directory_count} "

	if [[ ${total_directory_count} -eq 1 ]]; then
		message+="directory "
	else
		message+="directories "
	fi

	message+="synchronized"

	echo "${message}"
fi

exit 0
