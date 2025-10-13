use strict;

use Exporter;

use Math::R;

# Nemenyi test, after a Friedman test
package StatTests::Nemenyi;

our @ISA = qw( Exporter );
our @EXPORT = qw( nemenyi );

use Carp qw( croak );

# Make the test
sub nemenyi {
    # Check arguments
    croak 'Must provide three arguments.'
        if @_ != 3;
    my ($friedman, $col1, $col2) = @_;
    croak 'First argument must be a Friedman model.'
        if ref($friedman) ne 'StatTests::Friedman';
    croak 'Second and third arguments must be integers.'
        if $col1 !~ /^\d+$/ || $col2 !~ /^\d+/;
    my $k = $friedman->{'k'};
    croak 'Column out of range'
        if $col1 < 0 || $col1 >= $k || $col2 < 0 || $col2 >= $k;

    # Factor
    my $r1 = $friedman->{'avgRank'}[$col1];
    my $r2 = $friedman->{'avgRank'}[$col2];
    my $N  = $friedman->{'N'};
    my $z = ($r1 - $r2) / sqrt($k * ($k + 1) / 6 / $N);

    # Save everything to the object
    my $this = {
        'r1' => $r1, 'r2' => $r2, 'z' => $z, 'k' => $k
    };
    return bless($this);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+-------------+-------------+
|   Rank 1    |   Rank 2    |   Nemenyi   |
+-------------+-------------+-------------+
| % .4e | % .4e | % .4e |
+-------------+-------------+-------------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'r1', 'r2', 'z'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'z'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::ptukey($this->{'z'} * sqrt(2), 1,
                           $this->{'k'}, 'inf', 0, 0);
}

# Return true
1;
