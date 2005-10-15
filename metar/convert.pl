#!/usr/bin/perl -w

use strict;

open LIST, "<CODES";

my $country = "none";

while ( my $line = <LIST> ) {
    chomp $line;
    if ( $line =~ /^-(.*)$/ ) {
        $country = $1;

        #print "Country: $country\n";
    } elsif ( $line =~ /^ (\w{4}) -> (.*)$/ ) {
        print "$1 $2 ($country)\n";

    }

}
