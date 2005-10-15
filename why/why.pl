#!/usr/bin/perl -w

use strict;

my ( $hour, $wday ) = (localtime)[ 2, 6 ];
my $surfstuk = ( ( $wday == 1 ) and ( ( $hour >= 18 ) and ( $hour < 20 ) ) );
my $magie = int( rand 4 ) == 0;

if ( $surfstuk and $magie ) {
    print "Surfnet maintenance window\n";
} else {
    my $excusefile = 'excuses';
    my @excuses;

    open( EF, $excusefile ) or die "can't open excuse file($excusefile)";
    @excuses = <EF>;
    print $excuses[ rand @excuses ];
}
