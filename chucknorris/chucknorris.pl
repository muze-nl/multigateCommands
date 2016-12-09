#!/usr/bin/perl -w
use strict;

my $number = 0;

if ( ( defined( $ARGV[0] ) ) && ( $ARGV[0] =~ /^(\d+)$/ ) ) {
    #nummertje gevraagd
    $number = $1;
}

#Inlezen file

open( FACTS, "< chucknorris.txt" );

my @facts;
my $count = 0;

while ( my $line = <FACTS> ) {
    chomp $line;
    $count++;
    push @facts, $line;
}

close FACTS;

if ( $number > 0 ) {
    if ( defined $facts[$number - 1] ) {
        #arg is gegeven en rule nummer $arg bestaat
        print $facts[$number - 1] ." ($number)";
    } else {
        print "Helaas bestaat $number niet, probeer een ander nummer tussen 1 en $count (incl).";
    }
} else {
    #pak random rule en print.
    $number = int( rand(@facts));
    print $facts[$number] .' (' . ($number + 1) . ')';
}
