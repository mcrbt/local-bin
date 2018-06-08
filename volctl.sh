#!/bin/bash

VOLM=75			# raw volume
VOLS=84			# raw volume
VOLH=70			# raw volume
VOLP=93			# percentage
CTRL="'Speaker',0"	# "'Speaker',0", "'Headphone',0", "All"
MODE=1			# 1 - toggle (on/off), 2 - change (inc/dec)

which amixer &> /dev/null
if [ $? -ne 0 ]; then echo "command \"amixer\" not found"; exit 2; fi

function print_usage()
{
	echo "usage: $(basename $0) [speaker | headphone | all] <on | off>"
	echo "       $(basename $0) <inc | dec | stat>"
	echo "       $(basename $0) [-h | --help]"
	exit $1
}

function vol_update()
{
	VOLM=$(amixer -Rn sget 'Master',0 | awk '/Mono:/ {print $3}')
	#VOLS=$(amixer -Rn sget 'Speaker',0 | awk '/Front Left:/ {print $4}')
	#VOLH=$(amixer -Rn sget 'Headphone',0 | awk '/Front Left:/ {print $4}')
	#VOLP=$(amixer -Rn sget 'PCM',0 | awk '/Front Left:/ {print $5}' | perl -pe 's/\[(\d{1,3})%\]/\1/')
}

function vol_on()
{
	if [ $MODE -eq 1 ]; then
		if [ "$CTRL" == "All" ]; then
			amixer -Rnq sset 'Master',0 $VOLM unmute
			amixer -Rnq sset 'Speaker',0 $VOLS unmute
			amixer -Rnq sset 'Headphone',0 $VOLH unmute
			amixer -Rnq sset 'Headphone',1 $VOLH unmute
			amixer -Rnq sset 'PCM',0 "${VOLP}%"
		else
			amixer -Rnq sset 'Master',0 $VOLM unmute
			if [ "$CTRL" == "'Speaker',0" ]; then amixer -Rnq sset $CTRL $VOLS unmute
			elif [ "$CTRL" == "'Headphone',0" ]; then
				amixer -Rnq sset $CTRL $VOLH unmute
				amixer -Rnq sset "'Headphone',1" $VOLH unmute
			fi
			amixer -Rnq sset 'PCM',0 "${VOLP}%"
		fi
	elif [ $MODE -eq 2 ]; then amixer -Rnq sset 'Master',0 $VOLM unmute; fi
}

function vol_off()
{
	#if [ "$CTRL" == "All" ]; then
		amixer -Rnq sset 'Master',0 0% mute
		amixer -Rnq sset 'Speaker',0 0% mute
		amixer -Rnq sset 'Headphone',0 0% mute
		amixer -Rnq sset 'Headphone',1 0% mute
		amixer -Rnq sset 'PCM',0 0%
	#else
	#	amixer -Rnq sset 'Master',0 0% mute
	#	amixer -Rnq sset $CTRL 0% mute
	#	amixer -Rnq sset 'PCM',0 0%
	#fi
}

function vol_inc()
{
	vol_update
	VOLM=$((VOLM + 5))
	#if [ "$CTRL" == "'Speaker',0" ]; then VOLS=$((VOLS + 2))
	#elif [ "$CTRL" == "'Headphone',0" ]; then VOLH=$((VOLH + 5))
	#else VOLS=$((VOLS + 2)); VOLH=$((VOLH + 5)); fi
	vol_on
}

function vol_dec()
{
	vol_update
	VOLM=$((VOLM - 5))
	#if [ "$CTRL" == "'Speaker',0" ]; then VOLS=$((VOLS - 2))
	#elif [ "$CTRL" == "'Headphone',0" ]; then VOLH=$((VOLH - 5))
	#else VOLS=$((VOLS - 2)); VOLH=$((VOLH - 5)); fi
	vol_on
}

function vol_stat_master()
{
	AMXRMN=$(amixer -Rn sget 'Master',0 | awk '/Mono:/ {print $3" "$4" "$5" "$6}')
	BOUNDS=$(amixer -Rn sget 'Master',0 | awk '/Limits:/ {print "["$3"-"$5"]"}')
	VOLRAW=$(echo $AMXRMN | awk '{print $1}')
	PERCNT=$(echo $AMXRMN | awk '{print $2}' | perl -pe 's/\[(\d{1,3}%)\]/\(\1\)/')
	VOLDZB=$(echo $AMXRMN | awk '{print $3}' | perl -pe 's/\[(.*?dB)]/\1/')
	STMUTE=$(echo $AMXRMN | awk '{print $4}')
	if [ $VOLRAW -lt 10 ]; then VOLRAW="  $VOLRAW"
	elif [ $VOLRAW -lt 100 ]; then VOLRAW=" $VOLRAW"; fi
	if [ ${#PERCNT} -lt 5 ]; then PERCNT="  $PERCNT"
	elif [ ${#PERCNT} -lt 6 ]; then PERCNT=" $PERCNT"; fi
	if [ ${#VOLDZB} -lt 7 ]; then VOLDZB="   $VOLDZB"
	elif [ ${#VOLDZB} -lt 8 ]; then VOLDZB="  $VOLDZB"
	elif [ ${#VOLDZB} -lt 9 ]; then VOLDZB=" $VOLDZB"; fi
	echo "Master:     $VOLRAW  $BOUNDS $PERCNT $VOLDZB  $STMUTE"
}

function vol_stat_control()
{
	AMXRLR=$(amixer -Rn sget $1 | awk '/Front Left:/ {print $4" "$5" "$6" "$7}')
	BOUNDS=$(amixer -Rn sget $1 | awk '/Limits:/ {print "["$3"-"$5"]"}')
	VOLRAW=$(echo $AMXRLR | awk '{print $1}')
	PERCNT=$(echo $AMXRLR | awk '{print $2}' | perl -pe 's/\[(\d{1,3}%)\]/\(\1\)/')
	VOLDZB=$(echo $AMXRLR | awk '{print $3}' | perl -pe 's/\[(.*?dB)]/\1/')
	STMUTE=$(echo $AMXRLR | awk '{print $4}')
	HEADPHONE1_MUTE=$(amixer -Rn sget 'Headphone',1 | awk '/Front Left:/ {print $4}')
	CONTROL=$(echo $1 | perl -pe 's/.(\w+).+/\1/')
	if [ $VOLRAW -lt 10 ]; then VOLRAW="  $VOLRAW"
	elif [ $VOLRAW -lt 100 ]; then VOLRAW=" $VOLRAW"; fi
	if [ ${#PERCNT} -lt 5 ]; then PERCNT="  $PERCNT"
	elif [ ${#PERCNT} -lt 6 ]; then PERCNT=" $PERCNT"; fi
	if [ ${#VOLDZB} -lt 7 ]; then VOLDZB="   $VOLDZB"
	elif [ ${#VOLDZB} -lt 8 ]; then VOLDZB="  $VOLDZB"
	elif [ ${#VOLDZB} -lt 9 ]; then VOLDZB=" $VOLDZB"; fi
	if [ "$CONTROL" == "Speaker" ]; then echo "$CONTROL:    $VOLRAW  $BOUNDS $PERCNT $VOLDZB  $STMUTE"
	elif [ "$CONTROL" == "Headphone" ]; then echo "$CONTROL:  $VOLRAW  $BOUNDS $PERCNT $VOLDZB  $HEADPHONE1_MUTE"
	elif [ "$CONTROL" == "PCM" ]; then echo "$CONTROL:        $VOLRAW $BOUNDS $PERCNT $VOLDZB"; fi
}

function print_stats()
{
	CTLS="'Speaker',0"; CTLH="'Headphone',0"; CTLP="'PCM',0"
	echo "$(vol_stat_master)"
	echo "$(vol_stat_control $CTLS)"
	echo "$(vol_stat_control $CTLH)"
	echo "$(vol_stat_control $CTLP)"
}

if [ $# -eq 0 ]; then print_usage 0
elif [ $# -gt 2 ]; then print_usage 1
else
	if [ $# -eq 2 ]; then
		CMD=$2
		case $1 in
			speaker) CTRL="'Speaker',0" ;;
			headphone) CTRL="'Headphone',0" ;;
			all) CTRL="All" ;;
			*) print_usage 1 ;;
		esac
	elif [ $# -eq 1 ]; then CMD=$1; fi

	case $CMD in
		on)  MODE=1; vol_on ;;
		off) MODE=1; vol_off ;;
		inc) MODE=2; vol_inc ;;
		dec) MODE=2; vol_dec ;;
		stat) echo "$(print_stats)" ;;
		-h|--help) print_usage 0 ;;
		*)   print_usage 1 ;;
	esac
fi

exit 0
