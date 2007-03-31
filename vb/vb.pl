#!/usr/bin/perl -w
use strict;

my %openingstijden = (
    "zondag"    => "21:00",
    "maandag"   => "21:00",
    "dinsdag"   => "21:00",
    "woensdag"  => "21:00",
    "donderdag" => "22:00",
    "vrijdag"   => "22:00",
    "zaterdag"  => "22:00"
);

my $thisday = ( 'zondag', 'maandag', 'dinsdag', 'woensdag', 'donderdag', 'vrijdag', 'zaterdag' )[ (localtime)[6] ];

if ( @ARGV && defined( $openingstijden{ lc( $ARGV[0] ) } ) ) {
    $thisday = lc( $ARGV[0] );
}

print "Op $thisday is de VB geopend vanaf $openingstijden{$thisday}.\n";
