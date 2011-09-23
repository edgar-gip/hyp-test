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
