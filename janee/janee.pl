#!/usr/bin/perl -w
# DND's eigen orakel, nu met statistieken.
# Schubi: ik gebruik nu ook een if :(
# Er zijn racecondities te verzinnen volgens mij... jammer dan
# Copyright Casper Joost Eyckelhof

use strict;

$| = 1;

my @keuzes   = qw (ja nee);
my $histfile = "/home/multilink/multigate/commands/janee/history.txt";
open HIST, "< $histfile";
my $line = <HIST>;
my ( $ja, $nee ) = split /\s/, $line, 2;
close HIST;

chomp $nee;

if ( @ARGV && ( $ARGV[0] =~ /^stats?$/ ) ) {

    #We willen statistieken hebben
    #Eerst percentages
    my $jap  = sprintf( "%.2f", ( $ja / ( $ja + $nee ) ) * 100 );
    my $neep = sprintf( "%.2f", 100 - $jap );                       #tenminste geen zichtbare afrondfouten :)
    print "ja: $ja ($jap\%), nee: $nee ($neep\%)\n";

} else {

    #Geen statistieken, maar orakelen!
    #Eerst antwoord bepalen:
    my $antwoord = $keuzes[ int( rand(2) ) ];
    print "$antwoord\n";

    #toevoegen aan statistiek
    if ( $antwoord eq $keuzes[0] ) {
        $ja++;
    } else {
        $nee++;
    }

    #schrijven naar disk (jaja, geen locking enzo. Bad Titan!):
    open HIST, "> $histfile" or die ("cannot open histfile");
    print HIST "$ja $nee\n";
    close HIST;

    # En speciaal voor Wouter:
    if ( int( rand(100) ) == 42 ) {    #in 1% van de gevallen
        sleep(2);
        print "Oh wacht! Ik vergis me! Het moet ";
        if ( $antwoord eq $keuzes[0] ) {
            print "nee";
        } else {
            print "ja";
        }
        print " zijn.\n";
    }
}
