#!/usr/bin/perl -w
use strict;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

if ($commandline eq '') {
  print "Hup! hup!\n";
  exit 0;
} 

my ($first, undef) = split ' ', $commandline, 2;

my $result;
foreach my $letter (split // , $first) {
   $result .= "we hebben een \U$letter, ";
}
$result = ucfirst($result);
$result =~ s/, $/.\n/;

print $result . "We hebben \U$first!!!\n";