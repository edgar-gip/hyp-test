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

#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#include "ppport.h"

#include "text.h"

MODULE = XFig   PACKAGE = XFig

void
openDisplay(name)
    char* name
  PROTOTYPE: $
  CODE:
    switch (openDisplay(name)) {
    case OD_OK:
      break;
    case OD_OPEN:
      croak("Display is already open");
      break;
    case OD_ERROR:
      croak("Error opening display");
      break;
    }

void
_textSize(psFlag, fontNum, size, text)
    int   psFlag
    int   fontNum
    int   size
    char* text
  PROTOTYPE: $$$$
  PREINIT:
    int   width;
    int   ascent;
    int   descent;
  PPCODE:
    // Call C library function
    switch (textSize(psFlag, fontNum, size, text, &width, &ascent, &descent)) {
    case TS_OK:
      EXTEND(SP, 3);
      PUSHs(sv_2mortal(newSViv(width)));
      PUSHs(sv_2mortal(newSViv(ascent)));
      PUSHs(sv_2mortal(newSViv(descent)));
      break;
    case TS_NODISPLAY:
      croak("Display is not open");
      break;
    case TS_SIZE:
      croak("Size outside of range");
      break;
    case TS_FONT:
      croak("Font index outside of range");
      break;
    case TS_OVERRUN:
      croak("Buffer overrun");
      break;
    case TS_NOFONT:
      croak("Font does not exist");
      break;
    }
