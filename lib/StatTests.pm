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

# Load all public test packages
use StatTests::BonferroniDunn;
use StatTests::Dunnett;
use StatTests::Friedman;
use StatTests::ImanDavenport;
use StatTests::Nemenyi;
use StatTests::PairedANOVA;
use StatTests::PairedStudent;
use StatTests::PairedWilcoxon;
use StatTests::PairedWilcoxonZ;
use StatTests::Tukey;

# Return true
1;
