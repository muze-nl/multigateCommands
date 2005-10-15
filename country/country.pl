#! /usr/bin/perl -w
# my first command
# all rights Sjoerd van Tongeren

open( LIJST, "< lijst" ) or die "kan lijst niet openen$!\n";
$frop = lc( $ARGV[0] );

$frop =~ s/^\s*\.//;
$frop =~ s/\s+$//;

while ( $line = <LIJST> ) {
    ( $code1, $land1 ) = split ( " ", $line, 2 );
    $code1 =~ s/^\.//;
    $land1 =~ s/\n//;
    $land1 =~ s/\s+$//;
    $land1 = lc($land1);
    $land{$code1} = $land1;
    $code{$land1} = $code1;
}

if ( defined( $land{$frop} ) ) {
    print "Het land is : $land{$frop}\n";
} elsif ( defined( $code{$frop} ) ) {
    print "De landcode is: $code{$frop}\n";
} else {
    print "Bestaat niet\n";
}

