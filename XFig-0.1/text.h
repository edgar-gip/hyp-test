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

#ifndef TEXT_H
#define TEXT_H

/* Open display status */
enum odStatus { OD_OK, OD_OPEN, OD_ERROR };

/* Open display */
enum odStatus openDisplay(const char* _name);

/* Text size status */
enum tsStatus { TS_OK, TS_NODISPLAY, TS_SIZE, TS_FONT, TS_OVERRUN, TS_NOFONT };

/* Text size */
enum tsStatus textSize(int _psFlag, int _fontNum, int _size, const char* _text,
                       int* _width, int* _ascent, int* _descent);

#endif
