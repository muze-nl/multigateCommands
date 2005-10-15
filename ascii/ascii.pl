#!/usr/bin/perl -w

use strict;

my $what = shift;

if ( defined $what ) {
    if ( $what =~ /^0\d+$/ ) {
        $what = oct $what;
    } elsif ( $what =~ /^0x[0-9a-f]+$/i ) {
        $what = hex $what;
    } elsif ( $what =~ /^.$/ ) {
        print ord $what, "\n";
        exit;
    }
    if ( $what =~ /\d+/ ) {
        if ( $what > 32 and $what < 127 ) {
            print chr $what, "\n";
        } else {
            print "$what out of range \n";
        }
    }
}
