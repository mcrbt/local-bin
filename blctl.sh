#!/bin/bash

function usage()
{
	echo "usage: $0 <pset | aset> <value>"
	echo "       $0 <inc | dec | min | max | std | val>"
	echo ""
	echo "  pset <value>"
	echo "    set backlight brightness to <value> percent (relative)"
	echo "    <value> may be an integer between 1 and 99"
	echo "  aset <value>"
	echo "    set backlight brightness to absolut value (absolut)"
	echo "    <value> may be an integer between 9 and 844 (1%-99%)"
	echo "  inc"
	echo "    increase backlight brightness by 10 percent"
	echo "  dec"
	echo "    decrease backlight brightness by 10 percent"
	echo "  min"
	echo "    set backlight brightness to 9 (1%)"
	echo "  max"
	echo "    set backlight brightness to 844 (99%)"
	echo "  std"
	echo "    set backlight brightness to default value (328 (38%))"
	echo "  val"
	echo "    print current value of backlight brightness"
	echo ""
	echo "exiting with return code $1"
	exit $1
}

function percent()
{
	VAL=$(echo "scale=2; (($1 / 852) * 100)" | bc)
	VAL=$(echo "scale=0; ($VAL / 1)" | bc)
	echo $VAL
}

function absolut()
{
	VAL=$(echo "scale=2; ($1 * (852 / 100))" | bc)
	VAL=$(echo "scale=0; ($VAL / 1)" | bc)
	echo $VAL
}

function set_percent()
{
	if [ $1 -lt 1 ]; then echo $(absolut 1) > /sys/class/backlight/intel_backlight/brightness
	elif [ $1 -gt 99 ]; then echo $(absolut 99) > /sys/class/backlight/intel_backlight/brightness
	else echo $(absolut $1) > /sys/class/backlight/intel_backlight/brightness; fi
}

function set_absolut()
{
	if [ $1 -lt 9 ]; then
		echo "9" > /sys/class/backlight/intel_backlight/brightness
	elif [ $1 -gt 844 ]; then
		echo "844" > /sys/class/backlight/intel_backlight/brightness
	else echo $1 > /sys/class/backlight/intel_backlight/brightness; fi
}

if [ $# -eq 2 ]; then
	if [ "$1" == "pset" ]; then set_percent $2
	elif [ "$1" == "aset" ]; then set_absolut $2
	else usage 1; fi
elif [ $# -eq 1 ]; then
	if [ "$1" == "inc" ]; then
		CUR=$(cat /sys/class/backlight/intel_backlight/brightness)
		PCT=$(percent $CUR)
		PCT=$((PCT + 10))
		set_percent $PCT
	elif [ "$1" == "dec" ]; then
		CUR=$(cat /sys/class/backlight/intel_backlight/brightness)
		PCT=$(percent $CUR)
		PCT=$((PCT - 10))
		set_percent $PCT
	elif [ "$1" == "min" ]; then set_absolut 9
	elif [ "$1" == "max" ]; then set_absolut 844
	elif [ "$1" == "std" ]; then set_absolut 328
	elif [ "$1" == "val" ]; then
		CUR=$(cat /sys/class/backlight/intel_backlight/brightness)
		PCT=$(percent $CUR)
		echo "$CUR (${PCT}%)"
	else usage 1; fi
elif [ $# -eq 0 ]; then usage 0; else usage 1; fi
exit 0
