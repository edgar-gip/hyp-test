# hyp-test: Non-parametric hypothesis testing.
# Copyright (C) 2006-2012  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
    AUTHOR     => 'Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>',
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
