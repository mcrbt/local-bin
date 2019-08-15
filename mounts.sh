#!/bin/bash
mount | grep /dev/sd | awk '{print $1" "$2" "$3" as "$5}'
mount | grep /dev/mmc | awk '{print $1" "$2" "$3" as "$5}'
exit 0
