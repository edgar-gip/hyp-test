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

use Exporter;

use Math::R;

# Z statistic for the PairedWilcoxon test
# As specified in (Demsar, 2006)
package StatTests::PairedWilcoxonZ;

our @ISA = qw( Exporter );
our @EXPORT = qw( pairedWilcoxonZ );

use Carp qw( croak );

# Make the test
sub pairedWilcoxonZ {
    # Check the argument is a Wilcoxon
    croak 'Must provide an argument' if @_ != 1;
    croak 'Argument must be a PairedWilcoxon model'
        if ref($_[0]) ne 'StatTests::PairedWilcoxon';
    my ($wilcox) = @_;

    # Find Z
    my $N = $wilcox->{'N'};
    # my $stdDev = sqrt($N * ($N + 1) * (2 * $N + 1) / 6);
    # my $z = ($wilcox->{'W'} - .5) / $stdDev;
    my $stdDev = sqrt($N * ($N + 1) * (2 * $N + 1) / 24);
    my $z = ($wilcox->{'W'} - $N * ($N + 1) / 4) / $stdDev;

    # Save everything to the object
    my $this = {
        'N' => $N, 'z' => $z
    };
    return bless($this, __PACKAGE__);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+------+
|      Z      |  N   |
+-------------+------+
| % .4e | %4d |
+-------------+------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'z', 'N'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'z'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::pnorm($this->{'z'}, 0.0, 1.0, 1, 0);
}

# Return true
1;
