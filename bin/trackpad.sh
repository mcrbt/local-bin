#!/usr/bin/env bash
##
## trackpad - quickly enable/disable trackpad
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

# shellcheck disable=SC2310

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

NAME="trackpad"
VERSION="0.3.1"

TRACKPAD_PATTERN="${TRACKPAD_PATTERN:-"Synaptics"}"
TRACKPOINT_PATTERN="${TRACKPOINT_PATTERN:-"TrackPoint"}"

function check_command {
	if ! command -v "${1}" &>/dev/null; then
		echo >&2 "no such command \"${1}\""
		exit 1
	fi
}

function print_version {
	cat <<-EOF
		${NAME} ${VERSION}
		copyright (c) 2020-2023 Daniel Haase
	EOF
}

function print_usage {
	print_version
	cat <<-EOF

		usage:  ${NAME} [on | off | status]
		        ${NAME} [--version | --help]

		   on
		      enable trackpad (and trackpoint) input device(s)

		   off
		      disable trackpad (and trackpoint) input device(s)

		   status
		      print status of trackpad, trackpoint, and optical mouse

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function get_input_device {
	local -r pattern="${1}"

	if [[ -z "${pattern}" ]]; then
		return 1
	fi

	xinput list --name-only |
		grep --max-count=1 --fixed-strings --ignore-case "${pattern}"
} 2>/dev/null

function get_input_device_status {
	local -r input_device="$(get_input_device "${1}")"

	if [[ -z "${input_device}" ]]; then
		return 0
	fi

	local -r pattern="This device is disabled"
	local -r status="$(xinput list "${input_device}" |
		grep --max-count=1 --fixed-strings "${pattern}")"

	if [[ -n "${status}" ]]; then
		echo "disabled"
	else
		echo "enabled"
	fi
} 2>/dev/null

function set_input_device {
	local -r input_device="${1}"
	local -r operation="${2}"

	if [[ -z "${input_device}" ]]; then
		return 0
	fi

	if [[ "${operation}" != "enable" &&
		"${operation}" != "disable" ]]; then
		return 1
	fi

	if ! xinput "${operation}" "${input_device}" 2>/dev/null; then
		echo >&2 "failed to ${operation} input device \"${input_device}\""
		exit 3
	fi
}

function has_mouse {
	[[ -n "$(get_input_device "Mouse")" ]]
}

function disable_input_device {
	set_input_device "${1}" disable
}

function enable_input_device {
	set_input_device "${1}" enable
}

function disable_native_input_devices {
	local -r trackpad="$(get_input_device "${TRACKPAD_PATTERN}")"
	local -r trackpoint="$(get_input_device "${TRACKPOINT_PATTERN}")"

	disable_input_device "${trackpad}"
	disable_input_device "${trackpoint}"
}

function enable_native_input_devices {
	local -r trackpad="$(get_input_device "${TRACKPAD_PATTERN}")"
	local -r trackpoint="$(get_input_device "${TRACKPOINT_PATTERN}")"

	enable_input_device "${trackpad}"
	enable_input_device "${trackpoint}"
}

function print_formatted_status {
	printf "  %-10s    %-11s\n" "${1}" "${2}"
}

function print_native_input_device_status {
	local -r trackpad="$(get_input_device "${TRACKPAD_PATTERN}")"
	local -r trackpoint="$(get_input_device "${TRACKPOINT_PATTERN}")"
	local status

	if [[ -n "${trackpad}" ]]; then
		status="$(get_input_device_status "${trackpad}")"

		print_formatted_status "trackpad" "${status}"
	fi

	if [[ -n "${trackpoint}" ]]; then
		status="$(get_input_device_status "${trackpoint}")"

		print_formatted_status "trackpoint" "${status}"
	fi
}

function print_mouse_availability {
	local status

	if has_mouse; then
		status="available"
	else
		status="unavailable"
	fi

	print_formatted_status "mouse" "${status}"
}

check_command "awk"
check_command "cat"
check_command "grep"
check_command "printf"
check_command "xinput"

if [[ $# -eq 0 ]]; then
	if has_mouse; then
		disable_native_input_devices
	else
		enable_native_input_devices
	fi
elif [[ $# -eq 1 ]]; then
	case "${1}" in
		on)
			enable_native_input_devices
			;;
		off)
			disable_native_input_devices
			;;
		status)
			print_native_input_device_status
			print_mouse_availability
			;;
		-V | --version)
			print_version
			exit 0
			;;
		-h | --help)
			print_usage
			exit 0
			;;
		*)
			print_usage
			exit 2
			;;
	esac
else
	print_usage
	exit 2
fi

exit 0
