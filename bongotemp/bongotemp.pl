#!/usr/bin/perl
use strict;
use warnings;


my $line = `lynx -dump http://www.bonairewebcams.com/CurrentWeather.php | grep Temperature`;
#my $line = `lynx -dump http://weather.noaa.gov/weather/current/TNCB.html | grep "Temperature "`;

$line =~ m/\((\d+.\d+).*?\)/;
my $temp = $1;

#print substr($line,15)  ;;
print "Huidige weersituatie in tonytee's toekomstige achtertuin: " . $temp . " graden Celsius\n";;

sleep 1 ;

my $line2 = `lynx -dump http://weather.noaa.gov/weather/current/TNCB.html | grep "Sky conditions "`;
print  "En oja, het is er " . substr($line2,18) ;;


