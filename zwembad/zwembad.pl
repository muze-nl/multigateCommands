#!/usr/bin/perl -w
use strict;

my %openingstijden = (
    "maandag"   => "11:00 - 18:00",
    "dinsdag"   => "11:00 - 18:00",
    "woensdag"  => "11:00 - 18:00",
    "donderdag" => "11:00 - 18:00",
    "vrijdag"   => "11:00 - 18:00",
    "zaterdag"  => "12:00 - 18:00",
    "zondag"    => "12:00 - 18:00",
);

my $thisday = ( 'zondag', 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag' )[ (localtime)[6] ];

if ( @ARGV && defined( $openingstijden{ lc( $ARGV[0] ) } ) ) {
    $thisday = lc( $ARGV[0] );
}

print "Op $thisday is het zwembad op de UT geopend om $openingstijden{$thisday}.\n";
