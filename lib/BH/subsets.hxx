// hyp-test: Non-parametric hypothesis testing.
// Copyright (C) 2006-2012  Ignasi Abío i Roig <ignasi.abio@gmail.com>
//                          Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifndef SUBSETS_HXX
#define SUBSETS_HXX

#include <vector>

typedef unsigned int uint;

void computeSets(const std::vector<std::vector<double>>& probs, double alpha,
                 std::vector<std::vector<bool>>& list);

#endif
