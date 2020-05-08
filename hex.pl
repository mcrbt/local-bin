#!/usr/bin/perl
##
## hex - convert between ASCII and hexadecimal string representation
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

use strict;
use warnings;

sub usage
{
	print "\r\nusage: " . __FILE__ . " [-h | -a] <string>\r\n";
	print "       " . __FILE__ . " --help\r\n\r\n";
	print "  -h | --hex | --hexadecimal\r\n";
	print "      convert ASCII <string> to hexadecimal representation\r\n";
	print "  -a | --asc | --ascii\r\n";
	print "      convert hexadecimal <string> to ASCII representation\r\n";
	print "  --help\r\n";
	print "      print this help message and exit\r\n\r\n";
	exit shift;
}

sub asc2hex { my $asc = shift; $asc =~ s/(.)/sprintf("%x", ord($1))/eg; print "$asc\n"; }
sub hex2asc { my $hex = shift; $hex =~ s/(..)/sprintf("%c", hex("0x${1}"))/eg; print "$hex\n"; }

sub parse_args
{
	if(@ARGV == 0) { usage(0); }
	elsif(@ARGV > 2) { usage(1); }
	if($ARGV[0] eq "-h" || $ARGV[0] eq "--hex" || $ARGV[0] eq "--hexadecimal")
	{ if(@ARGV != 2) { usage(1); } else { asc2hex($ARGV[1]); } }
	elsif($ARGV[0] eq "-a" || $ARGV[0] eq "--asc" || $ARGV[0] eq "--ascii")
	{ if(@ARGV != 2) { usage(1); } else { hex2asc($ARGV[1]); } }
	elsif($ARGV[0] eq "--help") { usage(0); }
	else { if(@ARGV != 1) { usage(1); } else { asc2hex($ARGV[0]); } }
}

parse_args();
exit 0;
