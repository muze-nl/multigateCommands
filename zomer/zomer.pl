#!/usr/bin/perl -w
use strict;

open ZOMER, "< zomer.txt";
my @lines = <ZOMER>;
close ZOMER;


print $lines[ int( rand(@lines) ) ];

