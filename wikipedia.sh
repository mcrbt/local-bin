#!/bin/bash

LANG="en"
QUERY=""

which sed &> /dev/null
if [ $? -ne 0 ]; then echo "command \"sed\" not found on the system"; exit 2; fi
which tr &> /dev/null
if [ $? -ne 0 ]; then echo "command \"tr\" not found on the system"; exit 2; fi
which firefox &> /dev/null
if [ $? -ne 0 ]; then echo "command \"firefox\" not found on the system"; exit 2; fi

function prepare()
{
	NAME=$(for i in $@; do CONV=$(echo -n "${i:0:1}" | tr "[:lower:]" "[:upper:]"); echo -n "${CONV}${i:1}"; done) 
	NAME=$(echo "$NAME" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//')
	echo "$NAME"
}

if [ $# -eq 0 ]; then echo "usage: $(basename $0) <en|de> <query>"; exit 0
elif [ $# -eq 1 ]; then
	if [[ "$1" == "en" || "$1" == "de" ]]; then echo "usage: $0 <en|de> <query>"; exit 1; fi
	QUERY=$(prepare $1)
else
	if [[ "$1" == "en" || "$1" == "de" ]]; then LANG=$1; shift; fi
	QUERY=$(prepare $@)
fi

if [ "$QUERY" == "" ]; then URL="https://www.wikipedia.org/"
else URL="https://$LANG.wikipedia.org/wiki/$QUERY"; fi
firefox --new-tab $URL &> /dev/null &
exit 0
