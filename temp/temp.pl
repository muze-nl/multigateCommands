#!/usr/bin/perl
#Geeft huidige weersituatie (default in twente, met parameters van andere weerstation)
#Gegevens van  http://www.knmi.nl/voorl/weer/aktueel.html
use strict;
my $plaats = "Twenthe";
if ( $ARGV[0] ) {
    $plaats = '';
    foreach my $argument (@ARGV) {
        $plaats .= $argument . " ";
    }
}
#my @html     = `lynx -dump http://www.knmi.nl/voorl/weer/aktueel.html`;
my @html     = `lynx -dump -nolist http://www.knmi.nl/actueel/index.html`;
my $result   = "onbekend";
my $gevonden = 0;
foreach my $regel (@html) {
    if ( $gevonden == 0 ) {
        if ( $regel =~ /$plaats/i ) {
            $result   = $regel;
            $gevonden = 1;
        }
    }
}
if ( $result =~ /niet ontvangen/i ) {
    print "Waarnemer weggewaaid\n";
    exit 0;
}

$result =~ s/^\s*//g;
$result =~ s/De\sBilt/DeBilt/ig;
$result =~ s/Den\sHelder/DenHelder/ig;
$result =~ s/Vliegveld//ig;
$result =~ /^(\w+)(.*?)\s+(-{0,1}\d{1,}\.\d).*?$/;
my @twente = ( $1, $2, $3 );
$plaats =~ s/\s{1,}$//g;
$twente[1] =~ s/\s{1,}$//g;
$twente[1] =~ s/^\s*//;

if ( $twente[1] !~ /\w+/ ) { $twente[1] = "geen waarneming"; }

if ( $plaats eq "Twenthe" ) {
    $plaats = "titan's ex-koelkast";

    #$plaats ="a6502's tijdelijke koelkast";
    my $temp = $twente[2];
    if ( $temp < -5 ) {
        $plaats = "titan's diepvries";
    } elsif ( $temp < 0 ) {
        $plaats = "titan's vriesvak";
    } elsif ( $temp > 29 ) {
        $plaats = "titan's sauna";
    } elsif ( $temp > 19 ) {
        $plaats = "titan's ex-balkon";
    }
}
if ($gevonden) {
    print "Huidige weersituatie te $plaats: $twente[1], $twente[2] graden. (Bron: KNMI)\n";
} else {
    print "Geen weerstation gevonden in $plaats.\n";
    exit 1; #no caching
}
