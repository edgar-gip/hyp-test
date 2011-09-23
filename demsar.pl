# Demsar-style plots
# @see Janez Demsar
#      "Statistical Comparisons of Classifiers over Multiple Data Sets"
#      Journal of Machine Learning Research, 7, pp. 1--30, 2006
# @see Salvador García, Francisco Herrera
#      "An Extension on 'Statistical Comparisons of Classifiers over
#       Multiple Data Sets' for All Pairwise Comparisons"
#      Journal of Machine Learning Research, 9, pp. 2677--2694, 2008

use strict;
use warnings;

use FindBin qw( $RealBin );
use Getopt::Long qw( :config no_ignore_case bundling );

use lib "$RealBin/Math-R-0.1/blib/arch";
use lib "$RealBin/Math-R-0.1/blib/lib";
use Math::R;

use lib "$RealBin/StatTests-0.1/blib/lib";
use StatTests::Friedman;

use lib "$RealBin/XFig-0.1/blib/arch";
use lib "$RealBin/XFig-0.1/blib/lib";
use XFig qw( :area :b_area :color :just :psfonts );

use lib "$RealBin/See-0.1/blib/lib";
use enum qw( BergmannHommel BonferroniDunn Hochberg Holm Nemenyi
             Schaffer );

# Math::R functions:
# double qtukey(double p, double n_ranges, double n_means,
#               double df, int lower_tail, int log_p);
# double qnorm(double p, double mu, double sigma,
#              int lower_tail, int log_p)

# Nemenyi alphas
# -> Equal to qtukey(alpha, k, inf) / sqrt(2)

# Bonferroni-Dunn alphas
# -> Equal to qnorm(1.0 - (alpha_2 / (k - 1)))

# Options
my $against  = undef;
my $alpha    = 0.10;
my $extended = undef;
my $named    = undef;
my $reverse  = undef;
my $test     = Nemenyi;
my $testData = undef;
my $title    = undef;
my $verbose  = undef;

# Help string
my $helpString = << "EOH;";
Usage:
    $0 [options] <data>

Options:
    --bergmann / --hommel
    --bonferroni / --dunn
    --hochberg
    --holm
    --nemenyi
    --schaffer
      Sets the test to be applied
      (Default is Nemenyi)

    --against <s>
    --all
      Sets a single method to make the comparison, or all-vs-all
      (Default is all-vs-all)

    --alpha <f>
      Sets the test significance level
      (Default is 0.10)

    --extended
    --no-extended
      Use extended text processing (symbols)
      (Default is not)

    --named
    --no-named
      Specifies if row names are included as first field in the input
      (Default is not)

    --reverse
    --no-reverse
      Sets the reversal of the scale (Highest values first)
      (Default is not)

    --title <s>
      Sets the title for the plot
      (Default is none)

    --verbose
    --no-verbose
      Sets the verbosity mode
      (Default is not)

EOH;

# XFig file
my $xfig;


#########
# Input #
#########

# Read the column names
sub readColumnNames {
    my ($fin) = @_;

    my $firstLine = <$fin>;
    chomp($firstLine);
    return split(' ', $firstLine);
}

# Find the index
sub findIndex($\@) {
    my ($w, $array) = @_;
    my $i = 0;
    while ($i < @{$array}) {
	return $i if $array->[$i] eq $w;
	++$i;
    }
    return undef;
}

# Read the data
sub readPairedData {
    my ($fin) = @_;

    # Read the first line
    my $firstLine = <$fin>;
    chomp($firstLine);
    my @F = split(' ', $firstLine);
    shift(@F) if $named;
    my $k = @F;
    my @result = map { [ $_ ] } @F;

    # Read the rest
    while (<$fin>) {
	chomp();
	@F = split();
	shift(@F) if $named;
	die "All input fields must be of the same size\n"
	    if @F != $k;
	for (my $i = 0; $i < $k; ++$i) {
	    push(@{$result[$i]}, $F[$i]);
	}
    }

    # Return the result
    return @result;
}


########
# Bars #
########

# Critical difference bars
sub criticalDifferenceBars($\@\@\@;$) {
    my ($cd, $ranks, $order, $names, $againstOrder) = @_;

    # Output
    my @bars;

    # Is there an against column?
    if ($againstOrder) {
	# One-vs-all

	# Against rank
	my $againstRank = $ranks->[$order->[$againstOrder]];

	# Find the low point
	my $lo = $againstOrder;
	--$lo while $lo > 0 &&
	            $ranks->[$order->[$lo - 1]] - $againstRank < $cd;

	# Verbose log
	printf STDERR (" %s == %s: %g - %g = %g < %g\n",
		       @{$names}[@{$order}[$lo, $againstOrder]],
		       $ranks->[$order->[$lo]], $againstRank,
		       $ranks->[$order->[$lo]] - $againstRank, $cd)
	    if $verbose;

	# Find the high point
	my $hi = $againstOrder;
	++$hi while $hi < $#{$order} &&
	            $againstRank - $ranks->[$order->[$hi + 1]] < $cd;

	# Verbose log
	printf STDERR (" %s == %s: %g - %g = %g < %g\n",
		       @{$names}[@{$order}[$againstOrder, $hi]],
		       $againstRank, $ranks->[$order->[$hi]],
		       $againstRank - $ranks->[$order->[$hi]], $cd)
	    if $verbose;

	# Add it as a single bar
	push(@bars, [ $lo, $hi, undef ]);
    }
    else {
	# All-vs-all

	# Try all pairs
	for (my $i = 0; $i < @{$order}; ++$i) {
	    for (my $j = $i + 1; $j < @{$order}; ++$j) {
		# If difference is lower than CD
		if ($ranks->[$order->[$i]] - $ranks->[$order->[$j]] < $cd) {
		    # Add
		    push(@bars, [ $i, $j, undef ]);

		    # Verbose log
		    printf STDERR (" %s == %s: %g - %g = %g < %g\n",
				   @{$names}[@{$order}[$i, $j]],
				   @{$ranks}[@{$order}[$i, $j]],
				   $ranks->[$order->[$i]] -
				   $ranks->[$order->[$j]], $cd)
			if $verbose;
		}
		else {
		    # Verbose log
		    printf STDERR (" %s != %s: %g - %g = %g > %g\n",
				   @{$names}[@{$order}[$i, $j]],
				   @{$ranks}[@{$order}[$i, $j]],
				   $ranks->[$order->[$i]] -
				   $ranks->[$order->[$j]], $cd)
			if $verbose;
		}
	    }
	}
    }

    # Return the bars
    return @bars;
}

# All normal bars
sub allNormBars($\@\@\@;$) {
    my ($stddev, $ranks, $order, $names, $againstOrder) = @_;

    # Verbose log
    print STDERR ("Individuals\n") if $verbose;

    # Output
    my @bars;

    # Is there an against column?
    if ($againstOrder) {
	# One-vs-all

	# Against rank
	my $againstRank = $ranks->[$order->[$againstOrder]];

	# Lower
	for (my $i = 0; $i < $againstRank; ++$i) {
	    my $z = ($ranks->[$order->[$i]] - $againstRank) / $stddev;
	    my $p = 2.0 * Math::R::pnorm($z, 0.0, 1.0, 0, 0);
	    push(@bars, [ $i, $againstOrder, $p ]);

	    # Verbose log
	    printf STDERR (" %s <-> %s: %g - %g = %g -> %g -> %g\n",
			   @{$names}[@{$order}[$i, $againstOrder]],
			   $ranks->[$order->[$i]], $againstRank,
			   $ranks->[$order->[$i]] - $againstRank,
			   $z, $p) if $verbose;
	}

	# Upper
	for (my $j = $againstRank + 1; $j < @{$order}; ++$j) {
	    my $z = ($againstRank - $ranks->[$order->[$j]]) / $stddev;
	    my $p = 2.0 * Math::R::pnorm($z, 0.0, 1.0, 0, 0);
	    push(@bars, [ $againstOrder, $j, $p ]);

	    # Verbose log
	    printf STDERR (" %s <-> %s: %g - %g = %g -> %g -> %g\n",
			   @{$names}[@{$order}[$againstOrder, $j]],
			   $againstRank, $ranks->[$order->[$j]],
			   $againstRank - $ranks->[$order->[$j]],
			   $z, $p) if $verbose;
	}
    }
    else {
	# All-vs-all

	# Try all pairs
	for (my $i = 0; $i < @{$order}; ++$i) {
	    for (my $j = $i + 1; $j < @{$order}; ++$j) {
		my $z = ($ranks->[$order->[$i]] - $ranks->[$order->[$j]]) /
		        $stddev;
		my $p = 2.0 * Math::R::pnorm($z, 0.0, 1.0, 0, 0);
		push(@bars, [ $i, $j, $p ]);

		# Verbose log
		printf STDERR (" %s <-> %s: %g - %g = %g -> %g -> %g\n",
			       @{$names}[@{$order}[$i, $j]],
			       @{$ranks}[@{$order}[$i, $j]],
			       $ranks->[$order->[$i]] -
			       $ranks->[$order->[$j]], $z, $p) if $verbose;
	    }
	}
    }

    # Return the bars
    return @bars;
}

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
sub bhExhaustiveSets {
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

		    my @E1 = bhExhaustiveSets($c1);
		    my @E2 = bhExhaustiveSets($c2);

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

# Bergmann-Hommel test
sub bergmannHommelBars($\@\@\@) {
    my ($k, $bars, $order, $names) = @_;

    # Verbose log
    print STDERR ("Bergmann-Hommel\n") if $verbose;

    # Obtain the exhaustive sets
    my @exSets = bhExhaustiveSets([ 0 .. $k - 1 ]);

    # Index p-Values
    my %pValue;
    $pValue{$_->[0] . ',' . $_->[1]} = $_->[2] foreach @{$bars};

    # Acceptance set
    my %acceptance;

    # Check each exhaustive set
    foreach my $set (@exSets) {
	# Threshold
	my $th = $alpha / @{$set};

	# Accepted?
	my $accepted = 1;
	foreach my $pair (@{$set}) {
	    # Below threshold?
	    if ($pValue{$pair} <= $th) {
		# Reject!
		$accepted = undef;

		# Verbose log
		if ($verbose) {
		    my $npair = $pair;
		    $npair =~ s/(\d+)/$names->[$1]/g;
		    printf STDERR (" { %s } -> %s: p(%s) = %g < %g / %d = %g\n",
				   join(' ', @{$set}), $npair, $pair,
				   $pValue{$pair}, $alpha, scalar(@{$set}),
				   $th);
		}

		# End
		last;
	    }
	}

	# Was it accepted after all?
	if ($accepted) {
	    # Verbose log
	    printf STDERR (" { %s } -> Accepted!\n", join(' ', @{$set}))
		if $verbose;

	    # Add each pair
	    $acceptance{$_} = 1 foreach @{$set};
	}

    }

    # Keep only those pairs not in the acceptance set
    foreach my $bar (@{$bars}) {
	$bar = undef if !$acceptance{$bar->[0] . ',' . $bar->[1]};
    }

    # Keep only those not rejected
    @{$bars} = grep { defined($_) } @{$bars};
}

# Hochberg test
sub hochbergBars(\@\@\@) {
    my ($bars, $order, $names) = @_;

    # Verbose log
    print STDERR ("Hochberg\n");

    # Sort bars by p-value (large to small)
    my @bOrder = sort { $bars->[$b][2] <=> $bars->[$a][2] } (0..$#{$bars});

    # Now, accept until the value is smaller
    my $m_i = 1;
    while (@bOrder) {
	my $i = shift(@bOrder);

	# Is p-value less than \alpha / (m - i)
	if ($bars->[$i][2] <= $alpha / $m_i) {
	    # Reject
	    $bars->[$i] = undef;

	    # Verbose log
	    printf STDERR (" %s != %s: %g < %g / %d = %g -> BREAK!\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $m_i,
			   $alpha / $m_i) if $verbose;

	    # End
	    last;
	}
	else {
	    # Verbose log
	    printf STDERR (" %s == %s: %g < %g / %d = %g\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $m_i,
			   $alpha / $m_i) if $verbose;

	    # One more pair
	    ++$m_i;
	}
    }

    # For those which remain
    foreach my $i (@bOrder) {
	# Update m_i
	++$m_i;

	# Reject
	$bars->[$i] = undef;

	# Log
	printf STDERR (" %s == %s: %g < %g / %d = %g\n",
		       $names->[$order->[$bars->[$i][0]]],
		       $names->[$order->[$bars->[$i][1]]],
		       $bars->[$i][2], $alpha, $m_i,
		       $alpha / $m_i) if $verbose;
    }

    # Keep only those not rejected
    @{$bars} = grep { defined($_) } @{$bars};
}

# Holm test
sub holmBars(\@\@\@) {
    my ($bars, $order, $names) = @_;

    # Verbose log
    print STDERR ("Holm\n");

    # Sort bars by p-value (small to large)
    my @bOrder = sort { $bars->[$a][2] <=> $bars->[$b][2] } (0..$#{$bars});

    # Now, reject until the value is larger
    my $m_i = @{$bars};
    while (@bOrder) {
	my $i = shift(@bOrder);

	# Is p-value more than \alpha / (m - i)
	if ($bars->[$i][2] > $alpha / $m_i) {
	    # Verbose log
	    printf STDERR (" %s == %s: %g < %g / %d = %g --> BREAK!\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $m_i,
			   $alpha / $m_i) if $verbose;

	    # End
	    last;
	}
	else {
	    # Verbose log
	    printf STDERR (" %s != %s: %g < %g / %d = %g\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $m_i,
			   $alpha / $m_i) if $verbose;

	    # Reject
	    $bars->[$i] = undef;

	    # One less pair
	    --$m_i;
	}
    }

    # Verbose log
    if ($verbose) {
	# For those which remain
	foreach my $i (@bOrder) {
	    # Update m_i
	    --$m_i;

	    # Log
	    printf STDERR (" %s == %s: %g < %g / %d = %g\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $m_i,
			   $alpha / $m_i);
	}
    }

    # Keep only those not rejected
    @{$bars} = grep { defined($_) } @{$bars};
}

# Schaffer (Static) test
sub schafferBars($\@\@\@) {
    my ($k, $bars, $order, $names) = @_;

    # Verbose log
    print STDERR ("Schaffer\n") if $verbose;

    # Find the number of simultaneous true hypothesis
    my @S = ([ 0 ], [ 0 ]);
    for (my $i = 2; $i <= $k; ++$i) {
	# Value \{ \comb{1}{2} + x | x \in S(k - 1) \} = \{ x \in S(k - 1) \}
	my %vals = map { $_ => 1 } @{$S[$i - 1]};

	# Add \Cup_{j=2}^k \{ \comb{j}{2} + x | x \in S(k - j) \}
	for (my $j = 2; $j <= $i; ++$j) {
	    my $term = $j * ($j - 1) / 2;
	    $vals{$term + $_} = 1 foreach @{$S[$i - $j]};
	}

	# Find them
	my @vals = sort { $a <=> $b } keys(%vals);

	# Verbose log
	printf STDERR (" S[%d] = { %s }\n", $i, join(', ', @vals)) if $verbose;

	# Add it
	push(@S, \@vals);
    }

    # Index
    my %S     = map { map { $_ => 1 } @{$_} } @S;
    my @sortS = sort { $a <=> $b } keys(%S);

    # Preparation is done, now, for the actual test...

    # Sort bars by p-value (small to large)
    my @bOrder = sort { $bars->[$a][2] <=> $bars->[$b][2] } (0..$#{$bars});

    # Now, reject until the value is larger
    my $m_i  = @{$bars};
    my $posS = $#sortS;
    my $t_i  = $sortS[$posS];
    while (@bOrder) {
	my $i = shift(@bOrder);

	# Is p-value more than \alpha / t_i
	if ($bars->[$i][2] > $alpha / $t_i) {
	    # Verbose log
	    printf STDERR (" %s == %s: %g < %g / %d = %g -> BREAK!\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $t_i,
			   $alpha / $t_i) if $verbose;

	    # End
	    last;
	}
	else {
	    # Verbose log
	    printf STDERR (" %s != %s: %g < %g / %d = %g\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $t_i,
			   $alpha / $t_i) if $verbose;

	    # Reject
	    $bars->[$i] = undef;

	    # Update t_i
	    $t_i = $sortS[--$posS] if $t_i > --$m_i;
	}
    }

    # Verbose log
    if ($verbose) {
	# For those which remain
	foreach my $i (@bOrder) {
	    # Update t_i
	    $t_i = $sortS[--$posS] if $t_i > --$m_i;

	    # Log
	    printf STDERR (" %s == %s: %g < %g / %d = %g\n",
			   $names->[$order->[$bars->[$i][0]]],
			   $names->[$order->[$bars->[$i][1]]],
			   $bars->[$i][2], $alpha, $t_i,
			   $alpha / $t_i);
	}
    }

    # Keep only those not rejected
    @{$bars} = grep { defined($_) } @{$bars};
}


###############
# XFig Output #
###############

# Write the header
sub writeHeader {
    my $display = $ENV{'DISPLAY'} || ':0';
    XFig::openDisplay($display);
    $xfig = new XFig('-');
    $xfig->fill(C_BLACK);
}
# Draw a black line
sub blackLine($@) {
    $xfig->thick(shift(@_));
    $xfig->drawLine(@_);
}

# Draw a black box
sub blackBox($$$$) {
    $xfig->area(BA_BLACK);
    $xfig->drawBox(@_);
    $xfig->area(A_NOT_FILLED);
}

#  Write black text
sub blackText($$$$) {
    if ($_[0] == JT_CENTER || !$extended) {
	# No extended processing
	$xfig->justify(shift(@_));
	$xfig->drawText(@_);
    }
    else {
	# Extended
	my ($just, $x, $y, $text) = @_;

	# Set justification
	$xfig->justify($just);

	# Parts
	my ($prefix, $symbols, $suffix);

	# Match
	if ($just == JT_LEFT) {
	    ($prefix, $symbols, $suffix) = $text =~ /^(.*?)(\\s\d+)+ ?(.*)$/;
	}
	else { # $just == JT_RIGHT
	    ($suffix, $symbols, $prefix) = $text =~ /^(.*)(\\s\d+)+ ?(.*)$/;
	}

	# Some remains?
	while (defined($prefix)) {
	    # Write the prefix
	    $xfig->drawText($x, $y, $prefix) if $prefix;

	    # Which size?
	    my ($width, $ascent, $descent) = $xfig->textSize($prefix);

	    # Update x
	    if ($just == JT_LEFT) {
		$x += $width;
	    }
	    else { # $just == JT_RIGHT
		$x -= $width;
	    }

	    # Now, change to symbol
	    $xfig->psFont(PS_SYMBOL);

	    # Convert the symbols to a text
	    my $stext =
		join('', map { chr(oct($_)) } ($symbols =~ /\\s(\d+)/g));

	    # Write it
	    $xfig->drawText($x, $y, $stext);

	    # Which size?
	    ($width, $ascent, $descent) = $xfig->textSize($stext);

	    # Update x
	    if ($just == JT_LEFT) {
		$x += $width;
	    }
	    else { # $just == JT_RIGHT
		$x -= $width;
	    }

	    # Back to default
	    $xfig->psFont(PS_DEFAULT);

	    # Set the suffix
	    $text = $suffix;

	    # Next match
	    if ($just == JT_LEFT) {
		($prefix, $symbols, $suffix) =
		    $text =~ /^(.*?)(\\s\d+)+ ?(.*)$/;
	    }
	    else { # $just == JT_RIGHT
		($suffix, $symbols, $prefix) =
		    $text =~ /^(.*)(\\s\d+)+ ?(.*)$/;
	    }
	}

	# Last one
	$xfig->drawText($x, $y, $text) if $text;
    }
}

# Draw the CD line
sub drawCD($) {
    my ($cd) = @_;

    blackLine(2, 500, 500, 500 + int(1000 * $cd), 500);
    blackLine(2, 500, 400, 500, 600);
    blackLine(2, 500 + int(1000 * $cd), 400, 500 + int(1000 * $cd), 600);
    blackText(JT_CENTER, 500 + int(500 * $cd), 350, 'CD');
}

# Draw the scale
sub drawScale($) {
    my ($k) = @_;

    blackLine(2, 500, 1000, int(1000 * $k) - 500, 1000);
    for (my $i = 0; $i < $k - 1; ++$i) {
	blackLine(2, 500 + int(1000 * $i),  900,  500 + int(1000 * $i), 1100);
	blackLine(2, 1000 + int(1000 * $i), 900, 1000 + int(1000 * $i), 1000);
	blackText(JT_CENTER, 500 + int(1000 * $i), 825, $k - $i);
    }
    blackLine(2, int(1000 * $k) - 500, 900, int(1000 * $k) - 500, 1100);
    blackText(JT_CENTER, int(1000 * $k) - 500, 825, 1);
}

# Draw the title
sub drawTitle($$) {
    my ($k, $title) = @_;

    blackText(JT_CENTER, 500 * $k, 350, $title);
}

# Assign depth
sub assignDepth {
    my (@bars) = @_;

    my $barDepth = 1;
    my @depths;
    foreach my $bar (@bars) {
	my $d = 0;
	++$d while $d < @depths && $depths[$d] >= $bar->[0];
	push(@{$bar}, $d);
	$depths[$d] = $bar->[1];
	$barDepth = $d + 1 if $d >= $barDepth;
    }
    return $barDepth;
}

# Draw the bars
sub drawBars($\@\@\@) {
    my ($k, $order, $rank, $bars) = @_;

    foreach my $bar (@{$bars}) {
	my ($a, $b, $p, $d) = @{$bar};
	my $xa = 500 + int(1000 * ($k - $rank->[$order->[$a]]));
	my $xb = 500 + int(1000 * ($k - $rank->[$order->[$b]]));
	my $y  = 1200 + 150 * $d;
	blackBox($xa - 25, $y, $xb + 25, $y + 75);
    }
}

# Draw a single bar
sub drawBar($$$) {
    my ($k, $rank, $cd) = @_;

    my $a = $k - $rank - $cd;
    $a = 0 if $a < 0;
    my $b = $k - $rank + $cd;
    $b = $k if $b > $k;

    blackBox(500 + int(1000 * $a), 1200, 500 + int(1000 * $b), 1275);
}

# Draw the names
sub drawNames($$\@\@\@) {
    my ($k, $nbars, $order, $rank, $names) = @_;

    my $half = @{$order} >> 1;
    my $y    = 1300 + 150 * $nbars;
    for (my $i = 0; $i < $half; ++$i) {
	my $x = 500 + int(1000 * ($k - $rank->[$order->[$i]]));
	blackLine(1, $x, 1000, $x, $y, $x - 100, $y);
	blackText(JT_RIGHT, $x - 150, $y + 65, $names->[$order->[$i]]);
	$y += 200
    }

    $y -= 200 if !(@{$order} & 1);
    for (my $i = $half; $i < @{$order}; ++$i) {
	my $x = 500 + int(1000 * ($k - $rank->[$order->[$i]]));
	blackLine(1, $x, 1000, $x, $y, $x + 100, $y);
	blackText(JT_LEFT, $x + 150, $y + 65, $names->[$order->[$i]]);
	$y -= 200
    }
}


########
# Main #
########

# Get the options
if (!GetOptions("a|alpha=f"    => \$alpha,
		"B|bergmann"   => sub { $test = BergmannHommel },
		"b|bonferroni" => sub { $test = BonferroniDunn },
		"c|hochberg"   => sub { $test = Hochberg },
		"d|dunn"       => sub { $test = BonferroniDunn },
		"e|extended!"  => \$extended,
		"h|holm"       => sub { $test = Holm },
		"H|hommel"     => sub { $test = BergmannHommel },
		"l|all"        => sub { $against = undef },
		"n|nemenyi"    => sub { $test = Nemenyi },
		"N|named!"     => \$named,
		"r|reverse!"   => \$reverse,
		"s|schaffer"   => sub { $test = Schaffer },
		"t|title=s"    => \$title,
		"T|test!"      => \$testData,
		"v|verbose!"   => \$verbose,
		"x|against=s"  => \$against)) {
    die $helpString;
}

# Read data
$named = 1 if $testData;
my @names = readColumnNames($testData ? \*DATA : \*ARGV);
my @data  = readPairedData ($testData ? \*DATA : \*ARGV);

# Write the Header
writeHeader();

# Apply the test and find information
my $friedman = friedman(@data);
my ($k, $N)  = @{$friedman}{'k', 'N'};
my $stddev   = sqrt($k * ($k + 1) / 6 / $N);

# Verbose log
printf STDERR ("Friedman\n k:%d N:%d chi2:%g stdev:%g\n",
	       $k, $N, $friedman->{'chiSq'}, $stddev) if $verbose;

# Draw the scale and title
drawScale($k);
drawTitle($k, $title) if $title;

# Find the ranks
my @ranks = @{$friedman->{'avgRank'}};
map { $_ = ($k + 1) - $_ } @ranks if $reverse;
my @order = sort { $ranks[$b] <=> $ranks[$a] } (0..$#ranks);

# Against column info
my ($againstIndex, $againstOrder);
if (defined($against)) {
    $againstIndex = findIndex($against, @names);
    $againstOrder = 0;
    ++$againstOrder while $againstOrder < @order &&
	                  $order[$againstOrder] != $againstIndex;
}

# Find the bars
my @bars;

# Which kind of test?
if ($test == BonferroniDunn) {
    # Bonferroni-Dunn

    # Find the critical difference
    my $qalpha = defined($against) ?
	Math::R::qnorm(1.0 - $alpha / 2.0 / ($k - 1), 0, 1, 1, 0) : # One-vs-All
	Math::R::qnorm(1.0 - $alpha / $k  / ($k - 1), 0, 1, 1, 0);  # All-vs-All
    my $cd     = $qalpha * $stddev;
    drawCD($cd);

    # Verbose log
    printf STDERR ("Bonferroni-Dunn\n alpha':%g qAlpha':%g CD:%g\n",
		   defined($against) ?
		   $alpha / ($k - 1) : 2.0 * $alpha / $k  / ($k - 1),
		   $qalpha, $cd)
	if $verbose;

    # Critical difference bar
    @bars = criticalDifferenceBars($cd, @ranks, @order, @names, $againstOrder);
}
elsif ($test == Nemenyi) {
    # Perform a Nemenyi test

    # Used for One-vs-All
    warn "Nemenyi test loses power in One-vs-All comparisons\n"
	if defined($against);

    # Find the critical difference
    my $qalpha = Math::R::qtukey(1.0 - $alpha, 1.0, $k, 'inf', 1, 0) / sqrt(2);
    my $cd     = $qalpha * $stddev;
    drawCD($cd);

    # Verbose log
    printf STDERR ("Nemenyi\n qAlpha:%g CD:%g\n", $qalpha, $cd)
	if $verbose;

    # Critical difference bars
    @bars = criticalDifferenceBars($cd, @ranks, @order, @names, $againstOrder);
}
else {
    # Other tests

    # Find all bars (with normal confidence)
    @bars = allNormBars($stddev, @ranks, @order, @names, $againstOrder);

    # Apply the suitable test
    if ($test == BergmannHommel) {
	# One-vs-all?
	if (defined($against)) {
	    # Error
	    die "Bermann-Hommel test is unimplemented for One-vs-All " .
		"comparisons\n";
	}
	else {
	    # Bermann-Hommel test
	    bergmannHommelBars($k, @bars, @order, @names);
	}
    }
    elsif ($test == Hochberg) {
	# Hochber test
	hochbergBars(@bars, @order, @names);
    }
    elsif ($test == Holm) {
	# Holm test
	holmBars(@bars, @order, @names);
    }
    elsif ($test == Schaffer) {
	# One-vs-all?
	if (defined($against)) {
	    # Equivalent to Holm
	    warn "Schaffer test is equivalent to Holm test in One-vs-All " .
		 "comparisons\n";
	    holmBars(@bars, @order, @names);
	}
	else {
	    # Schaffer test
	    schafferBars($k, @bars, @order, @names);
	}
    }
    else {
	# Error
	die "Unhandled test #$test\n";
    }
}

# Purge the bars!!
my $i = 0;
while ($i < @bars) {
    my $j = $i + 1;
    while ($j < @bars) {
	if      ($bars[$i][0] >= $bars[$j][0] &&
		 $bars[$i][1] <= $bars[$j][1]) {
	    $bars[$i] = $bars[$j];
	    splice(@bars, $j, 1);
	} elsif ($bars[$j][0] >= $bars[$i][0] &&
		 $bars[$j][1] <= $bars[$i][1]) {
	    splice(@bars, $j, 1);
	} else {
	    ++$j;
	}
    }
    ++$i;
}

# Assign depth
my $barDepth = assignDepth(@bars);

# Draw names
drawNames($k, $barDepth, @order, @ranks, @names);

# Draw the bars
drawBars($k, @order, @ranks, @bars);

# Test data (García & Herrera, 2008)
__DATA__
    C4.5 1-NN Bays Krnl CN2
Aba .219 .202 .249 .165 .261
Adu .803 .750 .813 .692 .798
Aus .859 .814 .845 .542 .816
Aut .809 .774 .673 .275 .785
Bal .768 .790 .727 .872 .706
Bre .759 .654 .734 .703 .714
Bup .693 .611 .572 .689 .572
Car .915 .857 .860 .700 .777
Cle .544 .531 .558 .439 .541
Crx .855 .796 .857 .607 .809
Der .945 .954 .978 .541 .858
Ger .725 .705 .739 .625 .717
Gla .674 .736 .721 .356 .704
HRo .801 .357 .520 .309 .520
Hea .785 .770 .841 .659 .759
Ion .906 .359 .895 .641 .918
L7D .710 .402 .728 .120 .674
Let .691 .827 .667 .527 .638
Lym .743 .739 .830 .549 .746
Mus .990 .482 .941 .857 .990
ODi .867 .098 .915 .986 .784
Sat .821 .872 .815 .885 .778
SBa .893 .824 .902 .739 .885
Spl .799 .655 .925 .517 .755
TTT .845 .731 .693 .653 .704
Veh .741 .701 .591 .663 .619
Vow .799 .994 .603 .269 .621
Win .949 .955 .989 .770 .954
Yea .555 .505 .569 .312 .556
Zoo .928 .928 .945 .419 .897
