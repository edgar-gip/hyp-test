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
    eval $code;
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
    eval $code;
    die "Internal error: $@" if $@;
}


# Return true
1;
