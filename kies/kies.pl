#!/usr/bin/perl

use strict;
use warnings;

my @choices = split " ", (defined $ARGV[0] ? $ARGV[0] : '');

if (@choices == 0 ) {
   print "Gebruik !janee\n";
} elsif (@choices == 1) {
   print "Wat dacht je zelf?\n";
} else {
   #more than 1 ;)
   print $choices[int(rand @choices)], "\n";
}