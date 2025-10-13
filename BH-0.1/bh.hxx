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

#ifndef BH_HXX
#define BH_HXX

#include <list>
#include <vector>

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>


// Bar
struct bar {
  // First
  unsigned int first;

  // Second
  unsigned int second;

  // P-value
  double pvalue;

  // Constructor
  bar(unsigned int _first, unsigned _second, double _pvalue) :
    first(_first), second(_second), pvalue(_pvalue) {
  }
};


// Perform the bergmann-hommel test
std::list<bar> bergmannHommelOnline(unsigned int _k, AV* _inBars,
                                    double _alpha);

#endif
