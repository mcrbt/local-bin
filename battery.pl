#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode(STDOUT, ":utf8");

my $bat0 = "/sys/class/power_supply/BAT0/uevent";
my $bat1 = "/sys/class/power_supply/BAT1/uevent";
my @bat0_stat;
my @bat1_stat;

sub trim
{
	my $str = shift;
	$str =~ s/^\s+|\s+$//g;
	return $str;
}

if(-e $bat0)
{
	open BAT0, "<$bat0" or do { print "battery \"BAT0\" not found\n"; exit 1; };

	while(<BAT0>)
	{
		my @fields = split "=", $_;

		if($fields[0] eq "POWER_SUPPLY_NAME") { $bat0_stat[0] = trim($fields[1]); }
		elsif($fields[0] eq "POWER_SUPPLY_ENERGY_FULL_DESIGN") { $bat0_stat[1] = trim($fields[1]); }
		elsif($fields[0] eq "POWER_SUPPLY_ENERGY_FULL") { $bat0_stat[2] = trim($fields[1]); }
		elsif($fields[0] eq "POWER_SUPPLY_ENERGY_NOW") { $bat0_stat[3] = trim($fields[1]); }
		elsif($fields[0] eq "POWER_SUPPLY_STATUS") { $bat0_stat[4] = lc(trim($fields[1])); }
	}

	close BAT0;

	my $bat0_val = ($bat0_stat[3] / $bat0_stat[1]) * 100;
	printf "%s:    %s%.2f%% [%s]\n", $bat0_stat[0], ($bat0_val < 10 ? " " : ""), $bat0_val, $bat0_stat[4];
}

if(-e $bat1)
{
	open BAT1, "<$bat1" or do { print "battery \"BAT1\" not found\n"; exit 1; };

	while(<BAT1>)
	{
		my @fields = split "=", $_;

		if($fields[0] eq "POWER_SUPPLY_NAME") { $bat1_stat[0] = trim($fields[1]); }
        elsif($fields[0] eq "POWER_SUPPLY_ENERGY_FULL_DESIGN") { $bat1_stat[1] = trim($fields[1]); }
        elsif($fields[0] eq "POWER_SUPPLY_ENERGY_FULL") { $bat1_stat[2] = trim($fields[1]); }
        elsif($fields[0] eq "POWER_SUPPLY_ENERGY_NOW") { $bat1_stat[3] = trim($fields[1]); }
        elsif($fields[0] eq "POWER_SUPPLY_STATUS") { $bat1_stat[4] = lc(trim($fields[1])); }
	}

	close BAT1;

	my $bat1_val = ($bat1_stat[3] / $bat1_stat[1]) * 100;
	printf "%s:    %s%.2f%% [%s]\n", $bat1_stat[0], ($bat1_val < 10 ? " " : ""), $bat1_val, $bat1_stat[4];
}

if(-e $bat0 && -e $bat1)
{
	my $bats_val = (($bat0_stat[3] + $bat1_stat[3]) / ($bat0_stat[1] + $bat1_stat[1])) * 100;
	printf "overall: %.2f%%\n", $bats_val;
}

exit 0;
