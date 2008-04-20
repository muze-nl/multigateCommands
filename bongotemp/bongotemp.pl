#!/usr/bin/perl
use strict;
use warnings;

my $line = `lynx -dump http://www.bonairewebcams.com/CurrentWeather.php | grep Temperature`;

$line =~ m/\((\d+.\d+).*?\)/;
my $temp = $1;

print "Huidige weersituatie in tonytee's toekomstige achtertuin: " . $temp . " graden Celsius\n";;