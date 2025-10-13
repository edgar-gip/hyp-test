use strict;
use warnings;

# Perl implementation
package BHSets::Perl;
our @ISA = qw(Exporter);

# Exports
our @EXPORT      = qw( );
our @EXPORT_OK   = qw( exhaustiveSets );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

# For each possible division
sub bhDivisions {
    my ($cls, $i, $c1, $c2, $callback) = @_;

    # Last one?
    if ($i == $#{$cls}) {
        # c1 is empty?
        return if !@{$c1};

        # Add it to c2
        push(@{$c2}, $cls->[$i]);

        # Call the callback
        $callback->($c1, $c2);

        # Pop
        pop(@{$c2});
    }
    else {
        # Add it to c1, and make the recursive call
        push(@{$c1}, $cls->[$i]);
        bhDivisions($cls, $i + 1, $c1, $c2, $callback);
        pop(@{$c1});

        # Add it to c2, and make the recursive call
        push(@{$c2}, $cls->[$i]);
        bhDivisions($cls, $i + 1, $c1, $c2, $callback);
        pop(@{$c2});
    }
}

# Bergmann-Hommel exhaustive sets
# Recursive function
sub bhExhaustiveSetsRec {
    my ($cls) = @_;

    # Return empty if less than two classifiers
    return if @{$cls} < 2;

    # Generate all pair-wise comparisons
    my @all;
    my @E = ( \@all );
    for (my $i = 0; $i < @{$cls}; ++$i) {
        for (my $j = $i + 1; $j < @{$cls}; ++$j) {
            push(@all, $cls->[$i] . ','  . $cls->[$j]);
        }
    }

    # For each possible division
    bhDivisions($cls, 0, [], [],
                sub {
                    my ($c1, $c2) = @_;

                    my @E1 = bhExhaustiveSetsRec($c1);
                    my @E2 = bhExhaustiveSetsRec($c2);

                    push(@E, @E1, @E2);

                    foreach my $e1 (@E1) {
                        foreach my $e2 (@E2) {
                            push(@E, [ @{$e1}, @{$e2} ]);
                        }
                    }
                });

    # Return the total
    return @E;
}

# Lexicographical sort
sub lexicographical {
    # Lengths different?
    if (@{$a} != @{$b}) {
        # Compare lengths
        return @{$a} <=> @{$b};
    }
    else {
        # Find first difference
        for (my $i = 0; $i < @{$a}; ++$i) {
            return $a->[$i] cmp $b->[$i] if $a->[$i] ne $b->[$i];
        }

        # Equal
        return 0;
    }
}

# Lexicographical sort
sub lexicographicalAB {
    local $a = $_[0];
    local $b = $_[1];
    return lexicographical();
}

# Exhaustive sets
sub exhaustiveSets {
    my ($k) = @_;

    # Call recursive version
    my @E = bhExhaustiveSetsRec([ 0 .. $k - 1 ]);

    # Sort lexicographically
    @E = sort lexicographical @E;

    # Remove repeated
    if (@E) {
        my $src = 1;
        my $tgt = 0;
        while ($src < @E) {
            $E[++$tgt] = $E[$src] if lexicographicalAB($E[$src], $E[$tgt]);
            ++$src;
        }
        $#E = $tgt;
    }

    # Return
    return @E;
}

# Return true
1;
