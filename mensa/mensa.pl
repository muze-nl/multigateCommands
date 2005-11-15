#!/usr/bin/perl -w
# Geeft mensa menu
# Nieuwe versie van 22 sept 2001, omdat FB een lelijke nieuwe website heeft
# "Crude but effective" (en dus lelijk)
# Titanhead

use strict;

my $day = `date +%a`;
$day =~ s/\n//g;

my $num = `date +%d`;
$num =~ s/\n//g;

my $dag    = "frop";
my $morgen = "frop";

if ( index( $day, "Sun" ) == 0 ) { $dag = "Zondag";    $morgen = "Maandag"; }
if ( index( $day, "Mon" ) == 0 ) { $dag = "Maandag";   $morgen = "Dinsdag"; }
if ( index( $day, "Tue" ) == 0 ) { $dag = "Dinsdag";   $morgen = "Woensdag"; }
if ( index( $day, "Wed" ) == 0 ) { $dag = "Woensdag";  $morgen = "Donderdag"; }
if ( index( $day, "Thu" ) == 0 ) { $dag = "Donderdag"; $morgen = "Vrijdag"; }
if ( index( $day, "Fri" ) == 0 ) { $dag = "Vrijdag";   $morgen = "Zaterdag"; }
if ( index( $day, "Sat" ) == 0 ) { $dag = "Zaterdag";  $morgen = "Zondag"; }

my @html = `lynx -dump -nolist "http://zulu.student.utwente.nl/peter/mensa/mensa.txt"`;

my $line;
my $daggevonden  = 0;
my $menu;
my $xx;

foreach $line (@html) {
    #print STDERR "--> $line\n";
    if ( $line =~ /dagmenu $dag/i ) {
        $daggevonden = 1;
       $xx = 0;
    }

    if ( $daggevonden and ( $line =~ /$morgen/  or $line =~ /dagsoepen/i or $line =~ /menu of the day/i ) ) {
       last; 
    }
    if ( $daggevonden ) {
    $xx++;
       if($xx >  1) {
       		$line =~ s/\n//;
	}
       $menu .= $line;
    }

}

$menu =~ s/\s{2,}/ /g;
$menu =~ s/\s,/,/g;
$menu =~ s/,+\s*$//g;
print $menu , "\n";
