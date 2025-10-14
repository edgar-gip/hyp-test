# -*- mode:perl; -*-

# hyp-test: Non-parametric hypothesis testing.
# Copyright (C) 2006-2025  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
