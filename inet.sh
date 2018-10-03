#!/bin/bash

if [ $# -gt 0 ]; then PROFILE=$1
else PROFILE="68656c6c6f"; fi

which netctl &> /dev/null
if [ $? -ne 0 ]; then echo "\"netctl\" not installed."; exit 1; fi
which ping &> /dev/null
if [ $? -ne 0 ]; then echo "\"ping\" not installed."; exit 1; fi

active=$(netctl list | grep '*' | awk '{print $2}')
if [ "$active" == "$PROFILE" ]; then echo "profile already online."; exit 0
elif [ "$active" != "" ]; then netctl stop-all; fi

netctl start $PROFILE
if [ $? -ne 0 ]; then echo "failed to start netctl profile."; exit 2; fi

sleep 3

ping -c 1 ipinfo.io &> /dev/null
if [ $? -ne 0 ]; then echo "failed to ping server."; exit 3; fi

echo "internet connection established: $PROFILE"

if [ "$(echo -n $(which notify-send 2> /dev/null))" != "" ]; then
	notify-send "$PROFILE" "Internet connection established"
fi

exit 0
