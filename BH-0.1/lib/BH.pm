use strict;
use warnings;

use Exporter;

# Bergman-Hommel test
package BH;
our @ISA = qw(Exporter);

# Exports
our @EXPORT      = qw( );
our @EXPORT_OK   = qw( bergmannHommelOnline );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

# Version
our $VERSION = '0.1';

# Load XS
require XSLoader;
XSLoader::load('BH', $VERSION);

# Return true
1;
