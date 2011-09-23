use strict;

use Test::More tests => 1;

# Load
BEGIN { use_ok('XFig') };

# Open display
XFig::openDisplay(":0");

# Open file
my $f = new XFig("/dev/null");

# Write a text
my $text = "Fight Test";
$f->drawText(100, 100, $text);

# Draw a box
my ($width, $ascent, $descent) = $f->textSize($text);
$f->drawBox(100, 100 - $ascent, 100 + $width, 100 + $descent);

# Close
$f->close();
