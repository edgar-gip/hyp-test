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

# Bonferroni-Dunn test, after a Friedman test
package StatTests::BonferroniDunn;

our @ISA = qw( Exporter );
our @EXPORT = qw( bonferroniDunn );

use Carp qw( croak );

# Make the test
sub bonferroniDunn {
    # Check arguments
    croak 'Must provide three arguments.'
        if @_ != 3;
    my ($friedman, $col1, $col2) = @_;
    croak 'First argument must be a Friedman model.'
        if ref($friedman) ne 'StatTests::Friedman';
    croak 'Second and third arguments must be integers.'
        if $col1 !~ /^\d+$/ || $col2 !~ /^\d+/;
    my $k = $friedman->{'k'};
    croak 'Column out of range'
        if $col1 < 0 || $col1 >= $k || $col2 < 0 || $col2 >= $k;

    # Factor
    my $r1 = $friedman->{'avgRank'}[$col1];
    my $r2 = $friedman->{'avgRank'}[$col2];
    my $N  = $friedman->{'N'};
    my $z = ($r1 - $r2) / sqrt($k * ($k + 1) / 6 / $N);

    # Save everything to the object
    my $this = {
        'r1' => $r1, 'r2' => $r2, 'z' => $z, 'k' => $k
    };
    return bless($this);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+-------------+-------------+
|   Rank 1    |   Rank 2    | Bonferroni  |
+-------------+-------------+-------------+
| % .4e | % .4e | % .4e |
+-------------+-------------+-------------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'r1', 'r2', 'z'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'z'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;

    my $cf = ($this->{'k'} - 1) * Math::R::pnorm($this->{'z'}, 0, 1, 0, 0);
    return $cf < 1.0 ? $cf : 1.0;
}

# Return true
1;
