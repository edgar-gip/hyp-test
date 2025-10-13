# -*- mode:perl; -*-

use strict;
use warnings;

use Test::More tests => 10;

# sub display {
#     my ($label, $hc, $hp) = @_;

#     print STDERR ("$label\n");
#     for (my $i = 0; $i < @{$hc} || $i < @{$hp}; ++$i) {
#       printf STDERR ("\t%40s | %40s\n",
#                      join(" ", @{$hc->[$i]}),
#                      join(" ", @{$hp->[$i]}));
#     }
#     print STDERR ("\n");
# }

BEGIN {
    use_ok('BHSets');
    use_ok('BHSets::Perl');
};

for (my $i = 0; $i <= 7; ++$i) {
    my @hc = BHSets::exhaustiveSets($i);
    my @hp = BHSets::Perl::exhaustiveSets($i);

    # display("ES($i):", \@hc, \@hp);

    is_deeply(\@hc, \@hp, "Equal exhaustive sets $i");
}
