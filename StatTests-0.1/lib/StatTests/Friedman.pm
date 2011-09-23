use strict;
use warnings;

use Exporter;

use Math::R;

# Friedman non-parametrical for paired samples
# Includes tied pair correction from p.140 of
#   M. Hollander, D. Wolfe
#   "Nonparametric Statistical Methods"
#   John Wiley and Sons, 1973
package StatTests::Friedman;

our @ISA = qw( Exporter );
our @EXPORT = qw( friedman );

use Carp qw( croak );
use StatTests::Utilities qw( checkEqArrayRefs );

# Make the test
sub friedman {
    # Check arguments
    croak 'Must provide at least two arguments.'
	if @_ < 2;
    my $err = checkEqArrayRefs(@_);
    croak $err if $err;
    
    # Sizes
    my $k = @_;
    my $N = @{$_[0]};
    
    # Stats
    my $tieCorr = 0.0;

    # Average ranks
    my @avgRank = ( 0.0 ) x $k;

    # Each data
    for (my $d = 0; $d < $N; ++$d) {
	# Find ranks
	my $i = 0;
	my @list   = map  { [ $i++, $_[$_][$d] ] } (0..$k-1);
	my @sorted = sort { $a->[1] <=> $b->[1]  } @list;
	my @ranks;
	$i = 0;
	while ($i < @sorted) {
	    # End of range
	    my $j = $i + 1;
	    ++$j while $j < @sorted && $sorted[$j][1] == $sorted[$i][1];

	    # Average rank
	    my $rank = ($i + $j + 1) / 2;
	    for (my $l = $i; $l < $j; ++$l) {
		$ranks[$sorted[$l][0]] = $rank;
	    }

	    # Tie correction term
	    my $sz = $j - $i;
	    $tieCorr += $sz * ($sz * $sz - 1);

	    # Next
	    $i = $j;
	}

	# Update
	for (my $i = 0; $i < @ranks; ++$i) {
	    $avgRank[$i] += $ranks[$i];
	}
    }

    # Finish rank average and chiSq numeration
    my $meanRank = $N * ($k + 1) / 2.0;
    my $chiSqNum = 0.0;
    foreach my $r (@avgRank) {
	$chiSqNum += ($r - $meanRank) * ($r - $meanRank);
	$r        /= $N;
    }

    # ChiSq Test
    my $chiSq = (12 * $chiSqNum) / ($N * $k * ($k + 1) - $tieCorr / ($k - 1));
    my $df    = $k - 1;

    # Save everything to the object
    my $this = {
	'k' => $k, 'N' => $N,
	'chiSq' => $chiSq, 'df' => $df,
	'avgRank' => \@avgRank
    };
    return bless($this);
}

# Table format
our $tableFormat = << 'EOF;';
+-------------+------+----+---------+
|    ChiSq    |  DF  |  k |    N    |
+-------------+------+----+---------+
| % .4e | %4d | %2d | %7d |
+-------------+------+----+---------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
		   @{$this}{'chiSq', 'df', 'k', 'N'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'chiSq'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::pchisq($this->{'chiSq'}, $this->{'df'}, 0, 0);
}

# Return true
1;
    
    

