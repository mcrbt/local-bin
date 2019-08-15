#!/bin/bash

SCREEN_DIR="/home/user/pic/screen"
today=$(date +%y%m%d)
file=$(ls -t $SCREEN_DIR | head -n 1)

if [ "$file" == "" ]; then
	echo "no screenshots found"
elif [[ $file == *$today*'.png' ]]; then
	echo -n "delete $SCREEN_DIR/$file? (Y/n) "
	read resp

	if [ "$resp" == "n" ] || [ "$resp" == "N" ] ||
	   [ "$resp" == "no" ] || [ "$resp" == "NO" ]; then exit 0
	else rm -f "$SCREEN_DIR/$file"; fi
else
	if [ $# -eq 1 ] && [ "$1" == "-f" ]; then
		echo -n "delete $SCREEN_DIR/$file? (y/N) "
		read resp

		if [ "$resp" == "y" ] || [ "$resp" == "Y" ] ||
		   [ "$resp" == "yes" ] || [ "$resp" == "YES" ]; then
			rm -f "$SCREEN_DIR/$file"
		fi
	else echo "the latest screenshot is older than from today"; fi
fi

exit 0
