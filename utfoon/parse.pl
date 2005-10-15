#!/usr/bin/perl -w

open FOO, "< acasalijst.txt";
my @frop = <FOO>;
close FOO;

map { s/\n//g } @frop;
map { s/\s{2]/ /g } @frop;

while (@frop) {
    my $adres  = shift @frop;
    my $nummer = shift @frop;
    print "$nummer:$adres\n";
}

