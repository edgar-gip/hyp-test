# hyp-test: Non-parametric hypothesis testing.
# Copyright (C) 2006-2025  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
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

WriteMakefile(
    NAME    => 'HypTest',
    VERSION => '0.1',
    AUTHOR  => 'Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>',
    LICENSE => 'gpl_3',
    INC     => '-Ilib',
    CC      => '$(CXX)',
    LD      => '$(CXX)',
    XSOPT   => '-C++',
    XSMULTI => 1,
    XSBUILD => {
        xs => {
            'lib/BH' => {
                OBJECT => 'lib/BH$(OBJ_EXT) lib/BH/bh$(OBJ_EXT) lib/BH/subsets$(OBJ_EXT)',
            },
            'lib/BHSets' => {
                OBJECT => 'lib/BHSets$(OBJ_EXT) lib/BHSets/bh$(OBJ_EXT)',
            },
        },
    },
    PREREQ_PM => {
	'SVG' => 0,
    },
    EXE_FILES => ['bin/hyp-test'],
);

package MY;

sub init_xs {
    my $self = shift;
    $self->SUPER::init_xs(@_);
    $self->{INST_STATIC}  .= ' $(INST_ARCHLIB)/auto/Math/R/R$(LIB_EXT)';
    $self->{INST_DYNAMIC} .= ' $(INST_ARCHLIB)/auto/Math/R/R.$(DLEXT)';
    $self->{INST_BOOT}    .= ' $(INST_ARCHLIB)/auto/Math/R/R.bs';
}

sub blibdirs {
    my $self = shift;
    my $parentBlock = $self->SUPER::blibdirs_target;
    my $mathDir = '$(INST_ARCHLIB)/auto/Math/R';
    return (
        "$parentBlock" .
        "blibdirs: $mathDir\$(DFSEP).exists\n" .
        "\n" .
        $self->dir_target($mathDir)
    );
}

sub dynamic_lib {
    my ($self, %attribs) = @_;
    my $parentBlock = $self->SUPER::dynamic_lib(%attribs);
    my @mathRLib = (
        'lib/Math/R_wrap$(OBJ_EXT)',
        '$(INST_ARCHLIB)/auto/Math/R/R.$(DLEXT)',
        '$(INST_ARCHLIB)/auto/Math/R',
        'lib/Math/R_wrap$(OBJ_EXT) -lm -lRmath',
        '',
        undef,
    );
    return (
        "$parentBlock\n" .
        join("\n", $self->xs_make_dynamic_lib(\%attribs, @mathRLib))
    );
}

sub dynamic_bs {
    my($self, %attribs) = @_;
    my $parentBlock = $self->SUPER::dynamic_bs(%attribs);
    return (
        "$parentBlock\n" .
        "BOOTSTRAP += lib/Math/R/R.bs\n" .
        "\n" .
        $self->_xs_make_bs('lib/Math/R')
    );
}

sub postamble {
    return (
        "\n" .
        "lib/Math/R.pm: lib/Math/R_wrap.c\n" .
        "\n" .
        "lib/Math/R_wrap.c: lib/Math/R.i\n" .
        "\tswig -perl -I/usr/include -outdir lib/Math -DMATHLIB_STANDALONE \$<\n" .
        "\n"
    );
}
