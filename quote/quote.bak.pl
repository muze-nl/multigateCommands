#!/usr/bin/perl -w
# Simple and stupid quote database
# No file locking - race conditions possible - whatever :)
# Casper Joost Eyckelhof 2002

use strict;

my $quotefile = "./quotes.txt";

if ( $ARGV[0] =~ /^add (.*)$/i ) {
    open FOO, ">> $quotefile";
    print FOO "$1\n";
    close FOO;
    print "Quote added\n";
} else {

    #print random quote
    open MSG, "< $quotefile";
    my @opties = <MSG>;
    close MSG;
    my $antwoord = $opties[ int( rand(@opties) ) ];
    print $antwoord;
}
