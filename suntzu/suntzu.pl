#!/usr/bin/perl -w
use strict;

open SUN, "< suntzu.txt";
my @lines = <SUN>;
close SUN;


print $lines[ int( rand(@lines) ) ];

