#!/usr/bin/perl -w
open FOO, "parrot.txt";
my @quotes = <FOO>;
close FOO;
print $quotes[ int( rand(@quotes) ) ];
