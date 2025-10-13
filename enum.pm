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
                no strict 'refs';
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
