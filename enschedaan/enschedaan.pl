#!/usr/bin/perl

use warnings;
use strict;
use Date::Manip;

#Op 1 april verhuist Daan!
my $daandate = "1 April 2010";

my $err;
my $delta = DateCalc("today",$daandate,\$err,1);

my $sign;
#YY:MM:WK:DD:HH:MM:SS
if ( $delta =~ m/^([+-])(.*)$/ ) {
  $sign = $1; 
  $delta = $2;
} else {
  die "Invalid delta: $delta\n";
}  

my ($year, $month, $week, $day, $hour, $minute, $second) = split ':', $delta;
if ($sign eq '+') {
   print "Daan komt over $month " . ($month > 1 ? "maanden" : "maand") . 
                      ", $week "  . ($week  > 1 ? "weken"   : "week")  .
                      ", $day "   . ($day   > 1 ? "dagen"   : "dag")   . 
                      " en $hour uur naar Enschede\n";
} else {
  print "Daan is al in Enschede!\n";
  print "($year jaar, $month " . ($month > 1 ? "maanden" : "maand") .
        ", $week "  . ($week  > 1 ? "weken"   : "week")  .
        ", $day "   . ($day   > 1 ? "dagen"   : "dag")   .
        " en $hour uur)\n";
}   