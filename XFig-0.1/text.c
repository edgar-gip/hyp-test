/*
 * hyp-test: Non-parametric hypothesis testing.
 * Copyright (C) 2006-2012  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "text.h"

#include <X11/Xlib.h>
#include <stdio.h>
#include <string.h>

/* Zoom factor */
#define PIX_PER_INCH 1200
#define DISPLAY_PIX_PER_INCH 80
#define ZOOM_FACTOR (PIX_PER_INCH / DISPLAY_PIX_PER_INCH)

/* Font size range (points) */
#define MIN_FONT_SIZE 1
#define MAX_FONT_SIZE 500

/* Number of fonts */
#define N_LATEX_FONTS 5
#define N_PS_FONTS 35

/* Latex font mapping */
static int latexMapping[N_LATEX_FONTS] = {
    0,  /* Roman  */
    2,  /* Bold   */
    1,  /* Italic */
    16, /* Sans Serif */
    12  /* Typewriter */
};

/* PostScript font templates */
static const char* psFonts[N_PS_FONTS] = {
    "-*-times-medium-r-normal--",
    "-*-times-medium-i-normal--",
    "-*-times-bold-r-normal--",
    "-*-times-bold-i-normal--",
    "-*-avantgarde-book-r-normal--",
    "-*-avantgarde-book-o-normal--",
    "-*-avantgarde-demi-r-normal--",
    "-*-avantgarde-demi-o-normal--",
    "-*-bookman-light-r-normal--",
    "-*-bookman-light-i-normal--",
    "-*-bookman-demi-r-normal--",
    "-*-bookman-demi-i-normal--",
    "-*-courier-medium-r-normal--",
    "-*-courier-medium-o-normal--",
    "-*-courier-bold-r-normal--",
    "-*-courier-bold-o-normal--",
    "-*-helvetica-medium-r-normal--",
    "-*-helvetica-medium-o-normal--",
    "-*-helvetica-bold-r-normal--",
    "-*-helvetica-bold-o-normal--",
    "-*-helvetica-medium-r-narrow--",
    "-*-helvetica-medium-o-narrow--",
    "-*-helvetica-bold-r-narrow--",
    "-*-helvetica-bold-o-narrow--",
    "-*-new century schoolbook-medium-r-normal--",
    "-*-new century schoolbook-medium-i-normal--",
    "-*-new century schoolbook-bold-r-normal--",
    "-*-new century schoolbook-bold-i-normal--",
    "-*-palatino-medium-r-normal--",
    "-*-palatino-medium-i-normal--",
    "-*-palatino-bold-r-normal--",
    "-*-palatino-bold-i-normal--",
    "-*-symbol-medium-r-normal--",
    "-*-itc zapf chancery-medium-i-normal--",
    "-*-itc zapf dingbats-*-*-*--"};

/* PostScript backup font templates */
static const char* psBackupFonts[N_PS_FONTS] = {
    "-*-times-medium-r-normal--",
    "-*-times-medium-i-normal--",
    "-*-times-bold-r-normal--",
    "-*-times-bold-i-normal--",
    "-*-lucida-medium-r-normal-sans-", /* closest to Avant-Garde */
    "-*-lucida-medium-i-normal-sans-",
    "-*-lucida-bold-r-normal-sans-",
    "-*-lucida-bold-i-normal-sans-",
    "-*-times-medium-r-normal--", /* closest to Bookman */
    "-*-times-medium-i-normal--",
    "-*-times-bold-r-normal--",
    "-*-times-bold-i-normal--",
    "-*-courier-medium-r-normal--",
    "-*-courier-medium-o-normal--",
    "-*-courier-bold-r-normal--",
    "-*-courier-bold-o-normal--",
    "-*-helvetica-medium-r-normal--",
    "-*-helvetica-medium-o-normal--",
    "-*-helvetica-bold-r-normal--",
    "-*-helvetica-bold-o-normal--",
    "-*-helvetica-medium-r-normal--", /* closest to Helv-nar. */
    "-*-helvetica-medium-o-normal--",
    "-*-helvetica-bold-r-normal--",
    "-*-helvetica-bold-o-normal--",
    "-*-new century schoolbook-medium-r-normal--",
    "-*-new century schoolbook-medium-i-normal--",
    "-*-new century schoolbook-bold-r-normal--",
    "-*-new century schoolbook-bold-i-normal--",
    "-*-lucidabright-medium-r-normal--", /* closest to Palatino */
    "-*-lucidabright-medium-i-normal--",
    "-*-lucidabright-demibold-r-normal--",
    "-*-lucidabright-demibold-i-normal--",
    "-*-symbol-medium-r-normal--",
    "-*-zapf chancery-medium-i-normal--",
    "-*-zapf dingbats-*-*-*--"};

/* Font name buffer size */
#define FONT_BUFFER_SIZE 300

/* Display */
static Display* xDisplay = NULL;

/* Open display */
enum odStatus openDisplay(const char* _name) {
  /* Already open */
  if (xDisplay) {
    return OD_OPEN;
  }

  /* Try to open */
  xDisplay = XOpenDisplay(_name);

  /* OK? */
  return xDisplay ? OD_OK : OD_ERROR;
}

/* Cache information */
struct cacheInfo {
  int xfont;
  int size;
  XFontStruct* font;
};

/* Cache */
static struct cacheInfo cache = {0, 0, NULL};

/* Lookup font */
static enum tsStatus lookupFont(int _psFlag, int _fontNum, int _size) {
  /* Vars */
  int ret;
  int xfont;
  int isSymbolic;
  char fontName[FONT_BUFFER_SIZE];
  XFontStruct* newFont;

  /* Check size */
  if (_size < MIN_FONT_SIZE || _size > MAX_FONT_SIZE) {
    return TS_SIZE;
  }

  /* Default is zero */
  if (_fontNum == -1) {
    _fontNum = 0;
  }

  /* Start locating the font */
  if (_psFlag) {
    /* PostScript font */

    /* Check */
    if (_fontNum < 0 || _fontNum >= N_PS_FONTS) {
      return TS_FONT;
    }

    /* Direct map */
    xfont = _fontNum;
  } else {
    /* Latex font */

    /* Check */
    if (_fontNum < 0 || _fontNum >= N_LATEX_FONTS) {
      return TS_FONT;
    }

    /* Map */
    xfont = latexMapping[_fontNum];
  }

  /* Same? */
  if (cache.font && cache.xfont == xfont && _size == cache.size) {
    /* No need to look */
    return TS_OK;
  }

  /* Display is open? */
  if (!xDisplay) {
    /* Error! */
    return TS_NODISPLAY;
  }

  /* Is it a symbolic font? */
  isSymbolic =
      (strstr(psFonts[xfont], "ymbol") || strstr(psFonts[xfont], "ingbats"));

  /* Create the font name */
  ret = snprintf(fontName, FONT_BUFFER_SIZE, "%s%d-*-*-*-*-*-%s-*",
                 psFonts[xfont], _size, isSymbolic ? "*" : "ISO8859");
  if (ret < 0 || ret >= FONT_BUFFER_SIZE) {
    return TS_OVERRUN;
  }

  /* Look it up */
  newFont = XLoadQueryFont(xDisplay, fontName);

  /* If not found, try with backup */
  if (!newFont) {
    /* Create the backup font name */
    ret = snprintf(fontName, FONT_BUFFER_SIZE, "%s%d-*-*-*-*-*-%s-*",
                   psBackupFonts[xfont], _size, isSymbolic ? "*" : "ISO8859");
    if (ret < 0 || ret >= FONT_BUFFER_SIZE) {
      return TS_OVERRUN;
    }

    /* Look it up */
    newFont = XLoadQueryFont(xDisplay, fontName);

    /* Not found? */
    if (!newFont) {
      return TS_NOFONT;
    }
  }

  /* Free old font */
  if (cache.font) {
    XFreeFont(xDisplay, cache.font);
  }

  /* Update cache */
  cache.xfont = xfont;
  cache.size = _size;
  cache.font = newFont;

  /* OK */
  return TS_OK;
}

/* Text size */
enum tsStatus textSize(int _psFlag, int _fontNum, int _size, const char* _text,
                       int* _width, int* _ascent, int* _descent) {
  /* Vars */
  enum tsStatus ret;
  int dir, asc, desc;
  XCharStruct overall;

  /* Lookup the font */
  ret = lookupFont(_psFlag, _fontNum, _size);

  /* Any error? */
  if (ret) {
    return ret;
  }

  /* Query */
  XTextExtents(cache.font, _text, strlen(_text), &dir, &asc, &desc, &overall);

  /* Return */
  *_width = ZOOM_FACTOR * overall.width;
  *_ascent = ZOOM_FACTOR * overall.ascent;
  *_descent = ZOOM_FACTOR * overall.descent;
  return TS_OK;
}
