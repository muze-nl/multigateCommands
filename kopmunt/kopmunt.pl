#!/usr/bin/perl -w
my @kopmunt = qw (kop munt);
if (rand(100) == 42) {
  print "kant\n";
} else {
  print $kopmunt[ int( rand(2) ) ], "\n";
}