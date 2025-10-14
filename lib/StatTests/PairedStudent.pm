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

use Math::R;

# Student test for paired samples
package StatTests::PairedStudent;

our @ISA = qw( Exporter );
our @EXPORT = qw( pairedStudent );

use Carp qw( croak );
use StatTests::Utilities qw( checkEqArrayRefs );

# Make the test
sub pairedStudent {
    # Check arguments
    croak 'Must provide two arguments.'
        if @_ != 2;
    my $err = checkEqArrayRefs(@_);
    croak $err if $err;

    # Size
    my $N = @{$_[0]};

    # Statistics;
    my $sum1;
    my $sum2;
    my $sumDf;
    my $sumDfSq;

    # Get accumulated statistics
    for (my $i = 0; $i < $N; ++$i) {
        $sum1 += $_[0][$i];
        $sum2 += $_[1][$i];

        my $diff = $_[0][$i] - $_[1][$i];
        $sumDf   += $diff;
        $sumDfSq += $diff * $diff;
    }

    # Get estimator
    my $meanDf = $sumDf / $N;
    my $varDf  = ($sumDfSq - $sumDf * $sumDf / $N) / ($N - 1);
    my $samDev = sqrt($varDf / $N);
    my $t      = $meanDf / $samDev;

    # Save everything to the object
    my $this = {
        'N'  => $N,         'df' => $N - 1,
        'm1' => $sum1 / $N, 'm2' => $sum2 / $N,
        't'  => $t
    };
    return bless($this, __PACKAGE__);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+-------------+-------------+----+
|   Mean 1    |   Mean 2    |   Student   | DF |
+-------------+-------------+-------------+----+
| % .4e | % .4e | % .4e | %2d |
+-------------+-------------+-------------+----+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'m1', 'm2', 't', 'df'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'t'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::pt($this->{'t'}, $this->{'df'}, 0, 0);
}

# Return true
1;
