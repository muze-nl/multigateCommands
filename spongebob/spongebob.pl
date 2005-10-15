#!/usr/bin/perl -w
use strict;

open SPONGEBOB, "< spongebob.txt";
my @lines = <SPONGEBOB>;
close SPONGEBOB;


print $lines[ int( rand(@lines) ) ];

