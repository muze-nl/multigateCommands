#!/usr/bin/perl -w
use strict;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my @args = split ' ', $commandline;
my @newargs = ();
my $temp;
my $length = 9;

foreach $temp (@args) {
    if ( $temp eq "-n" || $temp eq "-c" || $temp eq "-s" ) {
        push @newargs, $temp;
    } elsif ( $temp =~ /^[0-9]+$/ ) {
        $length = $temp;
    }
}

if ( $length < 3 ) {
    $length = 3;
}

if ( int( rand(100) ) == 42 ) {   #in 1% van de gevallen
    print "frop";
} else {
    system( "./pwgen", @newargs, $length, 1 );
}
