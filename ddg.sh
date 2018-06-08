#!/bin/bash

which firefox &> /dev/null
if [ $? -ne 0 ]; then echo "command \"firefox\" not found on the system"; exit 1; fi
Q=$(echo "$@" | sed 's/ /+/g')
if [ "$Q" == "" ]; then firefox "https://start.duckduckgo.com/" &> /dev/null &
else firefox "https://start.duckduckgo.com/?q=$Q" &> /dev/null &; fi
exit 0

