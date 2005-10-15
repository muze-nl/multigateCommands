#!/usr/bin/perl -w

use strict;
use Date::Manip;

my ( $arg, $date, $base, $expr );

unless ( $arg = $ARGV[0] ) {
    print "usage: datecalc <date> [, <date calc expression>]\n";
    exit 0;
}

$arg =~ s/pizzaday/monday/g;
$arg =~ s/pizzadag/maandag/g;

if ( $arg =~ /,/ ) {
    ( $base, $expr ) = split /,/, $arg;
}

#
# First try plain english
#
if ($base) {
    $date = DateCalc( $base, $expr );
} else {
    $date = ParseDate($arg);
}

if ($date) {
    print UnixDate( $date, "%c" ), "\n";
    exit 0;
}

#
# When we get here english didn't work, so try Dutch
#

&Date_Init( 'Language=Dutch', 'DateFormat=non-US' );

if ($base) {
    $date = DateCalc( $base, $expr );
} else {
    $date = ParseDate($arg);
}

if ($date) {
    print UnixDate( $date, "%c" ), "\n";
    exit 0;
}

#
# That also didn't work, give up for now..
#

print "Unrecognised date\n";

