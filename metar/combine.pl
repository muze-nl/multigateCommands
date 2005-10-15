#!/usr/bin/perl
use strict;

my %locations = ();
open CODES, "<icao.txt";
while ( my $line = <CODES> ) {
    chomp $line;
    my ( $code, $location ) = split ' ', $line, 2;
    $locations{$code} = $location;
}
close CODES;

open CODES, "<icao2.txt";
while ( my $line = <CODES> ) {
    chomp $line;
    my ( $code, $location ) = split ' ', $line, 2;
    $locations{$code} = $location;
}
close CODES;

foreach my $code ( sort keys %locations ) {
    print "$code $locations{$code}\n";

}
