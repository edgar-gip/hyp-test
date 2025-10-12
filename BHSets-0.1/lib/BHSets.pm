use strict;
use warnings;

use Exporter;

# Bergman-Hommel sets
package BHSets;
our @ISA = qw(Exporter);

# Exports
our @EXPORT      = qw( );
our @EXPORT_OK   = qw( exhaustiveSets );
our %EXPORT_TAGS = ( 'all' => \@EXPORT_OK );

# Version
our $VERSION = '0.1';

# Load XS
require XSLoader;
XSLoader::load('BHSets', $VERSION);

# Return true
1;
