#! /usr/bin/perl -w
# Just a gag, says something stupid with a eurovision theme
# On krejt's request :)

my $quotefile = "/home/multilink/multigate/commands/songfestival/quotes.txt";

open( QUOTEFILE, "< $quotefile" );
my @quotes = <QUOTEFILE>;
my $quote  = @quotes[ int( rand(@quotes) ) ];
close QUOTEFILE;

## If there is a string '@@@' in the quote, put a random number from 1 to 12 in it's place

my $points = int( rand(11) + 1 );

$quote =~ s/@@@/$points/g;

print $quote;
