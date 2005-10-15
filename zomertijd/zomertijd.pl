#!/usr/bin/perl -w

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time - 3600 );

printf( "Eigenlijk is het pas %02d:%02d.\n", $hour, $min );
