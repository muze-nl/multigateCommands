#!/usr/bin/perl -w

use strict;

if ( !$ARGV[0] =~ /\d+/ ) {
    print "Syntax: roman <number>\n";
    exit(1);
}

my $num    = $ARGV[0];
my @vals   = ( 1000, 100, 10, 1 );
my @units  = ( "M", "C", "X", "I" );
my @fives  = ( "?", "D", "L", "V" );
my $result = "";

if ( ( $num < 1 ) || ( $num > 3999 ) ) {
    print "Number must be in the range 1 - 3999\n";
    exit(1);
}

for ( my $i = 0 ; $i < 4 ; $i++ ) {
    my $val = $vals[$i];
    my $mod = $num % $val;
    my $div = ( $num - $mod ) / $val;
    for ($div) {
        /1/ && do { $result .= $units[$i] x 1; last; };
        /2/ && do { $result .= $units[$i] x 2; last; };
        /3/ && do { $result .= $units[$i] x 3; last; };
        /4/ && do { $result .= $units[$i] x 1 . $fives[$i] x 1; last; };
        /5/ && do { $result .= $fives[$i] x 1; last; };
        /6/ && do { $result .= $fives[$i] x 1 . $units[$i] x 1; last; };
        /7/ && do { $result .= $fives[$i] x 1 . $units[$i] x 2; last; };
        /8/ && do { $result .= $fives[$i] x 1 . $units[$i] x 3; last; };
        /9/ && do { $result .= $units[$i] x 1 . $units[ $i - 1 ] x 1; last; };
    }
    $num = $mod;
    last if ( $num == 0 );
}

print "$result\n";
