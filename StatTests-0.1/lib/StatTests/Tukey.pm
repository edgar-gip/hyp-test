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

# Tukey test, after a PairedANOVA test
package StatTests::Tukey;

our @ISA = qw( Exporter );
our @EXPORT = qw( tukey );

use Carp qw( croak );

# Make the test
sub tukey {
    # Check arguments
    croak 'Must provide three arguments.'
        if @_ != 3;
    my ($anova, $col1, $col2) = @_;
    croak 'First argument must be a PairedANOVA model.'
        if ref($anova) ne 'StatTests::PairedANOVA';
    croak 'Second and third arguments must be integers.'
        if $col1 !~ /^\d+$/ || $col2 !~ /^\d+/;
    my $k = $anova->{'k'};
    croak 'Column out of range'
        if $col1 < 0 || $col1 >= $k || $col2 < 0 || $col2 >= $k;

    # Find the means
    my $m1 = $anova->{'sum'}[$col1] / $anova->{'N'};
    my $m2 = $anova->{'sum'}[$col2] / $anova->{'N'};

    # Factor
    my $t = ($m1 - $m2) / sqrt($anova->{'msErr'} / $anova->{'N'});

    # Save everything to the object
    my $this = {
        'm1' => $m1,
        'm2' => $m2, 't' => $t,
        'k'  => $k,  'dfErr' => $anova->{'dfErr'}
    };
    return bless($this);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+-------------+-------------+
|    Mean1    |    Mean2    |    Tukey    |
+-------------+-------------+-------------+
| % .4e | % .4e | % .4e |
+-------------+-------------+-------------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'m1', 'm2', 't'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'t'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::ptukey(abs($this->{'t'}), 1,
                           $this->{'k'},
                           $this->{'dfErr'}, 0, 0);
}

# Return true
1;
