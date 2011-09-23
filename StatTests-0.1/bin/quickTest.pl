use strict;

use FindBin qw( $RealBin );
use Getopt::Long;

use lib "$RealBin/../blib/arch";
use lib "$RealBin/../blib/lib";
use lib "$RealBin/../../Math-R-0.1/blib/arch";
use lib "$RealBin/../../Math-R-0.1/blib/lib";

# use StatTests::ANOVA;
use StatTests::BonferroniDunn;
use StatTests::Dunnett;
use StatTests::Friedman;
use StatTests::FriedmanF;
# use StatTests::Kappa;
use StatTests::Nemenyi;
use StatTests::PairedANOVA;
use StatTests::PairedStudent;
use StatTests::PairedWilcoxon;
use StatTests::PairedWilcoxonZ;
# use StatTests::Spearman;
# use StatTests::Student;
use StatTests::Tukey;
# use StatTests::Wilcoxon;

# Help string
our $helpString = << "EOF;";
Usage:
    $0 [options] <test> [arguments] < input

Available tests:
    ANOVA, Bonferroni-Dunn, Dunnet, Friedman, Friedman-F,
    Kappa, Spearman, Student, Tukey, Wilcoxon, Wilcoxon-Z

Options:
    --conf-th <value>
      Confidence threshold
      (Default is 0.05)

    --paired
    --nopaired
      Determines if the test is paired
      (Default is not)

    --silent
    --nosilent
      Only provides the statistic and the confidence level
      (Default is not, showing complete tables)

    --help
      Shows this help

EOF;

# Options
our $confTh = 0.05;
our $paired;
our $silent;
our $help;

# Get the options
if (!GetOptions("conf-th=f" => \$confTh,
		"paired!"   => \$paired,
		"silent!"   => \$silent,
		"help"      => \$help) ||
    $help || @ARGV < 1) {
    die $helpString;
}
our $test = lc(shift(@ARGV));

# Read data
my @data = $paired ? readPairedData() : readSingleData();

# Tests
my $testResult;
if ($test eq 'anova') {
    die "ANOVA test requires no arguments\n" if @ARGV != 0;
    $testResult = $paired ? pairedANOVA(@data) : ANOVA(@data);
    
} elsif ($test eq 'tukey') {
    die "Tukey test is for paired data\n" if !$paired;
    die "Must provide two columns\n" if @ARGV != 2;
    my $anova = pairedANOVA(@data);
    $testResult = tukey($anova, @ARGV);
    
    unless ($silent) {
	printf("%s\n", $anova->summary());
	printf("Confidence of the null hypothesis in ANOVA test: %f\n\n",
	       $anova->confidence());
    }

} elsif ($test eq 'dunnett') {
    die "Dunnet test is for paired data\n" if !$paired;
    die "Must provide two columns\n" if @ARGV != 2;
    my $anova = pairedANOVA(@data);
    $testResult = dunnett($anova, @ARGV);
    
    unless ($silent) {
	printf("%s\n", $anova->summary());
	printf("Confidence of the null hypothesis in ANOVA test: %f\n\n",
	       $anova->confidence());
    }

} elsif ($test eq 'friedman') {
    die "Friedman test is for paired data\n" if !$paired;
    die "Friedman test requires no arguments\n" if @ARGV != 0;
    $testResult = friedman(@data);
    
} elsif ($test eq 'friedman-f') {
    die "Friedman-F test is for paired data\n" if !$paired;
    die "Friedman-F test requires no arguments\n" if @ARGV != 0;
    my $friedman = friedman(@data);
    $testResult = friedmanF($friedman);

    unless ($silent) {
	printf("%s\n", $friedman->summary());
	printf("Confidence of the null hypothesis in Friedman test: %f\n\n",
	       $friedman->confidence());
    }
	
} elsif ($test eq 'bonferroni-dunn') {
    die "Bonferroni-Dunn test is for paired data\n" if !$paired;
    die "Must provide two columns\n" if @ARGV != 2;
    my $friedman = friedman(@data);
    $testResult = bonferroniDunn($friedman, @ARGV);
    
    unless ($silent) {
	printf("%s\n", $friedman->summary());
	printf("Confidence of the null hypothesis in Friedman test: %f\n\n",
	       $friedman->confidence());
    }

} elsif ($test eq 'nemenyi') {
    die "Nemenyi test is for paired data\n" if !$paired;
    die "Must provide two columns\n" if @ARGV != 2;
    my $friedman = friedman(@data);
    $testResult = nemenyi($friedman, @ARGV);
    
    unless ($silent) {
	printf("%s\n", $friedman->summary());
	printf("Confidence of the null hypothesis in Friedman test: %f\n\n",
	       $friedman->confidence());
    }

} elsif ($test eq 'student') {
    die "Student test requires no arguments" if @ARGV != 0;
    $testResult = $paired ? pairedStudent(@data) : student(@data);

} elsif ($test eq 'wilcoxon') {
    die "Wilcoxon test requires no arguments" if @ARGV != 0;
    $testResult = $paired ? pairedWilcoxon(@data) : wilcoxon(@data);

} elsif ($test eq 'wilcoxon-z') {
    die "Wilcoxon test requires no arguments" if @ARGV != 0;
    my $wilcox  = $paired ? pairedWilcoxon(@data)    : wilcoxon (@data);
    $testResult = $paired ? pairedWilcoxonZ($wilcox) : wilcoxonZ($wilcox);

    unless ($silent) {
	printf("%s\n", $wilcox->summary());
	printf("Confidence of the null hypothesis in Wilcoxon test: %f\n\n",
	       $wilcox->confidence());
    }

} else {
    die "Unimplemented test $test\n";
}

# Print summary and confidence
unless ($silent) {
    printf("%s\n", $testResult->summary());
    printf("Confidence of the null hypothesis: %f\n", $testResult->confidence());
} else {
    printf("%f %f\n", $testResult->statistic(), $testResult->confidence());
}

# Bye bye
exit(0);


# Read paired data
sub readPairedData {
    # Read the first line
    my $firstLine = <STDIN>;
    chomp($firstLine);
    my @F = split(' ', $firstLine);
    my $k = @F;
    my @result = map { [ $_ ] } @F;

    # Read the rest
    while (<STDIN>) {
	chomp();
	@F = split();
	die "All input fields must be of the same size\n"
	    if @F != $k;
	for (my $i = 0; $i < $k; ++$i) {
	    push(@{$result[$i]}, $F[$i]);
	}
    }

    # Return the result
    return @result;
}

# Read single data
sub readSingleData {
}
    

