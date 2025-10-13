use strict;

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
