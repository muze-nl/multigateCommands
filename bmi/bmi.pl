#!/usr/bin/perl -w
# Bepaalt Body Mass Index

use strict;

my ( $lengte, $gewicht, $stuff ) = split ' ', $ARGV[0], 3
  if ( defined $ARGV[0] );

unless ( ( defined $lengte ) && ( defined $gewicht ) && ( $lengte =~ /^\d+$/ ) && ( $gewicht =~ /^\d+$/ ) ) {
    print "Geef lengte in hele cm en gewicht in kg\n";
    exit 0;
}

$lengte /= 100;    #in meters
my $bmi = $gewicht / ( $lengte * $lengte );

my $result = "Te mager";

$result = "Goed gewicht"  if ( $bmi >= 20 );
$result = "Te zwaar"      if ( $bmi > 25 );
$result = "Veel te zwaar" if ( $bmi > 30 );

printf( "BMI: %.1f ==> %s\n", $bmi, $result );
