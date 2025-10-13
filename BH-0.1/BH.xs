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

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <bh.hxx>

MODULE = BH             PACKAGE = BH

AV*
bergmannHommelOnline(_k, _inBars, _alpha)
    unsigned int _k
    AV* _inBars
    double _alpha
  PROTOTYPE: $\@$
  PREINIT:
    std::list<bar> outBars;
  PPCODE:
    // Call function
    outBars = bergmannHommelOnline(_k, _inBars, _alpha);

    // Reserve space in the stack
    EXTEND(SP, outBars.size());

    // For each one
    for (std::list<bar>::const_iterator it = outBars.begin();
         it != outBars.end(); ++it) {
      // Create an AV
      AV* cs = newAV();
      av_extend(cs, 3);

      // Insert them
      av_store(cs, 0, newSVuv(it->first));
      av_store(cs, 1, newSVuv(it->second));
      av_store(cs, 2, newSVnv(it->pvalue));

      // Push it
      PUSHs(sv_2mortal(newRV_noinc(reinterpret_cast<SV*>(cs))));
    }
