#!/usr/bin/perl -w

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );

if($isdst == 0){
	( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time + 3600 );
	printf( "Het had ook %02d:%02d kunnen zijn.\n", $hour, $min );
} else {
	( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time - 3600 );
	printf( "Eigenlijk is het pas %02d:%02d.\n", $hour, $min );
}
