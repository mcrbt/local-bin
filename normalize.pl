#!/usr/bin/perl

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
	$name =~ s/á|à/a/g;
	$name =~ s/é|è/e/g;
	$name =~ s/í|ì/i/g;
	$name =~ s/ó|ò/o/g;
	$name =~ s/ú|ù/u/g;
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
