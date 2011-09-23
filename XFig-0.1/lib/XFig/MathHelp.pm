use strict;

# Math Helper Functions
package XFig::MathHelp;

# Epsilon
use constant EPSILON => 1e-4;

# Pi
use constant PI => 4.0 * atan2(1,1);

# Is zero
sub isZero {
    return abs($_[0]) < EPSILON;
}

# Is zero
sub areEqual {
    return abs($_[0] - $_[1]) < EPSILON;
}


# Solve a quadratic equation
sub solveQuadratic {
    my ($A, $B, $C) = @_;
    my $d = $B * $B - 4 * $A * $C;
    return if $d < 0;
    return -$B / (2 * $A) if isZero($d);
    my $r = sqrt($d);
    return ((-$B + $r) / (2 * $A),
	    (-$B - $r) / (2 * $A));
}

# Middle Point
# Between points (x0,y0) and (x1,y1)
# Returned as (x,y)
sub middlePoint {
    my ($x0, $y0, $x1, $y1) = @_;
    return (($x0 + $x1) / 2,
	    ($y0 + $y1) / 2);
}

# Middle Line
# Between points (x0,y0) and (x1,y1)
# Returned as (a,b,c) => a * X + b * Y = C
sub middleLine {
    my ($x0, $y0, $x1, $y1) = @_;
    die "The two points are the same\n"
	if areEqual($x0, $x1) && areEqual($y0, $y1);
    return ($x1 - $x0,
	    $y1 - $y0,
	    ($x1 * $x1 - $x0 * $x0 + $y1 * $y1 - $y0 * $y0) / 2);
}

# Line Intersection
# (a,b,c) => a * X + b * Y = c
# (d,e,f) => d * X + e * Y = d
# Returned as (x,y)
sub lineIntersection {
    my ($a, $b, $c, $d, $e, $f) = @_;
    my $det = $a * $e - $b * $d;
    if (isZero($a * $e - $b * $d)) {
	die "The two lines are parallel\n"
	    if (!isZero($a * $f - $c * $d) || !isZero($b * $f - $c * $e));
	die "The two lines are the same\n";
    }
    return (($c * $e - $b * $f) / $det,
	    ($a * $f - $c * $d) / $det);
}

# Line-Circle Intersection
# (a,b,c) => a * X + b * Y = c
# (xc,yc,rSq) => (X - xc)^2 + (Y - yc)^2 = rSq
# Returned as (xs,ys), (xz,yz)
sub lineCircleIntersection {
    my ($a, $b, $c, $xc, $yc, $rSq) = @_;
    if (isZero($a)) {
	my $y = $c / $b;
	my $d = $rSq - ($y - $yc) * ($y - $yc);
	die "The line and the circle do not touch\n"
	    if $d < 0;
	$d = sqrt($d);
	return ($xc + $d, $y, $xc - $d, $y);
    } elsif (isZero($b)) {
	my $x = $c / $a;
	my $d = $rSq - ($x - $xc) * ($x - $xc);
	die "The line and the circle do not touch\n"
	    if $d < 0;
	$d = sqrt($d);
	return ($x, $yc + $d, $x, $yc - $d);
    } else {
	my ($n, $m) = (($c - $a * $xc - $b * $yc) / $b,
		       -$a / $b);
	my ($A, $B, $C) = ((1 + $m * $m), 2 * $m * $n, $n * $n - $rSq);
	my ($xs, $xz) = solveQuadratic($A, $B, $C);
	die "The line and the circle do not touch\n" if !defined($xs);
	my ($ys, $yz) = ($n + $m * $xs, $n + $m * $xz);
	return defined($xz) ?
	    ($xs, $ys, $xz, $yz) : ($xs, $ys, $xs, $ys);
    }
}

# Find vector product
sub vectorProduct {
    my ($xu, $yu, $xv, $yv) = @_;
    return $xu * $yv - $yu * $xv;
}

# Find the direction of an arc
# O : Clockwise / 1 : Counterclockwise
sub arcDirection {
    my ($xc, $yc, $x0, $y0, $x2, $y2) = @_;
    return vectorProduct($x0 - $xc, $y0 - $yc,
			 $x2 - $xc, $y2 - $yc) > 0 ? 0 : 1;
}

# Point in the middle of an arc
sub arcMid {
    my ($xc, $yc, $x0, $y0, $x2, $y2, $dir) = @_;
    my ($dx0, $dy0) = ($x0 - $xc, $y0 - $yc);
    my ($dx2, $dy2) = ($x2 - $xc, $y2 - $yc);
    my $rSq0 = $dx0 * $dx0 + $dy0 * $dy0;
    my $rSq2 = $dx2 * $dx2 + $dy2 * $dy2;
    die "Points are not on a circle\n" if !areEqual($rSq0, $rSq2);
    my @line02 = middleLine($x0, $y0, $x2, $y2);
    my ($xs, $ys, $xz, $yz) = 
	lineCircleIntersection(@line02, $xc, $yc, $rSq0);
    my $dirS = arcDirection($xc, $yc, $x0, $y0, $xs, $ys);
    return ($dir == $dirS) ? ($xs, $ys) : ($xz, $yz);
}

# Center of the arc including 3 points
sub arcCenter {
    my ($x0, $y0, $x1, $y1, $x2, $y2) = @_;
    my @line01 = middleLine($x0, $y0, $x1, $y1);
    my @line12 = middleLine($x1, $y1, $x2, $y2);
    return lineIntersection(@line01, @line12);
}

# Return true
1;
