#!/usr/bin/env perl
##
## hex - convert between ASCII and hexadecimal string representation
## Copyright (C) 2020-2023 Daniel Haase
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
use 5.010;

use File::Basename;

our $VERSION = v2.1.5;

sub print_version {
    my $version = version::->parse($VERSION)->normal;

    say "hex $version\ncopyright (c) 2020-2023 Daniel Haase";
    return;
}

sub print_usage {
    my $caller = basename(__FILE__);
    my $description = <<"EOF";

usage: $caller [-a | -x] [0x]<string>
       $caller [--version | --help]

   [0x]<string>
      <string> is converted from ASCII to hexadecimal
      representation, unless prefixed with "0x", in which case
      the inverse conversion is performed

   -a
      convert ASCII <string> to hexdecimal representation;
      allowing for arguments legitimately starting with "0x"
      (can occur before or after <string>)

      this is the default, if neither "-a" nor "-x" are given
      and <string> is not prefixed by "0x"

   -x
      convert hexadecimal <string> to ASCII representation
      (can occur before or after <string>)

   --version
      print version information and exit

   --help
      print this help message and exit

EOF

    print_version;
    print $description;
    return;
}

sub fail_with_usage {
    print_usage;
    exit 1;
}

sub is_flag {
    my ($variable, $expected) = @_;

    if (not defined $variable or not defined $expected) {
        return 0;
    }

    return $variable eq $expected;
}

sub is_hex {
    my ($value) = @_;

    $value = lc $value;
    return ($value =~ /^(\d|[a-f])+$/xms);
}

sub ascii_to_hex {
    my ($value) = @_;

    $value =~ s/(.)/sprintf("%x", ord($1))/egxms;
    return $value;
}

sub hex_to_ascii {
    my ($value) = @_;

    if (not is_hex($value)) {
        say { \*STDERR } "illegal, non-hexadecimal digit(s) in \"$value\"";
        exit 2;
    }

    $value =~ s/(..)/sprintf("%c", hex("0x${1}"))/egxms;
    return $value;
}

if (@ARGV == 1) {
    my $argument = $ARGV[0];

    if ($argument eq '--version') {
        print_version;
    } elsif ($argument eq '--help') {
        print_usage;
    } elsif ('0x' eq substr $argument, 0, 2) {
        say hex_to_ascii(substr $argument, 2);
    } else {
        say ascii_to_hex($argument);
    }
} elsif (@ARGV == 2) {
    my @flags = grep { /^-a|x$/xms } @ARGV;

    if (is_flag($flags[0], '-a') or is_flag($flags[1], '-a')) {
        my @arguments = grep { !/^-a$/xms } @ARGV;

        if (@arguments == 1) {
            say ascii_to_hex($arguments[0]);
        } else {
            say ascii_to_hex('-a');
        }
    } elsif (is_flag($flags[0], '-x')) {
        my @arguments = grep { !/^-x$/xms } @ARGV;

        if (@arguments == 1) {
            say hex_to_ascii($arguments[0]);
        } else {
            fail_with_usage;
        }
    } else {
        fail_with_usage;
    }
} else {
    fail_with_usage;
}

exit 0;
