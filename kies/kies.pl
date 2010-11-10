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
   # normally, we expect the chance of '!kies a a a b' to return an 'a' to be around 75%. let's invert that! ;-)
   # 3 a's, 1 b  -->  'a' has weight 1/3, 'b' has weight 1
   # this means: 25% chance we will return an 'a', 75% chance we will return a 'b'.
   my %choices;
   map { $choices{$_}++ } @choices;
   my $sum = 0;
   map { $sum += 1 / $_ } values %choices;
   my $choice = rand $sum;
   $sum = 0;
   foreach my $key (keys %choices) {
      $sum += 1 / $choices{$key};
      if ($sum >= $choice) {
         print $key, "\n";
         exit 0;
      }
   }

   # this should not happen. apparently, rand($sum) > $sum..
   # let's keep the old code as backup
   print $choices[int(rand @choices)], "\n";
}
