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
use warnings;

use Carp;

# Pragma for defining enumerations
package enum;

# Importation
sub import {
    # Module and Caller
    my $module = shift(@_);
    my $pkg    = caller();

    # Follow each value
    my $cur = 0;
    while (@_) {
        # Get the name
        my $name = shift(@_);

        # Skip?
        if ($name ne '*') {
            # Other
            Carp::croak("Invalid name: $name")
                if $name !~ /_?[^\W_0-9]\w*$/;

            # Peek for a value
            $cur = shift(@_) if @_ && $_[0] =~ /^[\+\-]?\d+$/;

            # Assign
            {
                no strict 'refs';  ## no critic (ProhibitNoStrict)
                my $full_name = "${pkg}::$name";
                my $val       = $cur;
                *$full_name   = sub () { $val };
            }
        }

        # Next one
        ++$cur;
    }
}

# Return true
1;
