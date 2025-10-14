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

use Exporter;

# Contains utility functions
package StatTests::Utilities;

our @ISA = qw( Exporter );
our @EXPORT_OK = qw( checkArrayRefs checkEqArrayRefs );


# Check if all arguments are array references
sub checkArrayRefs {
    foreach (@_) {
        return 'Argument should be an array reference.'
            if ref(@_) ne 'ARRAY';
    }
}

# Check if all arguments are array references of the same size
sub checkEqArrayRefs {
    return if @_ < 2;
    return 'Argument should be an array reference.'
        if ref($_[0]) ne 'ARRAY';
    my $size = @{$_[0]};
    for (my $i = 1; $i < @_; ++$i) {
        return 'Argument should be an array reference.'
            if ref($_[$i]) ne 'ARRAY';
        return 'All arguments should be array references of the same size.'
            if @{$_[$i]} != $size;
    }
}

# Return true
1;
