use strict;

use Exporter;

use Math::R;

# Two-way ANOVA test
package StatTests::PairedANOVA;

our @ISA = qw( Exporter );
our @EXPORT = qw( pairedANOVA );

use Carp qw( croak );
use StatTests::Utilities qw( checkEqArrayRefs );

# Make the test
sub pairedANOVA {
    # Check arguments
    croak 'Must provide at least two arguments.'
        if @_ < 2;
    my $err = checkEqArrayRefs(@_);
    croak $err if $err;

    # Sizes
    my $k = @_;
    my $N = @{$_[0]};

    # Stats
    my @sum;
    my @sumSq;
    my $sumSbj;

    # Each data
    for (my $i = 0; $i < $N; ++$i) {
        # Subject sum
        my $sbj;

        # Update
        for (my $j = 0; $j < $k; ++$j) {
            $sum  [$j] += $_[$j][$i];
            $sumSq[$j] += $_[$j][$i] * $_[$j][$i];
            $sbj       += $_[$j][$i];
        }
        $sumSbj += $sbj * $sbj;
    }

    # Now find sums of squares
    my $ssWg;
    my $sumT;
    my $sumSqT;
    for (my $i = 0; $i < $k; ++$i) {
        $sumT   += $sum  [$i];
        $sumSqT += $sumSq[$i];
        $ssWg   += $sumSq[$i] - $sum[$i] * $sum[$i] / $N;
    }
    my $ssT = $sumSqT - $sumT * $sumT / ($k * $N);

    # Between-groups, subject and error
    my $ssBg   = $ssT - $ssWg;
    my $ssSbj  = $sumSbj / $k - $sumT * $sumT / ($k * $N);
    my $ssErr  = $ssWg - $ssSbj;

    # Degrees of freedom
    my $dfT    = $k * $N - 1;
    my $dfBg   = $k - 1;
    my $dfWg   = $k * $N - $k;
    my $dfSbj  = $N - 1;
    my $dfErr  = $dfWg - $dfSbj;

    # MSs
    my $msBg  = $ssBg  / $dfBg;
    my $msErr = $ssErr / $dfErr;
    my $F     = $msBg / $msErr;

    # Save everything to the object
    my $this = {
        'k'      => $k,     'N' => $N,
        'ssT'    => $ssT,   'dfT'   => $dfT,
        'ssBg'   => $ssBg,  'dfBg'  => $dfBg,  'msBg'  => $msBg,
        'ssWg'   => $ssWg,  'dfWg'  => $dfWg,
        'ssSbj'  => $ssSbj, 'dfSbj' => $dfSbj,
        'ssErr'  => $ssErr, 'dfErr' => $dfErr, 'msErr' => $msErr,
        'F'      => $F,

        'sum'    => \@sum
    };
    return bless($this);
}

# Table format
our $tableFormat = << 'EOF;';
         +-------------+------+-------------+-------------+
         |     SS      |  DF  |     MS      |      F      |
+--------+-------------+------+-------------+-------------+
| Total  | % .4e | %4d | % .4e | % .4e |
+--------+-------------+------+-------------+-------------+
| B.G.   | % .4e | %4d | % .4e |
+--------+-------------+------+-------------+
| W.G.   | % .4e | %4d |
+--------+-------------+------+
| *Subj  | % .4e | %4d |
+--------+-------------+------+-------------+
| *Err   | % .4e | %4d | % .4e |
+--------+-------------+------+-------------+
| k = %2d | N = %7d |
+--------+-------------+
EOF;

# Give a summary string
sub summary {
    my ($this) = @_;
    return sprintf($tableFormat,
                   @{$this}{'ssT',   'dfT',   'msT', 'F',
                            'ssBg',  'dfBg',  'msBg',
                            'ssWg',  'dfWg',
                            'ssSbj', 'dfSbj',
                            'ssErr', 'dfErr', 'msErr',
                            'k', 'N'});
}

# The statistic
sub statistic {
    my ($this) = @_;
    return $this->{'F'};
}

# Confidence of the null hypothesis
sub confidence {
    my ($this) = @_;
    return Math::R::pf($this->{'F'}, $this->{'dfBg'},
                       $this->{'dfErr'}, 0, 0);
}

# Return true
1;
