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

# End
__END__

=head1 NAME

BHSets - Perl extension for Bergmann-Hommel exhaustive set calculation


=head1 SYNOPSIS

  use BHSets qw( exhaustiveSets );

  my @sets = exhaustiveSets(4);


=head1 DESCRIPTION

Stub documentation for BHSets, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.


=head1 AUTHOR

Edgar Gonzàlez i Pellicer, E<lt>egonzalez@lsi.upc.eduE<gt>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Edgar Gonzàlez i Pellicer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
