#!/usr/bin/perl -w
use strict;

my %openingstijden = (
    "zondag"    => "14:00 - 17:00",
    "maandag"   => "11:45 - 14:00",
    "dinsdag"   => "11:45 - 14:00 en 16:00 - 18:00",
    "woensdag"  => "11:45 - 14:00 en 16:00 - 18:00",
    "donderdag" => "11:45 - 14:00 en 16:00 - 18:00",
    "vrijdag"   => "11:30 - 14:00 en 15:30 - 17:30",
    "zaterdag"  => "14:00 - 17:00"
);

my $thisday = ( 'zondag', 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag' )[ (localtime)[6] ];

if ( @ARGV && defined( $openingstijden{ lc( $ARGV[0] ) } ) ) {
    $thisday = lc( $ARGV[0] );
}

print "Op $thisday is het zwembad op de UT geopend om $openingstijden{$thisday}.\n";
