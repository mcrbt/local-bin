#!/usr/bin/perl

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

sub convert_asc2hex { my $asc = shift; $asc =~ s/(.)/sprintf("%x", ord($1))/eg; print "$asc\n"; }
sub convert_hex2asc { my $hex = shift; $hex =~ s/(..)/sprintf("%c", hex("0x${1}"))/eg; print "$hex\n"; }

sub parse_args
{
	if(@ARGV == 0) { usage(0); }
	elsif(@ARGV > 2) { usage(1); }
	if($ARGV[0] eq "-h" || $ARGV[0] eq "--hex" || $ARGV[0] eq "--hexadecimal")
	{ if(@ARGV != 2) { usage(1); } else { convert_asc2hex($ARGV[1]); } }
	elsif($ARGV[0] eq "-a" || $ARGV[0] eq "--asc" || $ARGV[0] eq "--ascii")
	{ if(@ARGV != 2) { usage(1); } else { convert_hex2asc($ARGV[1]); } }
	elsif($ARGV[0] eq "--help") { usage(0); }
	else { if(@ARGV != 1) { usage(1); } else { convert_asc2hex($ARGV[0]); } }
}

parse_args();
exit 0;
