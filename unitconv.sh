#!/bin/bash
which units &> /dev/null
if [ $? -ne 0 ]; then echo "command \"units\" not installed on the system"; exit 2; fi
if [ $# -ne 3 ]; then echo "usage: $(basename $0) <value> <from-unit> <to-unit>"; exit 1; fi
units --compact --one-line "$1 $2" $3
exit 0
