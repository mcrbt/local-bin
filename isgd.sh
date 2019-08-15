#!/bin/bash

which curl &> /dev/null
if [ $? -ne 0 ]; then echo "command \"curl\" not found on the system"; exit 2; fi
which grep &> /dev/null
if [ $? -ne 0 ]; then echo "command \"grep\" not found on the system"; exit 2; fi
which perl &> /dev/null
if [ $? -ne 0 ]; then echo "command \"perl\" not found on the system"; exit 2; fi
which ps &> /dev/null
if [ $? -ne 0 ]; then echo "command \"ps\" not found on the system"; exit 2; fi

if [ $# -ne 1 ]; then echo "usage: $(basename $0) <url>"; exit 1; fi

if [ "$(ps -e | grep tor)" == "" ]; then
	curl --silent "https://is.gd/create.php?url=$1" | grep "short_url" | perl -pe 's/.*value="(https:\/\/is\.gd\/.*?)".*/\1/'
else
	curl --silent --socks5 127.0.0.1:9050 "https://is.gd/create.php?url=$1" | grep "short_url" | perl -pe 's/.*value="(https:\/\/is\.gd\/.*?)".*/\1/'
fi
exit 0
