# -*- mode:perl; -*-

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
    use_ok('BH');
};

my @input = ([ 0, 1, 0.0048 ],
             [ 0, 2, 0.8065 ],
             [ 0, 3, 4.487e-8 ],
             [ 0, 4, 0.0128 ],
             [ 1, 2, 0.0101 ],
             [ 1, 3, 0.008 ],
             [ 1, 4, 0.744 ],
             [ 2, 3, 1.736e-7 ],
             [ 2, 4, 0.0247 ],
             [ 3, 4, 0.0029 ]);

my @output = BH::bergmannHommelOnline(5, @input, 0.05);

my @expected = ([ 0, 2, 0.8065 ],
                [ 1, 4, 0.744 ]);

is(scalar(@output), scalar(@expected));
is_deeply($output[$_], $expected[$_]) foreach 0 .. $#expected;
