#!/usr/bin/env bash
##
## torcircuit - open new Tor circuit by restarting services
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
## along with this program. If not, see
## <http://www.gnu.org/licenses/gpl.txt>.
##

set -o errexit
set -o nounset
set -o pipefail
set -o noclobber

TITLE="torcircuit"
VERSION="0.4.0"

SOCKS_PROXY="${SOCKS_PROXY:-"localhost:9050"}"
IP_LOOKUP_URL="${IP_LOOKUP_URL:-"https://api.ipify.org"}"

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

		usage:  ${TITLE} [--version | --help]

		   -V | --version
		      print version information and exit

		   -h | --help
		      print this usage description and exit

	EOF
}

function has_network_connection {
	[[ -n "$(ip route)" ]]
} &>/dev/null

function has_tor_instance {
	pgrep '^tor$'
} &>/dev/null

function is_tor_running {
	[[ "$(systemctl status tor |
		awk '/Active/ { print $2" "$3 }')" == "active (running)" ]]
} &>/dev/null

function is_circuit_established {
	systemctl status tor |
		grep --max-count=1 --fixed-strings --quiet \
			"Bootstrapped 100% (done): Done"
} &>/dev/null

function get_tor_address {
	local proxy_url

	if [[ "${SOCKS_PROXY}" != "socks5://"* ]]; then
		proxy_url="socks5://${SOCKS_PROXY}"
	else
		proxy_url="${SOCKS_PROXY}"
	fi

	curl --proxy "${proxy_url}" --connect-timeout 5 --silent \
		"${IP_LOOKUP_URL}"
} 2>/dev/null

function restart_tor_service {
	systemctl restart tor &>/dev/null || {
		echo >&2 "failed to open new tor circuit"
		exit 3
	}

	sleep 5
}

check_command "awk"
check_command "cat"
check_command "curl"
check_command "grep"
check_command "ip"
check_command "pgrep"
check_command "systemctl"
check_command "tor"

if [[ $# -eq 1 ]]; then
	case "${1}" in
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
elif [[ $# -gt 1 ]]; then
	print_usage
	exit 2
fi

if ! has_network_connection; then
	echo >&2 "no network connection detected"
	exit 3
fi

if ! has_tor_instance; then
	echo >&2 "no running tor daemon detected"
	#exit 3
fi

if ! is_tor_running; then
	echo >&2 "tor service not running"
	#exit 3
fi

declare old_address
declare new_address
declare -i exit_code

if is_circuit_established; then
	old_address="$(get_tor_address)" || {
		echo >&2 "failed to get old tor exit relay ip address"
	}
else
	echo >&2 "no previous tor circuit established"
	old_address="none"
fi

restart_tor_service

if is_circuit_established; then
	exit_code=0
	new_address="$(get_tor_address)" || {
		echo >&2 "failed to get new tor exit relay ip address"
		new_address="none"
		exit_code=4
	}
else
	echo >&2 "failed to establish new tor circuit in time"
	new_address="none"
	exit_code=5
fi

cat <<-EOF

	tor exit relay ip address:

	   old: ${old_address}
	   new: ${new_address}

EOF

exit "${exit_code}"
