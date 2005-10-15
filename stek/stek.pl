#!/usr/bin/perl -w
# Geeft de hap van de stek aan, van de huidige datum
# Herschreven na een "update" van de FB website (Yuck!)
# titanhead, 22 September 2001

use strict;
my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);

if ( ( $wday == 0 ) || ( $wday == 6 ) ) {
    print "Stek is gesloten in het weekend.";
    exit 0;
}

my $vrijdag = ( localtime( time + ( ( 5 - $wday ) * 60 * 60 * 24 ) ) )[3];
my $maandag = ( localtime( time + ( ( 1 - $wday ) * 60 * 60 * 24 ) ) )[3];

#my @html       = `lynx -dump "http://www.utwente.nl/fb/docs/Hap-aan-de-Tap.doc/"`;
#my @html       = `lynx -dump "http://weblx030.civ.utwente.nl/diensten/fb/catering/stec/hap-aan-de-tap.doc/_printableversion.html"`;
#my @html       = `lynx -dump "http://www.utwente.nl/fb/catering/stek/de_stekwk_14.doc/_printableversion.html"`;
my @html        = `lynx -dump -nolist "http://www.utwente.nl/fb/catering/stek/hap-aan-de-tap.doc/_printableversion.html"`;
my $menu        = "";
my $daggevonden = 0;

#   De Stek; Hap a/d Tap
#   Gyrossteak met zazikisaus
#   Superhap
#   Spies onwies
#   ! Cinestekkaarten



foreach my $regel (@html) {
#    print STDERR "-->$regel\n";
    if ( ( $regel =~ /Vrijdag $vrijdag /i ) || ( $regel =~ /Maandag $maandag /i ) || ( $regel =~ m|\s*De Stek|i ) ) {
        $daggevonden = 1;
#        print STDERR "Begin gevonden\n";
    }

    if ($daggevonden) {
        if ( $regel =~ /^\s*!/ ) { $daggevonden = 0; last; }
        if ( $regel =~ /Cinestekkaarten/i ) { $daggevonden = 0; last; }
        $menu .= "$regel , ";
    }
}
$menu =~ s/\s{2,}/ /g;
$menu =~ s/\s,/,/g;
$menu =~ s/,+\s*$//g;
$menu =~ s/^\s*//;
$menu =~ s/,+/,/g;
$menu =~ s/\.,/./g;
$menu =~ s/EUR \d+,\d+//g;

if ($menu and $menu ne "") {
   print $menu;
} else {
   print "Geen menu gevonden. Stek vandaag gesloten?\n";
}   
