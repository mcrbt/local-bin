#!/usr/bin/env perl
##
## battery - get capacity of installed batteries
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

binmode STDOUT, ':encoding(UTF-8)' or
    die 'STDOUT does not support UTF-8 encoding';

our $VERSION = v0.2.4;

my $POWER_SUPPLY_PATH =
    $ENV{'POWER_SUPPLY_PATH'} || '/sys/class/power_supply';
my $UEVENT_FIELD_PREFIX = 'POWER_SUPPLY_';

sub trim {
    my ($string) = @_;

    $string =~ s/(^\s+)|(\s+$)//gxms;
    return $string;
}

sub is_valid_scalar {
    my ($value) = @_;

    return (
        defined $value and
            ref $value eq q{} and
            length trim($value)
    );
}

sub raise {
    my ($message) = @_;

    if (is_valid_scalar($message)) {
        say { \*STDERR } $message;
    } else {
        die 'invalid scalar';
    }

    return;
}

sub panic {
    my ($argument) = @_;

    raise($argument);
    exit 2;
}

sub print_version {
    my $version = version::->parse($VERSION)->normal;

    say "battery $version\ncopyright (c) 2020-2023 Daniel Haase";
    return;
}

sub print_usage {
    my $caller = basename(__FILE__);
    my $description = <<"EOF";

usage: $caller [--version | --help]

   --version
      print version information and exit

   --help
      print this help message and exit

EOF

    print_version;
    print $description;
    return;
}

sub parse_arguments {
    if (@ARGV == 1) {
        my $argument = $ARGV[0];

        if ($argument eq '--version') {
            print_version;
            exit 0;
        } elsif ($argument eq '--help') {
            print_usage;
            exit 0;
        } else {
            raise("unknown command line argument \"$argument\"\n");
            print_usage;
            exit 1;
        }
    } elsif (@ARGV > 1) {
        raise("too many command line arguments\n");
        print_usage;
        exit 1;
    }

    return;
}

sub get_power_supply_data {
    my ($supply) = @_;

    if (not is_valid_scalar($supply)) {
        die 'invalid scalar';
    }

    my $filename = "$supply/uevent";

    if (not -e $filename) {
        panic("no such file \"$filename\"");
    }

    my %data;
    my $prefix_regex = qr/$UEVENT_FIELD_PREFIX/xms;

    open my $battery, '<', $filename or
        panic("failed to open file \"$filename\"");

    while (<$battery>) {
        chomp;

        my @line = split /=/xms;

        if (not /^${prefix_regex}[[:upper:]]|_+=.+$/xms) {
            next;
        }

        my $key = trim($line[0]);

        $key =~ s/${prefix_regex}//xms;
        $key = lc $key;
        $data{$key} = trim($line[1]);
    }

    close $battery or
        panic("failed to close file \"$filename\"");
    return %data;
}

sub load_battery_power_supplies {
    if (not -d $POWER_SUPPLY_PATH) {
        panic("no such directory \"$POWER_SUPPLY_PATH\"");
    }

    my @files = glob "$POWER_SUPPLY_PATH/*";
    my @supplies;

    foreach my $file (@files) {
        my %supply = get_power_supply_data($file);

        if (not exists $supply{'type'}) {
            next;
        }

        my $type = lc $supply{'type'};

        if ($type eq 'battery') {
            push @supplies, \%supply;
        }
    }

    return @supplies;
}

sub aggregate_totals {
    my ($supplies) = @_;

    if (ref $supplies ne 'ARRAY') {
        die 'invalid array reference';
    }

    my %totals = ('name' => 'total');

    foreach (@{$supplies}) {
        $totals{'energy_now'} += $_->{'energy_now'};
        $totals{'energy_full'} += $_->{'energy_full'};
        $totals{'energy_full_design'} += $_->{'energy_full_design'};
    }

    return %totals;
}

sub aggregate_status {
    my ($totals, $supplies) = @_;

    if (ref $totals ne 'HASH') {
        die 'invalid hash reference';
    }

    if (ref $supplies ne 'ARRAY') {
        die 'invalid array reference';
    }

    my %status_map = (
        'full' => 0,
        'charging' => 0,
        'discharging' => 0,
        'not charging' => 0,
    );

    foreach (@{$supplies}) {
        my $status = lc $_->{'status'};

        $status_map{$status} += 1;
    }

    my $supply_count = scalar @{$supplies};

    if ($supply_count == 0) {
        $totals->{'status'} = 'unknown';
    } elsif ($status_map{'full'} == $supply_count) {
        $totals->{'status'} = 'full';
    } elsif ($status_map{'charging'} > $status_map{'discharging'}) {
        $totals->{'status'} = 'charging';
    } elsif ($status_map{'discharging'} > $status_map{'charging'}) {
        $totals->{'status'} = 'discharging';
    } elsif (
        $status_map{'not charging'} > 0
        and
        $status_map{'discharging'} < 1
        and
        $status_map{'charging'} < 1
    ) {
        $totals->{'status'} = 'not charging';
    } else {
        $totals->{'status'} = 'unknown';
    }

    return;
}

sub percentage {
    my ($share, $total) = @_;

    if (is_valid_scalar($share) and is_valid_scalar($total)) {
        return (($share / $total) * 100);
    }

    return 0;
}

sub calculate_capacity {
    my ($data) = @_;

    if (ref $data ne 'HASH') {
        die 'invalid hash reference';
    }

    return percentage($data->{'energy_now'}, $data->{'energy_full'});
}

sub calculate_design_capacity {
    my ($data) = @_;

    if (ref $data ne 'HASH') {
        die 'invalid hash reference';
    }

    return percentage($data->{'energy_now'}, $data->{'energy_full_design'});
}

sub format_output {
    my ($data) = @_;

    if (ref $data ne 'HASH') {
        die 'invalid hash reference';
    }

    my $capacity = calculate_capacity($data);
    my $design_capacity = calculate_design_capacity($data);

    return sprintf '%8s:  %6.2f%%  (%6.2f%%)  [%s]', $data->{'name'},
        $capacity, $design_capacity, lc $data->{'status'};
}

sub aggregate_output {
    my ($supplies) = @_;
    my @output;

    if (ref $supplies ne 'ARRAY') {
        die 'invalid array reference';
    }

    foreach (@{$supplies}) {
        push @output, format_output($_);
    }

    return join qq{\n}, @output;
}

parse_arguments;

my @supplies = load_battery_power_supplies;

if (@supplies > 1) {
    my %totals = aggregate_totals(\@supplies);

    aggregate_status(\%totals, \@supplies);
    push @supplies, \%totals;
}

say aggregate_output(\@supplies);
exit 0;
