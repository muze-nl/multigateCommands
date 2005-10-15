#!/usr/bin/perl -w

open( MSG, "< fool.txt" );
my @opties = <MSG>;
close MSG;

my $antwoord = $opties[ int( rand(@opties) ) ];
print "$antwoord";
