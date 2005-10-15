#!/usr/bin/perl -w
# Converts euro's to guldens

my $koers = 2.20371;
my $euro;

if ( defined( $ARGV[0] ) ) {
    $euro = $ARGV[0];
    $euro =~ s/,/./;
} else {
    print "Geef bedrag dat je wilt omrekenen";
    exit 1;
}
if ( $euro =~ /^-?\d+\.?\d*$/ ) {
    my $a = sprintf( "%.2f", $euro * $koers );
    my $b = sprintf( "%.2f", $euro / $koers );
    print "$euro euro is $a gulden. $euro gulden is $b euro.";
} else {
    print "Snap alleen getallen...";
}
