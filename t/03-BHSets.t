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

use Test::More tests => 10;

# sub display {
#     my ($label, $hc, $hp) = @_;

#     print STDERR ("$label\n");
#     for (my $i = 0; $i < @{$hc} || $i < @{$hp}; ++$i) {
#       printf STDERR ("\t%40s | %40s\n",
#                      join(" ", @{$hc->[$i]}),
#                      join(" ", @{$hp->[$i]}));
#     }
#     print STDERR ("\n");
# }

BEGIN {
    use_ok('BHSets');
    use_ok('BHSets::Perl');
};

for (my $i = 0; $i <= 7; ++$i) {
    my @hc = BHSets::exhaustiveSets($i);
    my @hp = BHSets::Perl::exhaustiveSets($i);

    # display("ES($i):", \@hc, \@hp);

    is_deeply(\@hc, \@hp, "Equal exhaustive sets $i");
}
