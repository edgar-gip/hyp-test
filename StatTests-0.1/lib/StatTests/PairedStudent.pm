use strict;

use Math::R;

# Student test for paired samples
package StatTests::PairedStudent;

our @ISA = qw( Exporter );
our @EXPORT = qw( pairedStudent );

use Carp qw( croak );
use StatTests::Utilities qw( checkEqArrayRefs );

# Make the test
sub pairedStudent {
    # Check arguments
    croak 'Must provide two arguments.'
        if @_ != 2;
    my $err = checkEqArrayRefs(@_);
    croak $err if $err;

    # Size
    my $N = @{$_[0]};

    # Statistics;
    my $sum1;
    my $sum2;
    my $sumDf;
    my $sumDfSq;

    # Get accumulated statistics
    for (my $i = 0; $i < $N; ++$i) {
        $sum1 += $_[0][$i];
        $sum2 += $_[1][$i];

        my $diff = $_[0][$i] - $_[1][$i];
        $sumDf   += $diff;
        $sumDfSq += $diff * $diff;
    }

    # Get estimator
    my $meanDf = $sumDf / $N;
    my $varDf  = ($sumDfSq - $sumDf * $sumDf / $N) / ($N - 1);
    my $samDev = sqrt($varDf / $N);
    my $t      = $meanDf / $samDev;

    # Save everything to the object
    my $this = {
        'N'  => $N,         'df' => $N - 1,
        'm1' => $sum1 / $N, 'm2' => $sum2 / $N,
        't'  => $t
    };
    return bless($this);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+-------------+-------------+----+
|   Mean 1    |   Mean 2    |   Student   | DF |
+-------------+-------------+-------------+----+
| % .4e | % .4e | % .4e | %2d |
+-------------+-------------+-------------+----+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'m1', 'm2', 't', 'df'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'t'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::pt($this->{'t'}, $this->{'df'}, 0, 0);
}

# Return true
1;
