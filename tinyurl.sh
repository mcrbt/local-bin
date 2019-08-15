#!/bin/bash

which curl &> /dev/null
if [ $? -ne 0 ]; then echo "command \"curl\" not found on the system"; fi
which grep &> /dev/null
if [ $? -ne 0 ]; then echo "command \"curl\" not found on the system"; fi
which perl &> /dev/null
if [ $? -ne 0 ]; then echo "command \"curl\" not found on the system"; fi

if [ $# -ne 1 ]; then echo "usage: $0 <url>"; exit 1; fi
curl --silent "https://tinyurl.com/create.php?url=$1" | grep "<b>https://tinyurl.com/" | perl -pe 's/.*<b>(https:\/\/tinyurl\.com\/.*?)<\/b>.*/\1/'
exit 0
