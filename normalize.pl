#!/usr/bin/perl
##
## normalize - adapt file names for use with Linux file systems
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

my $VERSION = "0.3.1";
my $mvno = 0;

sub basename
{
	my $name = shift;
	my $len = length $name;
	my $idx = rindex $name, "/";

	if(!defined $idx) { return $idx; }
	if($idx eq ($len - 1))
	{
		$name = substr $name, 0, ($len - 1);
		$idx = rindex $name, "/";
	}

	$name = substr $name, ($idx + 1);
	return $name;
}

sub version
{
	print "normalize version $VERSION\n";
	print " - normalize filenames for UNIX systems\n";
	print "copyright (c) 2020 Daniel Haase\n";
}

sub usage
{
	my $name = __FILE__;
	version;
	print "\nusage:  ", basename($name), " [-r] [<file>]\n";
	print "        ", basename($name), " [-h | -V]\n\n";
	print "  <file>\n";
	print "      file which name will be normalized\n";
	print "      can be a regular file or a directory\n";
	print "      defaults to the current working directory\n";
	print "      i.e. giving no arguments is the same as:\n";
	print "        " . __FILE__ . " -r .\n\n";
	print "  -r | --recursive\n";
	print "      if <file> is a directory normalize everything\n";
	print "      inside that directory recursively in addition\n";
	print "      to the name of the directory\n\n";
	print "  -V | --version\n";
	print "      print version information and exit\n\n";
	print "  -h | --help\n";
	print "      print this help message and exit\n\n";
	exit shift;
}

sub normalize
{
	my $name = shift;
	$name = lc $name;
	$name =~ s/ - /_/g;
	$name =~ s/ /_/g;
	$name =~ s/\(|\)|\[|\]|\{|\}/_/g;
	$name =~ s/'|"|\?|!|\$|\^|§|%|&|=|,|#|~|\+|\*|<|>|\|/_/g;
	$name =~ s/ä/ae/g;
	$name =~ s/ö/oe/g;
	$name =~ s/ü/ue/g;
	$name =~ s/ß/ss/g;
	$name =~ s/á|à|â/a/g;
	$name =~ s/é|è|ê/e/g;
	$name =~ s/í|ì|î/i/g;
	$name =~ s/ó|ò|ô/o/g;
	$name =~ s/ú|ù|û/u/g;
	$name =~ s/_-_/_/g;
	$name =~ s/_+/_/g;
	$name =~ s/_+\./\./g;
	return $name;
}

sub permit
{
	my $name = shift;
	if($> eq 0) { chmod 0644, $name; }
}

sub move
{
	my $name = shift;
	my $norm = normalize $name;

	if($name ne $norm)
	{
		rename $name, $norm;
		$mvno += 1;
		permit $norm;
	}
	else { permit $name; }
}

sub dive
{
	my $dir = shift;
	my @files;

	opendir DH, $dir;
	@files = readdir DH;
	closedir DH;

	foreach my $file (@files)
	{
		if($file eq "." || $file eq "..") { next; }
		move "$dir/$file";
		if(-d "$dir/$file") { dive("$dir/$file"); }
	}
}

if(@ARGV == 0) { dive($ENV{'PWD'}); }
elsif(@ARGV == 1)
{
	if($ARGV[0] eq "-h" || $ARGV[0] eq "--help") { usage 0; }
	elsif($ARGV[0] eq "-V" || $ARGV[0] eq "--version") { version; exit 0; }
	elsif($ARGV[0] =~ /-{1,2}.*/) { usage 1; }
	else { move $ARGV[0]; }
}
elsif(@ARGV == 2)
{
	if($ARGV[0] eq "-r" || $ARGV[0] eq "--recursive") { dive $ARGV[1]; }
	elsif($ARGV[1] eq "-r" || $ARGV[1] eq "--recursive") { dive $ARGV[0]; }
	else { usage 1; }
}
else { usage 1; }

print "$mvno files normalized\n";
exit 0;
