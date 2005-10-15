#!/usr/bin/perl -w
use strict;

my $number = 0;

if ( ( defined( $ARGV[0] ) ) && ( $ARGV[0] =~ /(\d+)/ ) ) {

    #het is een nummertje
    $number = $1;
}

#Inlezen file

open( RULES, "< /home/multilink/multigate/commands/froa/froa.txt" );

my @rules;
my @numrules;

while ( my $line = <RULES> ) {
    chomp $line;
    push @rules, $line;

    my ( $nummer, $rule ) = split ( /\t/, $line );
    if ( $nummer =~ /(\d+)/ ) {
        $numrules[$nummer] = $rule;
    }
}

close RULES;

my ( $nummer, $rule ) = split ( /\t/, $rules[ int( rand(@rules) ) ] );

if ( $number > 0 ) {
    if ( defined $numrules[$number] ) {

        #arg is gegeven en rule nummer $arg bestaat
        print "Ferengi rule of acquisition #$number\n$numrules[$number]";
        exit 0;
    } else {
        print "That rule does not exist. According to rule number 266 it has to be\n";
    }
} else {
    if ( $nummer =~ /(\d+)/ ) {
        print "Ferengi rule of acquisition #$1\n";
    } else {
        print "A good ferengi should always remember this rule:\n";
    }
}

#pak random rule en print.
print $rule;
