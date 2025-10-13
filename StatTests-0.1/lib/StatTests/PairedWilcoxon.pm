# hyp-test: Non-parametric hypothesis testing.
# Copyright (C) 2006-2012  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
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

use Exporter;

use Math::R;

# Wilcoxon non-parametrical test for paired samples
# As specified in (Demsar, 2006)
package StatTests::PairedWilcoxon;

our @ISA = qw( Exporter );
our @EXPORT = qw( pairedWilcoxon );

use Carp qw( croak );
use StatTests::Utilities qw( checkEqArrayRefs );

# Make the test
sub pairedWilcoxon {
    # Check arguments
    croak 'Must provide two arguments.'
        if @_ != 2;
    my $err = checkEqArrayRefs(@_);
    croak $err if $err;

    # Size
    my $N = @{$_[0]};

    # Convert and sort
    my @diffs;
    for (my $i = 0; $i < $N; ++$i) {
        push(@diffs, $_[0][$i] - $_[1][$i]);
    }
    @diffs = sort { abs($a) <=> abs($b) } @diffs;

    # Sums
    my $Wpos = 0;
    my $Wneg = 0;

    # Assign ranks
    my $i = 0;
    while ($i < @diffs) {
        my $j = $i + 1;
        ++$j while $j < @diffs && abs($diffs[$j]) == abs($diffs[$i]);
        my $rank = ($i + $j + 1) / 2;
        for (my $l = $i; $l < $j; ++$l) {
            my $s = Math::R::sign($diffs[$l]);
            if ($s > 0) {
                $Wpos += $rank;
            } elsif ($s == 0) {
                $Wpos += .5 * $rank;
                $Wneg += .5 * $rank;
            } else {
                $Wneg += $rank;
            }
        }
        $i = $j;
    }

    # Find the estimator and the Nsr
    my $W = $Wpos < $Wneg ? $Wpos : $Wneg;

    # Save everything to the object
    my $this = {
        'N' => $N, 'W' => $W
    };
    return bless($this);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+------+
|      W      |  N   |
+-------------+------+
| % .4e | %4d |
+-------------+------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'W', 'N'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'W'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::psignrank($this->{'W'}, $this->{'N'}, 1, 0);
}

# Return true
1;
