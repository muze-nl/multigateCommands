#!/usr/bin/perl -w
# Simple and stupid quote database
# No file locking - race conditions possible - whatever :)
# Casper Joost Eyckelhof 2002
# Keyword search by Wouter Commandeur
#
# Changed for recepies by CJ again ;)

use strict;

my $quotefile = "./quotes.txt";

my $user = $ENV{'MULTI_REALUSER'};

my $eerste;
my $rest;

if ( $ARGV[0] ) { ( $eerste, $rest ) = split ' ', $ARGV[0], 2; }

if ( $eerste && $eerste eq "add" ) {
    open FOO, ">> $quotefile";
    print FOO "$rest (idee van: $user)\n";
    close FOO;
    print "Idee toegevoegd\n";
} elsif ( $eerste && $eerste eq "count" ) {
    open MSG, "< $quotefile";
    my @opties = <MSG>;
    close MSG;
    if ($rest) {
        my @hits = grep /\Q$rest\E/i, @opties;
        print "Aantal eetideeen met \"$rest\" erin: " . scalar(@hits) . "\n";
    } else {
        print "Aantal eetideeen (totaal): " . scalar(@opties) . "\n";
    }
} else {

    #print random quote or if keywords find one
    open MSG, "< $quotefile";
    my @opties = <MSG>;
    close MSG;

    my @matching;

    if ( $eerste && !( $eerste eq "" ) ) {
        @matching = grep( /\Q$eerste\E/i, @opties );
    }

    my $antwoord = "";

    if ( scalar(@matching) > 0 ) {
        $antwoord = $matching[ int( rand(@matching) ) ];
    } else {
        $antwoord = $opties[ int( rand(@opties) ) ];
    }
    print $antwoord;
}
