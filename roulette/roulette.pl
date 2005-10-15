#!/usr/bin/perl -w

use strict;

srand();

my $user = $ENV{'MULTI_REALUSER'};

my $raak = int( rand(6) );

print "Multilink pakt de six-shooter en stopt er een kogel in...\n";
print "Een flinke draai.. prrrrrrrrrrrrrrrr....\n";

my $wie = int( rand(2) );

my $i;

for ( $i = 0 ; $i < 6 ; $i++ ) {
    my $text = "Multilink richt het pistool op ";
    if ( $wie == 0 ) {
        $text .= "zichzelf en haalt de trekker over.\n";
    } else {
        $text .= $user . " en haalt de trekker over.\n";
    }
    $wie = ( $wie + 1 ) % 2;
    if ( $raak == $i ) {
        $text .= "*BANG* Game over.\n";
        print $text;
        exit(0);
    }
    $text .= "*CLICK*\n";

    print $text;

    #  sleep(1); 

}
