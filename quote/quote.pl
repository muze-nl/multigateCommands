#!/usr/bin/perl -w
# Simple and stupid quote database
# No file locking - race conditions possible - whatever :)
# Casper Joost Eyckelhof 2002
# Keyword search by Wouter Commandeur
# "ls" option by Robbert Muller

use strict;

my $quotefile = "./quotes.txt";

my $eerste;
my $rest;
my $line;
my $is_multicast = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)

if ( $ARGV[0] ) { ( $eerste, $rest ) = split ' ', $ARGV[0], 2; }

if ( $eerste && $eerste eq "add" ) {
    open FOO, ">> $quotefile";
    print FOO "$rest\n";
    close FOO;
    print "Quote added\n";
} elsif ( $eerste && $eerste eq "count" ) {
    open MSG, "< $quotefile";
    my @opties = <MSG>;
    close MSG;
    if ($rest) {
        my @hits = grep /\Q$rest\E/i, @opties;
        print "Aantal quotes met \"$rest\" erin: " . scalar(@hits) . "\n";
    } else {
        print "Aantal quotes (totaal): " . scalar(@opties) . "\n";
    }
} elsif ( $eerste && $eerste eq "ls" ) {
    open MSG, "< $quotefile";
    my @opties = <MSG>;
    close MSG;
    if ($rest) {
        my @hits = grep /\Q$rest\E/i, @opties;
		  unless ( $is_multicast && ( scalar(@hits) > 3 ) ) {
			  print "Quotes met \"$rest\" erin:\n";
			  while($line = pop(@hits)){
				  print $line;
			  }
		  } else {
			  print "Use a query please\n";
		  }
    } else {
        print "Alle Quotes: " . scalar(@opties) . "\n";
		  if ( $is_multicast && ( scalar(@opties) > 3 ) ) {
			  while($line = pop(@opties)){
				  print $line;
			  }
		  } else {
			  print "Use a query please\n";
		  }
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
