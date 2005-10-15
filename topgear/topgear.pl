#!/usr/bin/perl -w
# Simple and stupid quote database
# No file locking - race conditions possible - whatever :)
# Casper Joost Eyckelhof 2002
# Keyword search by Wouter Commandeur

use strict;

my $quotefile = "./quotes.txt";

my $eerste;
my $rest;

if ( $ARGV[0] ) { ( $eerste, $rest ) = split ' ', $ARGV[0], 2; }

if ( $eerste && $eerste eq "add" ) {
    open FOO, ">> $quotefile";
    print FOO "$rest\n";
    close FOO;
    print "Quote added\n";
} else {

    #print random quote or if keywords find one
    open MSG, "< $quotefile";
    my @opties = <MSG>;
    close MSG;

    my @matching;

    if ( $eerste && !( $eerste eq "" ) ) {
        @matching = grep( /$eerste/i, @opties );
    }

    my $antwoord = "";

    if ( scalar(@matching) > 0 ) {
        $antwoord = $matching[ int( rand(@matching) ) ];
    } else {
        $antwoord = $opties[ int( rand(@opties) ) ];
    }
    print $antwoord;
}
