#!/bin/bash
##
## pacpurge - remove orphaned packages and cached files from "pacman"
## Copyright (C) 2020 Daniel Haase
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/gpl.txt>.
##

function checkcmd
{
	local c="$1"
	if [ $# -eq 0 ] || [ -z "$c" ]; then return 0; fi
	which "$c" &> /dev/null
	if [ $? -ne 0 ]; then echo "command \"$c\" not found"; exit 1; fi
	return 0
}

function compute_orphan_size
{
	SUM_KB=$1
	shift
	PLAIN_KB=$(
	perl - $@ <<'EOF'
		my $rslt = 0.0;
		my $size;
		my $unit;

		while($size = shift)
		{
			$unit = shift;

			if($unit eq "B") { $size = ($size / 1024); $rslt += $size; }
			elsif($unit eq "KiB") { $rslt += $size; }
			elsif($unit eq "MiB") { $size = ($size * 1024); $rslt += $size; }
			elsif($unit eq "GiB") { $size = ($size * 1048576); $rslt += $size; }
			elsif($unit eq "TiB") { $size = ($size * 1073741824); $rslt += $size; }
			elsif($unit eq "PiB") { $size = ($size * 1099511627776); $rslt += $size; }
			# extend for file systems with sizes >= 1024 PiB
			# TODO: add "else" for unexpected value (error case)
		}

		print "$rslt";
EOF
	)

	PKB_INT=$(echo $PLAIN_KB | perl -pe 's/(\d+)\.\d+/\1/')
	SUM_KB=$((SUM_KB + PKB_INT))
	echo "$SUM_KB $PLAIN_KB"
}

function format_result
{
	echo "$(
	perl - $1 <<'EOF'
		my $size = shift;
		my $res = "0.00 KiB";

		if($size < 0) { $size *= -1; }
		if($size < 1024) { $res = sprintf "%.2f KiB", $size; }
		elsif($size < 1048576) { $res = sprintf "%.2f MiB", ($size / 1024); }
		elsif($size < 1073741824) { $res = sprintf "%.2f GiB", ($size / 1048576); }
		elsif($size < 1099511627776) { $res = sprintf "%.2f TiB", ($size / 1073741824); }
		else { $res = sprintf "%.2f PiB", ($size / 1099511627776); }

		print "$res";
EOF
	)"
}

function deorphan
{
	SUM_KB=$1
	shift
	ORPH=$(pacman -Qdtq 2> /dev/null)
	NUM=$(echo $ORPH | wc -l)
	if [ "$ORPH" == "" ]; then echo "$SUM_KB 0 0" # echo "no orphans found"
	else
		SIZES=$(pacman -Qi $(echo $ORPH) | awk '/Installed Size/ {print $4" "$5}' | tr '\n' ' ')
		RES="$(compute_orphan_size $SUM_KB $SIZES)"
		SUM_KB="$(echo $RES | awk '{print $1}')"
		ORPH_SIZE="$(echo $RES | awk '{print $2}')"
		pacman -Rns --noconfirm $(echo $ORPH) &> /dev/null
		if [ $? -ne 0 ]; then # echo "failed to remove orphans"; return; fi
			echo "$SUM_KB -1 -1"
			return
		fi

		# if [ $NUM -eq 1 ]; then echo "$NUM orphan removed ($(format_result $ORPH_SIZE))"
		# else echo "$NUM orphans removed ($(format_result $ORPH_SIZE))"; fi
		echo "$SUM_KB $NUM $ORPH_SIZE"
	fi
}

function clean
{
	SUM_KB=$1
	shift
	RES_C="0.00 KiB"

	SZ_CACHE_1=$(du /var/cache/pacman/pkg | awk '{print $1}')
	SZ_LOCAL_1=$(du -s /var/lib/pacman/local | awk '{print $1}')
	NO_CACHE_1=$(ls -l /var/cache/pacman/pkg | wc -l)
	NO_LOCAL_1=$(ls -l /var/lib/pacman/local | wc -l)

	pacman -Sc --noconfirm &> /dev/null
	if [ $? -ne 0 ]; then # echo "purge failed"; exit 2; fi
		echo "$SUM_KB -1 -1"
	fi

	SZ_CACHE_2=$(du /var/cache/pacman/pkg | awk '{print $1}')
	SZ_LOCAL_2=$(du -s /var/lib/pacman/local | awk '{print $1}')
	NO_CACHE_2=$(ls -l /var/cache/pacman/pkg | wc -l)
	NO_LOCAL_2=$(ls -l /var/lib/pacman/local | wc -l)

	DIFF_SZ_CACHE=$((SZ_CACHE_1 - SZ_CACHE_2))
	DIFF_SZ_LOCAL=$((SZ_LOCAL_1 - SZ_LOCAL_2))
	DIFF_SZ_ALL=$((DIFF_SZ_CACHE + DIFF_SZ_LOCAL))

	DIFF_NO_CACHE=$((NO_CACHE_1 - NO_CACHE_2))
	DIFF_NO_LOCAL=$((NO_LOCAL_1 - NO_LOCAL_2))
	DIFF_NO_ALL=$(((DIFF_NO_LOCAL * 3) + DIFF_NO_CACHE))

	# RES_C=$(format_result $DIFF_SZ_ALL)
	SUM_KB=$((SUM_KB + DIFF_SZ_ALL))

	# if [ $DIFF_NO_ALL -eq 1 ]; then echo "cleaned $DIFF_NO_ALL file ($RES_C)"
	# else echo "cleaned $DIFF_NO_ALL files ($RES_C)"; fi

	echo "$SUM_KB $DIFF_NO_ALL $DIFF_SZ_ALL"
}

function purge
{
	SUM_KB=0

	DEORPH_RES=$(deorphan $SUM_KB)
	SUM_KB="$(echo $DEORPH_RES | awk '{print $1}')"
	ORPH_NUM="$(echo $DEORPH_RES | awk '{print $2}')"
	ORPH_SIZE="$(echo $DEORPH_RES | awk '{print $3}')"

	CLEAN_RES=$(clean $SUM_KB)
	SUM_KB="$(echo $CLEAN_RES | awk '{print $1}')"
	DIFF_NO_ALL="$(echo $CLEAN_RES | awk '{print $2}')"
	DIFF_SZ_ALL="$(echo $CLEAN_RES | awk '{print $3}')"

	if [ $ORPH_NUM -eq -1 ]; then echo "failed to remove orphans"
	elif [ $ORPH_NUM -eq 0 ]; then echo "no orphans found"
	elif [ $ORPH_NUM -eq 1 ]; then echo "$ORPH_NUM orphan removed ($(format_result $ORPH_SIZE))"
	else echo "ORPH_NUM orphans removed"; fi

	if [ $DIFF_NO_ALL -eq -1 ]; then echo "failed to clean files"
	elif [ $DIFF_NO_ALL -eq 1 ]; then echo "cleaned $DIFF_NO_ALL file ($(format_result $DIFF_SZ_ALL))"
	else echo "cleaned $DIFF_NO_ALL files ($(format_result $DIFF_SZ_ALL))"; fi

	echo "purged $(format_result $SUM_KB) in total"
}

checkcmd "awk"
checkcmd "du"
checkcmd "ls"
checkcmd "pacman"
checkcmd "perl"
checkcmd "tr"
checkcmd "wc"

purge
exit 0
