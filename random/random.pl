#!/usr/bin/perl
use strict;

my $nr;

if ( $ARGV[0] =~ /^(\d+)$/ ) {
    $nr = $1;
} else {
    $nr = 100;
}

print int( rand($nr) ), "\n";
