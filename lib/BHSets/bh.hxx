// hyp-test: Non-parametric hypothesis testing.
// Copyright (C) 2006-2012  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
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

#ifndef BHSETS_BH_HXX
#define BHSETS_BH_HXX

#include <utility>
#include <vector>

// Bergman-Hommel namespace
namespace bh {

// Index
typedef char index;

// Index set
typedef std::vector<index> index_set;

// Comparison
typedef std::pair<index, index> comparison;

// Comparison set
typedef std::vector<comparison> comp_set;

// Hypothesis list
typedef std::vector<comp_set> hypothesis_list;

// Bergmann-Hommel exhaustive sets
hypothesis_list exhaustiveSets(int _k);
}  // namespace bh

#endif
