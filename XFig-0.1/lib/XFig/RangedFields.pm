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

# Ranged fields
package XFig::RangedFields;

# Importing
sub import {
    # Get the caller context
    my $pkg = caller();

    # Skip package name
    shift(@_);

    # Check and warn
    warn "Extra arguments for RangedFields ignored\n"
        if @_ % 4;

    # Create the accessor functions
    for (my $i = 0; $i < @_ - 3; $i += 4) {
        createAccessor($pkg, @_[$i..$i+3]);
    }

    # Create the empty constructor
    createEmpty($pkg, @_);
}

# Create an accessor
sub createAccessor {
    my ($pkg, $field, $low, $default, $high) = @_;

    # Create the function code
    my $code = << "FUN;";
    sub ${pkg}::$field {
        my (\$this, \$$field) = \@_;

        if (defined(\$$field)) {
            Carp::croak "Wrong $field: \$$field"
                if \$$field < $low || \$$field > $high;
            \$this->{'$field'} = \$$field;
        }

        return \$this->{'$field'};
    }
FUN;

    # Evaluate it
    eval $code;  ## no critic (ProhibitStringyEval)
    die "Internal error: $@" if $@;
}

# Create empty constructor
sub createEmpty {
    my ($pkg, @fields) = @_;

    # Create the initialization sentence
    my @init;
    for (my $i = 0; $i < @fields - 3; $i += 4) {
        push(@init, sprintf('"%s" => %d', @fields[$i,$i+2]));
    }
    my $init = join(', ', @init);

    # Create the function
    my $code = << "FUN;";
    sub ${pkg}::_empty {
        my (\$class) = \@_;

        my \$this = { $init };
        return bless(\$this, \$class);
    }
FUN;

    # Evaluate it
    eval $code;  ## no critic (ProhibitStringyEval)
    die "Internal error: $@" if $@;
}


# Return true
1;
