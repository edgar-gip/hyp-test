# -*- mode: perl; -*-

# 02-Friedman.t: Friedman Test Tests
# Edgar Gonzàlez i Pellicer, 2010

use strict;
use warnings;

use Test::More tests => 12;

# Use OK
BEGIN { use_ok('StatTests::Friedman') };

# Read the data
my $header = <DATA>;
my @data;
while (<DATA>) {
    chomp();
    my @F = split();
    shift(@F);
    push(@{$data[$_]}, $F[$_]) foreach 0 .. $#F;
}

# Make the test
my $f = StatTests::Friedman::friedman(@data);

# Check the values
SKIP : {
    skip(2, "Returned object is not a StatTests::Friedman")
	if not isa_ok($f, 'StatTests::Friedman');

    is($f->{'k'},   3);
    is($f->{'N'},  22);
    is($f->{'df'},  2);

    is($f->{'chiSq'},   11.1428571428571);
    is($f->statistic(), 11.1428571428571);
    is($f->confidence(), 0.00380504077551136);

    my $ar = $f->{'avgRank'};
    is(@{$ar}, 3);
    is($ar->[0], 53 / 22);
    is($ar->[1], 47 / 22);
    is($ar->[2], 32 / 22);
}

# Data, from p.141 of
#   M. Hollander, D. Wolfe
#   "Nonparametric Statistical Methods"
#   John Wiley and Sons, 1973
# For this data set, the value statistic should be
#   S = 11.1
__DATA__
Players Round_Out Narrow_Angle Wide_Angle
 1 5.40 5.50 5.55
 2 5.85 5.70 5.75
 3 5.20 5.60 5.50
 4 5.55 5.50 5.40
 5 5.90 5.85 5.70
 6 5.45 5.55 5.60
 7 5.40 5.40 5.35
 8 5.45 5.50 5.35
 9 5.25 5.15 5.00
10 5.85 5.80 5.70
11 5.25 5.20 5.10
12 5.65 5.55 5.45
13 5.60 5.35 5.45
14 5.05 5.00 4.95
15 5.50 5.50 5.40
16 5.45 5.55 5.50
17 5.55 5.55 5.35
18 5.45 5.50 5.55
19 5.50 5.45 5.25
20 5.65 5.60 5.40
21 5.70 5.65 5.55
22 6.30 6.30 6.25
