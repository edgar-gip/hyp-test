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

# Iman and Davenport test
# F statistic for a Friedman test
package StatTests::ImanDavenport;

our @ISA = qw( Exporter );
our @EXPORT = qw( imanDavenport );

use Carp qw( croak );

# Make the test
sub imanDavenport {
    # Check the argument is a Friedman
    croak 'Must provide an argument' if @_ != 1;
    croak 'Argument must be a Friedman model'
        if ref($_[0]) ne 'StatTests::Friedman';
    my ($friedman) = @_;

    # Convert to F
    my ($k, $N, $chiSq) = @{$friedman}{'k', 'N', 'chiSq'};
    my $F     = ($N - 1) * $chiSq / ($N * ($k - 1) - $chiSq);
    my $dfNum = $k - 1;
    my $dfDen = ($k - 1) * ($N - 1);

    # Save everything to the object
    my $this = {
        'F' => $F, 'dfNum' => $dfNum, 'dfDen' => $dfDen
    };
    return bless($this, __PACKAGE__);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+------+------+
|      F      | DFNu | DFDe |
+-------------+------+------+
| % .4e | %4d | %4d |
+-------------+------+------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'F', 'dfNum', 'dfDen'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'F'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::pf($this->{'F'}, $this->{'dfNum'},
                       $this->{'dfDen'}, 0, 0);
}

# Return true
1;
