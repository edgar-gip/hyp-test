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

use Exporter;

# Bergman-Hommel test
package BH;
our @ISA = qw(Exporter);

# Exports
our @EXPORT      = qw( );
our @EXPORT_OK   = qw( bergmannHommelOnline );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

# Version
our $VERSION = '0.1';

# Load XS
require XSLoader;
XSLoader::load('BH', $VERSION);

# Return true
1;
