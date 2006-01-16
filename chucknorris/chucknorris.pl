#!/usr/bin/perl -w
use strict;

my $number = 0;

if ( ( defined( $ARGV[0] ) ) && ( $ARGV[0] =~ /(\d+)/ ) ) {

    #het is een nummertje
    $number = $1;
}

#Inlezen file

open( FACTS, "< chucknorris.txt" );

my @facts;
my @numfacts;

while ( my $line = <FACTS> ) {
    chomp $line;
    push @facts, $line;
}

close FACTS;

my $rule = $facts[ int( rand(@facts) ) ];

#if ( $number > 0 ) {
#    if ( defined $numfacts[$number] ) {
#
#        #arg is gegeven en rule nummer $arg bestaat
#        print "$numfacts[$number]";
#        exit 0;
#    }
#}

#pak random rule en print.
print $rule;
