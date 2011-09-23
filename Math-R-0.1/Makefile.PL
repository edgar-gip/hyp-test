use strict;
use warnings;

use ExtUtils::MakeMaker;

# Write the makefile
WriteMakefile(
    NAME       => 'Math::R',
    VERSION    => '0.1', 
    PREREQ_PM  => {},
    ABSTRACT   => 
        'Wrapper around the Mathematical Library of the R Statistical System',
    AUTHOR     => 'E. Gonzalez <egonzalez@lsi.upc.edu>',
    OBJECT     => 'Math-R_wrap.o',
    DEFINE     => '-DMATHLIB_STANDALONE',
    LIBS       => ['-lm -lRmath'],
);

sub MY::postamble {
    return
	("\n" .
	 "lib/Math/R.pm: Math-R_wrap.c\n" .
	 "\n" .
	 "Math-R_wrap.c: Math-R.i\n" .
	 "\tswig -perl -I/usr/include -outdir lib/Math -DMATHLIB_STANDALONE Math-R.i\n" .
	 "\n");
}
