#!/bin/bash

reverse=0
which host &> /dev/null
if [ $? -ne 0 ]; then echo "command \"host\" not found on the system"; exit 1; fi
if [ $# -eq 0 ]; then echo "usage: $(basename $0) [-r] <host>"; exit 0; fi
if [[ $# -gt 1 && $1 == "-r" ]]; then reverse=1; shift; fi

if [ $reverse -eq 0 ]; then
	for h in $@; do
		res=$(host $h | head -n 1 -q | awk '{print $4}')
		if [ "$res" == "alias" ]; then
			h2=$(host $h | head -n 1 -q | awk '{print $6}' | sed 's/\(.+\)\.$/\1/')
			res=$(host $h2 | head -n 1 -q | awk '{print $4}')
		fi
		echo "$res"
	done
else for h in $@; do host $h | head -n 1 -q | awk '{print $5}' | perl -pe 's/(.+)\.$/\1/'; done; fi
exit 0
