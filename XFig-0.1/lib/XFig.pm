# hyp-test: Non-parametric hypothesis testing.
# Copyright (C) 2006-2012  Edgar Gonzàlez i Pellicer <edgar.gip@gmail.com>
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

use Carp;
use Exporter;
use IO::File;

use XFig::MathHelp;

# XFIG file
package XFig;

# Version
our $VERSION = '0.1';

# Exporting
our @ISA = qw( Exporter );
our @EXPORT_OK =
    qw( B_OFF B_ON
        C_DEFAULT C_BLACK C_BLUE C_GREEN C_CYAN C_RED C_MAGENTA C_YELLOW
        C_WHITE C_XD_BLUE C_D_BLUE C_M_BLUE C_L_BLUE C_D_GREEN C_M_GREEN
        C_L_GREEN C_D_CYAN C_M_CYAN C_L_CYAN C_D_RED C_M_RED C_L_RED
        C_D_MAGENTA C_M_MAGENTA C_L_MAGENTA C_D_BROWN C_M_BROWN C_L_BROWN
        C_D_PINK C_M_PINK C_L_PINK C_XL_PINK C_GOLD
        A_NOT_FILLED A_BLACK A_SHADE_1 A_SHADE_2 A_SHADE_3 A_SHADE_4
        A_SHADE_5 A_SHADE_6 A_SHADE_7 A_SHADE_8 A_SHADE_9 A_SHADE_10
        A_SHADE_11 A_SHADE_12 A_SHADE_13 A_SHADE_14 A_SHADE_15 A_SHADE_16
        A_SHADE_17 A_SHADE_18 A_SHADE_19 A_SATURATION A_TINT_19 A_TINT_18
        A_TINT_17 A_TINT_16 A_TINT_15 A_TINT_14 A_TINT_13 A_TINT_12
        A_TINT_11 A_TINT_10 A_TINT_9 A_TINT_8 A_TINT_7 A_TINT_6
        A_TINT_5 A_TINT_4 A_TINT_3 A_TINT_2 A_TINT_1 A_WHITE
        A_LT_DIAG30 A_RT_DIAG30 A_CROSS30 A_LT_DIAG45 A_RT_DIAG45 A_CROSS45
        A_H_BRICKS A_V_BRICKS A_H_LINES A_V_LINES A_CROSS A_RT_H_SHIN
        A_LT_H_SHIN A_LT_V_SHIN A_RT_V_SHIN A_FISH A_S_FISH A_CIRCLES
        A_HEXAGONS A_OCTAGONS A_H_TYRES A_V_TYRES
        BA_WHITE BA_BLACK
        L_DEFAULT L_SOLID L_DASH L_DOT L_DASH_DOT L_DASH_2DOT L_DASH_3DOT
        J_MITTER J_ROUND J_BEVEL
        CP_BUTT CP_ROUND CP_PROJECTING
        AR_STICK AR_TRIANGLE AR_I_TRIANGLE AR_P_TRIANGLE
        D_CLOCK D_COUNTER
        S_OPEN S_CLOSED S_APPROX S_INTER S_XSPLINE
        JT_LEFT JT_CENTER JT_RIGHT
        FF_RIGID FF_SPECIAL FF_PSFONT FF_HIDDEN
        LX_DEFAULT LX_ROMAN LX_BOLD LX_ITALIC LX_SANS_SERIF LX_TYPEWRITER
        PS_ITALIC PS_BOLD PS_DEFAULT  PS_TIMES PS_AVANTGARDE PS_BOOKMAN
        PS_COURIER PS_HELVETICA PS_NARROW PS_NCSCHOOL PS_PALATINO PS_SYMBOL
        PS_ZAPF PS_DINGBATS );
our %EXPORT_TAGS =
    ( bool    => [qw( B_ON B_OFF)],
      color   => [qw( C_DEFAULT C_BLACK C_BLUE C_GREEN C_CYAN C_RED C_MAGENTA
                      C_YELLOW C_WHITE C_XD_BLUE C_D_BLUE C_M_BLUE C_L_BLUE
                      C_D_GREEN C_M_GREEN C_L_GREEN C_D_CYAN C_M_CYAN
                      C_L_CYAN C_D_RED C_M_RED C_L_RED C_D_MAGENTA
                      C_M_MAGENTA C_L_MAGENTA C_D_BROWN C_M_BROWN C_L_BROWN
                      C_D_PINK C_M_PINK C_L_PINK C_XL_PINK C_GOLD )],
      area    => [qw( A_NOT_FILLED A_BLACK A_SHADE_1 A_SHADE_2 A_SHADE_3
                      A_SHADE_4 A_SHADE_5 A_SHADE_6 A_SHADE_7 A_SHADE_8
                      A_SHADE_9 A_SHADE_10 A_SHADE_11 A_SHADE_12 A_SHADE_13
                      A_SHADE_14 A_SHADE_15 A_SHADE_16 A_SHADE_17 A_SHADE_18
                      A_SHADE_19 A_SATURATION A_TINT_19 A_TINT_18 A_TINT_17
                      A_TINT_16 A_TINT_15 A_TINT_14 A_TINT_13 A_TINT_12
                      A_TINT_11 A_TINT_10 A_TINT_9 A_TINT_8 A_TINT_7 A_TINT_6
                      A_TINT_5 A_TINT_4 A_TINT_3 A_TINT_5 A_TINT_4 A_WHITE
                      A_LT_DIAG30 A_RT_DIAG30 A_CROSS30 A_LT_DIAG45 A_RT_DIAG45
                      A_CROSS45 A_H_BRICKS A_V_BRICKS A_H_LINES A_V_LINES
                      A_CROSS A_RT_H_SHIN A_LT_H_SHIN A_LT_V_SHIN A_RT_V_SHIN
                      A_FISH A_S_FISH A_CIRCLES A_HEXAGONS A_OCTAGONS
                      A_H_TYRES A_V_TYRES )],
      b_area  => [qw( BA_WHITE BA_BLACK )],
      line    => [qw( L_DEFAULT L_SOLID L_DASH L_DOT L_DASH_DOT L_DASH_2DOT
                      L_DASH_3DOT )],
      join    => [qw( J_MITTER J_ROUND J_BEVEL ) ],
      cap     => [qw( CP_BUTT CP_ROUND CP_PROJECTING ) ],
      arrow   => [qw( AR_STICK AR_TRIANGLE AR_I_TRIANGLE AR_P_TRIANGLE )],
      dir     => [qw( D_CLOCK D_COUNTER )],
      spline  => [qw( S_OPEN S_CLOSED S_APPROX S_INTER S_XSPLINE )],
      just    => [qw( JT_LEFT JT_CENTER JT_RIGHT )],
      fflags  => [qw( FF_RIGID FF_SPECIAL FF_PSFONT FF_HIDDEN )],
      lxfonts => [qw( LX_DEFAULT LX_ROMAN LX_BOLD LX_ITALIC LX_SANS_SERIF
                      LX_TYPEWRITER )],
      psfonts => [qw( PS_ITALIC PS_BOLD PS_DEFAULT  PS_TIMES PS_AVANTGARDE
                      PS_BOOKMAN PS_COURIER PS_HELVETICA PS_NARROW
                      PS_NCSCHOOL PS_PALATINO PS_SYMBOL PS_ZAPF PS_DINGBATS )]);

# :all Tag
push(@{$EXPORT_TAGS{all}}, @{$EXPORT_TAGS{$_}}) foreach keys %EXPORT_TAGS;

# Boolean Constants
use constant {
    B_OFF => 0, B_ON => 1 };

# Color Constants
use constant {
    C_DEFAULT   => -1, C_BLACK     =>  0, C_BLUE      =>  1,
    C_GREEN     =>  2, C_CYAN      =>  3, C_RED       =>  4,
    C_MAGENTA   =>  5, C_YELLOW    =>  6, C_WHITE     =>  7,
    C_XD_BLUE   =>  8, C_D_BLUE    =>  9, C_M_BLUE    => 10, C_L_BLUE => 11,
    C_D_GREEN   => 12, C_M_GREEN   => 13, C_L_GREEN   => 14,
    C_D_CYAN    => 15, C_M_CYAN    => 16, C_L_CYAN    => 17,
    C_D_RED     => 18, C_M_RED     => 19, C_L_RED     => 20,
    C_D_MAGENTA => 21, C_M_MAGENTA => 22, C_L_MAGENTA => 23,
    C_D_BROWN   => 24, C_M_BROWN   => 25, C_L_BROWN   => 26,
    C_D_PINK    => 27, C_M_PINK    => 28, C_L_PINK    => 29, C_XL_PINK => 30,
    C_GOLD      => 31 };

# Area Constants
use constant {
    A_NOT_FILLED => -1, A_BLACK     =>  0, A_SHADE_1  =>  1,
    A_SHADE_2    =>  2, A_SHADE_3   =>  3, A_SHADE_4  =>  4,
    A_SHADE_5    =>  5, A_SHADE_6   =>  6, A_SHADE_7  =>  7,
    A_SHADE_8    =>  8, A_SHADE_9   =>  9, A_SHADE_10 => 10,
    A_SHADE_11   => 11, A_SHADE_12  => 12, A_SHADE_13 => 13,
    A_SHADE_14   => 14, A_SHADE_15  => 15, A_SHADE_16 => 16,
    A_SHADE_17   => 17, A_SHADE_18  => 18, A_SHADE_19 => 19,
    A_SATURATION => 20, A_TINT_19   => 21, A_TINT_18  => 22,
    A_TINT_17    => 23, A_TINT_16   => 24, A_TINT_15  => 25,
    A_TINT_14    => 26, A_TINT_13   => 27, A_TINT_12  => 28,
    A_TINT_11    => 29, A_TINT_10   => 30, A_TINT_9   => 31,
    A_TINT_8     => 32, A_TINT_7    => 24, A_TINT_6   => 34,
    A_TINT_5     => 35, A_TINT_4    => 24, A_TINT_3   => 37,
    A_TINT_2     => 38, A_TINT_1    => 39, A_WHITE  => 40,
    A_LT_DIAG30  => 41, A_RT_DIAG30 => 42, A_CROSS30  => 43,
    A_LT_DIAG45  => 44, A_RT_DIAG45 => 45, A_CROSS45  => 46,
    A_H_BRICKS   => 47, A_V_BRICKS  => 48,
    A_H_LINES    => 49, A_V_LINES   => 50, A_CROSS    => 51,
    A_RT_H_SHIN  => 52, A_LT_H_SHIN => 53,
    A_LT_V_SHIN  => 54, A_RT_V_SHIN => 55,
    A_FISH       => 56, A_S_FISH    => 57,
    A_CIRCLES    => 58, A_HEXAGONS  => 59, A_OCTAGONS => 60,
    A_H_TYRES    => 61, A_V_TYRES   => 62 };

# Black Area Constants
use constant {
    BA_WHITE => 0, BA_BLACK => 20 };

# Line Style Constants
use constant {
    L_DEFAULT   => -1, L_SOLID    => 0, L_DASH      => 1,
    L_DOT       =>  2, L_DASH_DOT => 3, L_DASH_2DOT => 4,
    L_DASH_3DOT =>  5 };

# Join Style Constants
use constant {
    J_MITTER => 0, J_ROUND => 1, J_BEVEL => 2 };

# Cap Style Constants
use constant {
    CP_BUTT => 0, CP_ROUND => 1, CP_PROJECTING => 2 };

# Arrow Style Constants
use constant {
    AR_STICK => 0, AR_TRIANGLE => 1, AR_I_TRIANGLE => 2, AR_P_TRIANGLE => 3 };

# Direction Constants
use constant {
    D_CLOCK => 0, D_COUNTER => 1 };

# Spline Constants
use constant {
    S_OPEN => 0, S_CLOSED => 1, S_APPROX => 0, S_INTER => 2, S_XSPLINE => 4 };

# Font Justification Constants
use constant {
    JT_LEFT => 0, JT_CENTER => 1, JT_RIGHT => 2 };

# Font Flag Constants
use constant {
    FF_RIGID => 1, FF_SPECIAL => 2, FF_PSFONT => 4, FF_HIDDEN => 8 };

# Latex Fonts
use constant {
    LX_DEFAULT    => 0, LX_ROMAN      => 1, LX_BOLD => 2,
    LX_ITALIC     => 3, LX_SANS_SERIF => 4, LX_TYPEWRITER => 5 };

# Postscript Fonts
use constant {
    PS_ITALIC  =>  1, PS_BOLD     =>  2,
    PS_DEFAULT => -1, PS_TIMES    =>  0, PS_AVANTGARDE => 4,
    PS_BOOKMAN =>  8, PS_COURIER  => 12, PS_HELVETICA  => 16,
    PS_NARROW  => 20, PS_NCSCHOOL => 24, PS_PALATINO   => 28,
    PS_SYMBOL  => 32, PS_ZAPF     => 33, PS_DINGBATS   => 34 };


# Ranged fields
use XFig::RangedFields
    ('area'        =>  A_NOT_FILLED, A_NOT_FILLED,     A_V_TYRES,
     'depth'       =>             0,           50,           999,
     'line'        =>     L_DEFAULT,    L_DEFAULT,   L_DASH_3DOT,
     'gap'         =>             0,            4,           999,
     'thick'       =>             0,            1,            80,
     'join'        =>      J_MITTER,     J_MITTER,       J_BEVEL,
     'cap'         =>       CP_BUTT,      CP_BUTT, CP_PROJECTING,

     'arrowFwd'    =>         B_OFF,        B_OFF,          B_ON,
     'arrowFType'  =>      AR_STICK,     AR_STICK, AR_P_TRIANGLE,
     'arrowFFill'  =>         B_OFF,        B_OFF,          B_ON,
     'arrowFThick' =>           0.1,            1,           999,
     'arrowFWidth' =>           0.1,            4,           999,
     'arrowFHeight'=>           0.1,            8,           999,

     'arrowBack'   =>         B_OFF,        B_OFF,          B_ON,
     'arrowBType'  =>      AR_STICK,     AR_STICK, AR_P_TRIANGLE,
     'arrowBFill'  =>         B_OFF,        B_OFF,          B_ON,
     'arrowBThick' =>           0.1,            1,           999,
     'arrowBWidth' =>           0.1,            4,           999,
     'arrowBHeight'=>           0.1,            8,           999,

     'justify'     =>       JT_LEFT,      JT_LEFT,      JT_RIGHT,
     'fontFlags'   =>             0,    FF_PSFONT,            15,
     'latexFont'   =>    LX_DEFAULT,   LX_DEFAULT, LX_TYPEWRITER,
     'psFont'      =>    PS_DEFAULT,   PS_DEFAULT,   PS_DINGBATS,
     'fontSize'    =>             1,           10,           500);


# Constructor
sub new {
    my ($class, $file, %options) = @_;

    # Get an empty object
    my $this = _empty($class);

    # Colors
    $this->{'pen'}       = -1;
    $this->{'fill'}      = -1;
    $this->{'lastColor'} = 31;

    # Is file a file or a name
    if (!ref($file)) {
        my $name = $file;
        $file = new IO::File("> $name")
            or Carp::croak "Can't open $name: $!";
    }

    # Set default values
    $options{'orientation'}   ||= 'Landscape'; # Landscape/Portrait
    $options{'justification'} ||= 'Center';    # Center/Flush Left
    $options{'units'}         ||= 'Inches';    # Metric/Inches
    $options{'papersize'}     ||= 'Letter';    # Letter/Legal/Ledger/Tabloid
                                               # A/B/C/D/E
                                               # A4/A3/A2/A1/A0/B5
    $options{'magnification'} ||= 100.0;
    $options{'multiple-page'} ||= 'Single';    # Single/Multiple
    $options{'transparent'}   ||= -2;          # -3/-2/-1/0-31/32-
    $options{'resolution'}    ||= 1200;

    # Write the header
    $file->printf("#FIG 3.2\n%s\n%s\n%s\n%s\n%.2f\n%s\n%d\n%d 2\n",
                  @options{'orientation', 'justification', 'units',
                           'papersize', 'magnification', 'multiple-page',
                           'transparent', 'resolution'});

    # Assign the file and return
    $this->{'file'} = $file;
    return $this;
}

# Pen
sub pen {
    my ($this, $pen) = @_;

    if (defined($pen)) {
        Carp::croak "Wrong pen: $pen"
            if $pen < -1 || $pen > $this->{'lastColor'};
        $this->{'pen'} = $pen;
    }

    return $this->{'pen'};
}

# Fill
sub fill {
    my ($this, $fill) = @_;

    if (defined($fill)) {
        Carp::croak "Wrong fill: $fill"
            if $fill < -1 || $fill > $this->{'lastColor'};
        $this->{'fill'} = $fill;
    }

    return $this->{'fill'};
}

# Add a color
sub color {
    my ($this, @rgb) = @_;

    # Check for errors
    Carp::croak "Too many colors"    if $this->{'lastColor'} == 543;
    Carp::croak "Must give a color"  if !@rgb;

    # Convert
    my $rgb;
    if (@rgb == 1) {
        # Set
        $rgb = $rgb[0];
        Carp::croak "Wrong color format" if $rgb !~ /^\#[0-9A-Fa-f]{6}$/;
    }
    elsif (@rgb == 3) {
        # Check
        Carp::croak "Colour component out of range"
            if grep { $_ < 0 || $_ > 255 } @rgb;
        $rgb = sprintf("#%02x%02x%02x", @rgb);
    }
    else {
        # Error
        Carp::croak "Must give one or three components";
    }

    # Get an id and write
    my $id = ++$this->{'lastColor'};
    $this->{'file'}->printf("0 %d %s\n", $id, $rgb);

    # Return the id
    return $id;
}

# Arrows
# Private function
sub _arrows {
    my ($this) = @_;

    # Forward arrow
    if ($this->{'arrowFwd'}) {
        $this->{'file'}->
            printf("\t%d %d %f %f %f\n",
                   @{$this}{'arrowFType',  'arrowFFill', 'arrowFThick'},
                   map { 15.0 * $_ } @{$this}{'arrowFWidth', 'arrowFHeight'});
    }

    # Backwards arrow
    if ($this->{'arrowBack'}) {
        $this->{'file'}->
            printf("\t%d %d %f %f %f\n",
                   @{$this}{'arrowBType',  'arrowBFill', 'arrowBThick'},
                   map { 15.0 * $_ } @{$this}{'arrowFWidth', 'arrowFHeight'});
    }
}

# Draw an arc from center and two points
sub drawArc2 {
    my ($this, $xc, $yc, $x0, $y0, $x2, $y2, $dir) = @_;
    my ($x1, $y1) = XFig::MathHelp::arcMid($xc, $yc, $x0, $y0, $x2, $y2, $dir);
    $this->{'file'}->
        printf("5 1 %d %d %d %d %d -1 %d %f %d %d %d %d ".
               "%f %f %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap', 'cap'}, $dir, @{$this}{'arrowFwd', 'arrowBack'},
               $xc, $yc, $x0, $y0, $x1, $y1, $x2, $y2);
    $this->_arrows();
}

# Draw an arc from three points
sub drawArc3 {
    my ($this, $x0, $y0, $x1, $y1, $x2, $y2) = @_;
    my ($xc, $yc) = XFig::MathHelp::arcCenter($x0, $y0, $x1, $y1, $x2, $y2);
    my $dir = XFig::MathHelp::arcDirection($xc, $yc, $x0, $y0, $x2, $y2);
    $this->{'file'}->
        printf("5 1 %d %d %d %d %d -1 %d %f %d %d %d %d ".
               "%f %f %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap', 'cap'}, $dir, @{$this}{'arrowFwd', 'arrowBack'},
               $xc, $yc, $x0, $y0, $x1, $y1, $x2, $y2);
    $this->_arrows();
}

# Draw a pie from center and two points
sub drawPie2 {
    my ($this, $xc, $yc, $x0, $y0, $x2, $y2, $dir) = @_;
    my ($x1, $y1) = XFig::MathHelp::arcMid($xc, $yc, $x0, $y0, $x2, $y2, $dir);
    $this->{'file'}->
        printf("5 2 %d %d %d %d %d -1 %d %f %d %d 0 0 ".
               "%f %f %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap', 'cap'},
               $dir, $xc, $yc, $x0, $y0, $x1, $y1, $x2, $y2);
}

# Draw a pie from three points
sub drawPie3 {
    my ($this, $x0, $y0, $x1, $y1, $x2, $y2) = @_;
    my ($xc, $yc) = XFig::MathHelp::arcCenter($x0, $y0, $x1, $y1, $x2, $y2);
    my $dir = XFig::MathHelp::arcDirection($xc, $yc, $x0, $y0, $x2, $y2);
    $this->{'file'}->
        printf("5 2 %d %d %d %d %d -1 %d %f %d %d 0 0 ".
               "%f %f %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap', 'cap'},
               $dir, $xc, $yc, $x0, $y0, $x1, $y1, $x2, $y2);
}

# Draw a circle from center and radius
sub drawCircleR {
    my ($this, $xc, $yc, $r) = @_;
    $this->{'file'}->
        printf("1 3 %d %d %d %d %d -1 %d %f 1 0.0 ".
               "%d %d %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap'}, $xc, $yc, $r, $r, $xc, $yc, $xc + $r, $yc);
}

# Draw a circle from center and a point
sub drawCircleP {
    my ($this, $xc, $yc, $x0, $y0) = @_;
    my ($dx, $dy) = ($x0 - $xc, $y0 - $yc);
    my $r = sqrt($dx * $dx + $dy * $dy);
    $this->{'file'}->
        printf("1 3 %d %d %d %d %d -1 %d %f 1 0.0 ".
               "%d %d %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap' }, $xc, $yc, $r, $r, $xc, $yc, $x0, $y0);
}

# Draw a circle from two points (a diameter)
sub drawCircleD {
    my ($this, $x0, $y0, $x1, $y1) = @_;
    my ($dx, $dy) = ($x1 - $x0, $y1 - $y0);
    my $r = sqrt($dx * $dx + $dy * $dy) / 2;
    my ($xc, $yc) = XFig::MathHelp::middlePoint($x0, $y0, $x1, $y1);
    $this->{'file'}->
        printf("1 4 %d %d %d %d %d -1 %d %f 1 0.0 ".
               "%d %d %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap' }, $xc, $yc, $r, $r, $x0, $y0, $x1, $y1);
}

# Ellipse
sub drawEllipse {
    my ($this, $xc, $yc, $rx, $ry, $angle) = @_;
    my ($xe, $ye) = ($xc + $rx * cos($angle) - $ry * sin($angle),
                     $yc + $rx * sin($angle) + $ry * cos($angle));
    $this->{'file'}->
        printf("1 1 %d %d %d %d %d -1 %d %f 1 %f ".
               "%d %d %d %d %d %d %d %d\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap' },
               $angle, $xc, $yc, $rx, $ry, $xc, $yc, $xe, $ye);
}

# Draw a line
sub drawLine {
    my ($this, @points) = @_;
    $this->{'file'}->
        printf("2 1 %d %d %d %d %d -1 %d %f %d %d -1 %d %d %d\n\t%s\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap', 'join', 'cap', 'arrowFwd', 'arrowBack' },
               @points / 2, CORE::join(' ', @points));
    $this->_arrows();
}

# Draw a box
sub drawBox {
    my ($this, $x0, $y0, $xf, $yf) = @_;
    $this->{'file'}->
       printf("2 2 %d %d %d %d %d -1 %d %d %d %d -1 0 0 5\n\t%s\n",
              @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                       'gap', 'join', 'cap' },
              CORE::join(' ', $x0, $y0, $xf, $y0, $xf, $yf,
                         $x0, $yf, $x0, $y0));
}

# Draw a polygon
sub drawPolygon {
    my ($this, @points) = @_;

    # Check point sanity
    Carp::croak "Must give at least 3 points"
        if @points < 6;
    push(@points, @points[0,1])
        if ($points[0] != $points[-2] or $points[1] != $points[-1]);

    # Draw
    $this->{'file'}->
        printf("2 3 %d %d %d %d %d -1 %d %f %d %d -1 0 0 %d\n\t%s\n",
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap', 'join', 'cap' },
               @points / 2, CORE::join(' ', @points));
}

# Arc box
sub drawArcBox {
    my ($this, $x0, $y0, $xf, $yf, $radius) = @_;
    $this->{'file'}->
       printf("2 4 %d %d %d %d %d -1 %d %f %d %d %d 0 0 5\n\t%s\n",
              @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                       'gap', 'join', 'cap' }, $radius,
              CORE::join(' ', $x0, $y0, $xf, $y0, $xf, $yf,
                         $x0, $yf, $x0, $y0));
}

# Spline
sub drawSpline {
    my ($this, $mode, @points) = @_;
    my @control;
    if ($mode & S_XSPLINE) {
        my $i = 2;
        while ($i < @points) {
            push(@control, splice(@points, $i, 1));
            $i += 2;
        }
    } elsif ($mode & S_CLOSED) {
        @control = ( (($mode & S_INTER) ? -1.0 : +1.0 ) x (@points / 2) );
    } else { # OPEN
        @control = ( 0.0,
                     (($mode & S_INTER) ? -1.0 : +1.0) x (@points / 2 - 2),
                     0.0 );
    }

    $this->{'file'}->
        printf("3 %d %d %d %d %d %d -1 %d %f %d %d %d %d\n\t%s\n\t%s\n",
               $mode,
               @{$this}{'line', 'thick', 'pen', 'fill', 'depth', 'area',
                        'gap', 'cap', 'arrowFwd', 'arrowBack' }, @points / 2,
               CORE::join(' ', @points), CORE::join(' ', @control));
}

# Text size
sub textSize {
    my ($this, $text) = @_;

    # Call C function
    return _textSize($this->{'fontFlags'} & FF_PSFONT,
                     ($this->{'fontFlags'} & FF_PSFONT ?
                      $this->{'psFont'} : $this->{'latexFont'}),
                     $this->{'fontSize'}, $text);
}

# Text
sub drawText {
    my ($this, $x, $y, $text, $angle) = @_;

    # Default
    $angle = 0.0 if !defined($angle);

    # Font
    my $font = $this->{'fontFlags'} & FF_PSFONT ?
        $this->{'psFont'} : $this->{'latexFont'};

    # Size
    my ($width, $ascent, $descent) = $this->textSize($text);

    # Escape text
    $text =~ s/([\x80-\xff])/sprintf('\%03o',ord($1))/ge;

    # Write
    $this->{'file'}->
        printf("4 %d %d %d -1 %d %f %f %d %f %f %d %d %s\\001\n",
               @{$this}{'justify', 'pen', 'depth'}, $font,
               $this->{'fontSize'}, $angle, $this->{'fontFlags'},
               $ascent + $descent, $width, $x, $y, $text);
}

# Close
sub close {
    my ($this) = @_;

    $this->{'file'}->close();
}

# Dynamic part
# Includes routines openDisplay() and textSize()
use XSLoader;
XSLoader::load('XFig', $VERSION);

# Return true
1;
