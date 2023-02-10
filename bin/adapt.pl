#!/usr/bin/env -S perl -W
##
## normalize - adapt file names for use with Linux file systems
## Copyright (C) 2020-2021 Daniel Haase
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
use utf8;

binmode(STDOUT, ":utf8");

use Cwd qw(abs_path);

use constant VERSION => "0.4.3";
my $mvno = 0;
my $skno = 0;

## retrieve the filename of a file from a path
sub filename
{
	my $name = shift;
	if(not defined $name or length($name) == 0) { return ""; }
	my $len = length($name);
	my $idx = rindex($name, "/");
	if(not defined $idx) { return $name; }

	if($idx == ($len - 1))
	{
		$name = substr($name, 0, ($len - 1));
		$idx = rindex($name, "/");
	}

	return substr($name, ($idx + 1));
}

## retrieve the directory name of a file from a path
sub dirname
{
	my $name = shift;
	if(not defined $name or length($name) == 0) { return ""; }
	if(-e $name) { $name = abs_path($name); }
	my $len = length($name);
	my $idx = rindex($name, "/");
	if(not defined $idx) { return ""; }
	return substr($name, 0, $idx);
}

## retrieve a file's name without the filename extension
sub basename
{
	my $name = filename(shift);
	my $len = length($name);
	my $idx = rindex($name, ".");
	if(not defined $len or $len == 0) { return ""; }
	if(not defined $idx or $idx < 1) { return $name; }
	else { return substr($name, 0, $idx); }
}

## retrieve filename extension of a file
sub extension
{
	my $name = filename(shift);
	my $len = length($name);
	my $idx = rindex($name, ".");
	if(not defined $len or $len == 0) { return ""; }
	if(not defined $idx or $idx < 1) { return ""; }
	else { return substr($name, ($idx + 1)); }
}

## print version information
sub version
{
	print("normalize version " . VERSION . "\r\n");
	print("copyright (c) 2020-2021 Daniel Haase\r\n");
}

## print usage information and exit
sub usage
{
	my $name = __FILE__;
	version();
	print("\r\nusage:  ", filename($name), " [-r] [<file>]\r\n");
	print("        ", filename($name), " [-h | -V]\r\n\r\n");
	print("  <file>\r\n");
	print("      file which name will be normalized\r\n");
	print("      can be a regular file or a directory\r\n");
	print("      defaults to the current working directory\r\n");
	print("      i.e. giving no arguments is the same as:\r\n");
	print("        " . __FILE__ . " -r .\r\n\r\n");
	print("  -r | --recursive\r\n");
	print("      if <file> is a directory normalize everything\r\n");
	print("      inside that directory recursively in addition\r\n");
	print("      to the name of the directory\r\n\r\n");
	print("  -V | --version\r\n");
	print("      print version information and exit\r\n\r\n");
	print("  -h | --help\r\n");
	print("      print this help message and exit\r\n\r\n");
	exit shift;
}

## decide whether to exclude a file from normalization
sub exclude
{
	my $file = shift;
	if(not defined $file or length($file) == 0) { return 1; }
	if(not -e $file) { return 1; } ## skip non-existent files
	$file = filename($file);
	if(rindex($file, ".", 0) == 0) { return 1; } ## skip hidden files, including ".", and ".."
	if($file eq "HEAD" or $file eq "ORIG_HEAD" or $file eq "INDEX"
	or $file eq "COMMIT_EDITMSG" or $file eq "packed-refs") { return 1; } ## skip git files
	if(rindex($file, "README", 0) == 0) { return 1; } ## skip uppercase README* files
	if(rindex($file, "LICENSE", 0) == 0) { return 1; } ## skip uppercase LICENSE* files
	if(rindex($file, "COPYING", 0) == 0) { return 1; } ## skip uppercase COPYING* files
	if(rindex($file, "AUTHOR", 0) == 0) { return 1; } ## skip uppercase AUTHOR* files
	if(rindex($file, "CONTRIB", 0) == 0) { return 1; } ## skip uppder CONTRIB* files
	if(extension(lc($file)) eq "java") { return 1; } ## skip *.java files
	return 0;
}

## modify filename for easy use from the command line
sub normalize
{
	my $name = shift;
	if(not defined $name or length($name) == 0) { return ""; }

	## convert name to lowercase
	$name = lc($name);
	my $ext = extension($name);
	$name = basename($name);

	## replace some special characters by their ordinary
	$name =~ s/ä/ae/g;
	$name =~ s/ö/oe/g;
	$name =~ s/ü/ue/g;
	$name =~ s/ß/ss/g;
	$name =~ s/á|à|â/a/g;
	$name =~ s/é|è|ê/e/g;
	$name =~ s/í|ì|î/i/g;
	$name =~ s/ó|ò|ô/o/g;
	$name =~ s/ú|ù|û/u/g;

	## replace any dash combinations
	$name =~ s/ - /_/g;
	$name =~ s/ /_/g;
	$name =~ s/_-_/_/g;
	#$name =~ s/-/_/g;

	## replace any brackets
	$name =~ s/\(|\)|\[|\]|\{|\}/_/g;

	## replace most special characters
	$name =~ s/'|"|\?|!|\$|\^|§|%|&|=|,|#|~|\+|\*|<|>|\|/_/g;

	## fix underscore usages in special positions
	$name =~ s/_+/_/g; ## use at most one underscore in a row
	$name =~ s/_+\./\./g; ## delete underscore character before dot
	$name =~ s/^_+(.+)/$1/g; ## delete any underscores at the beginning
	$name =~ s/(.+)_$/$1/g; ## delete any underscores at the end

	## return new filename by re-appending the filename extension
	if(not defined $ext or length($ext) == 0) { return $name; }
	else { return $name . "." . $ext; }
}

## normalize the file by computing its new name,
## actually renaming the file, and changing its permissions
sub move
{
	my $name = shift;
	if(not defined $name or length($name) == 0) { return; }

	my $path = dirname($name);
	my $file = filename($name);

	if(exclude($name))
	{
		if($file ne "." and $file ne "..")
		{
			my $type = "file";
			if(-d $name) { $type = "directory"; }
			$skno += 1;
			print("[info] skip $type \"$file\"\r\n");
		}

		return;
	}

	## normalize the passed filename
	my $norm = normalize($file);

	## rename the file iff the new and old name differ
	if($file ne $norm)
	{
		rename($name, "$path/$norm");
		$mvno += 1;
		print("[info] rename \"$file\" to \"$norm\"\r\n");
		chmod(0644, "$path/$norm");
	}
	else { chmod(0644, $name); } ## change permissions of file
}

## recursively rename files under passed directory
sub dive
{
	my $path = shift;
	if(not defined $path or length($path) == 0) { return; }

	if(exclude($path)) { return; }
	if(not -e $path) { return; }
	$path = abs_path($path);
	if(not -d $path) { move($path); return; }

	if(not -r $path) ## test if parent directory is readable to list contents
	{
		my $parent = filename($path);
		print("[warn] listing files under \"$parent\" not allowed\r\n");
		return;
	}

	opendir(DH, $path);
	my @files = readdir(DH);
	closedir(DH);

	foreach my $file (@files)
	{
		if(-d "$path/$file") { dive("$path/$file"); }

		if(not -w $path) ## test if parent directory is writable to rename files
		{
			my $parent = filename($path);
			print("[warn] renaming files under \"$parent\" not allowed\r\n");
			return;
		}

		move("$path/$file");
	}
}

my $input = $ENV{'PWD'};
my $recurse = 0;

## parse command line arguments
if(@ARGV == 0) { $recurse = 1; }
elsif(@ARGV == 1)
{
	if($ARGV[0] eq "-h" || $ARGV[0] eq "--help") { usage(0); }
	elsif($ARGV[0] eq "-V" || $ARGV[0] eq "--version") { version(); exit(0); }
	elsif($ARGV[0] eq "-r" || $ARGV[0] eq "--recursive") { usage(1); }
	else { $input = $ARGV[0]; }
}
elsif(@ARGV == 2)
{
	$recurse = 1;
	if($ARGV[0] eq "-r" || $ARGV[0] eq "--recursive") { $input = $ARGV[1]; }
	elsif($ARGV[1] eq "-r" || $ARGV[1] eq "--recursive") { $input = $ARGV[0]; }
	else { usage(1); }
}
else { usage(1); }

if(not defined $input or length($input) == 0)
{
	print("[erro] file argument contains invalid characters\r\n");
	exit(2);
}

if(not -e $input)
{
	print("[erro] file or directory not found\r\n");
	exit(3);
}

if(-f $input) { move($input); }
elsif(-d $input)
{
	if($recurse) { dive($input); }
	else { move($input); }
}

if($skno == 1) { print("[info] $skno file skipped\r\n"); }
elsif($skno > 1) { print("[info] $skno files skipped\r\n"); }

## exit successfully
print("[ ok ] $mvno files normalized\r\n");
exit 0;
