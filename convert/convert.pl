#!/usr/bin/perl -w
# Berekent actuele wisselkoersen

use strict;

#Bouw 2 tabellen met de gegevens (1 met index landcode, 1 met index landnaam)
my $filenaam = "/home/multilink/multigate/commands/convert/koerstabel.txt";
my @page;
if ( ( -z $filenaam ) || ( !-e $filenaam ) ) {

    #@page = `lynx -dump http://www.abnamro.nl/ibs/valutacentrum/vvnlg.html`;
    #@page = `lynx -dump http://www.abnamro.nl/ibs/valutacentrum/eurovv.html`;
    @page = `lynx -dump http://www.abnamro.nl/interactie/nl/effecten/jsp/eur_vv.jsp`;
} else {
    my $file = open( FOO, "<$filenaam" );
    @page = <FOO>;
    close FOO;
}

my %tabel_code = ();
my %tabel_land = ();
my $line;

frop:
foreach $line (@page) {
    $line =~ s/,//g;
    #print $line, "\n";
    if ( $line =~ /^.*?(\S+)\s+(\w+)\s+(\w{3})\s+(.*?)\s+(\d+\.\d*?)\s(.*?)$/ ) {
        my ( $land, $eenheid, $code, $inkoop, $midden, $verkoop );
        $land    = $1;
        $eenheid = $2;
        $code    = $3;
        $midden  = $5;
        $verkoop = $6;
        $land =~ s/^\s+(.*)$/$1/;
        $land = lc($land);    #kleine letters
        $land =~ s/\xEB/e/g;
        my $factor = 1;

        #print STDERR "$land $code $midden\n";
        if ( $midden !~ /#/ ) {
            $tabel_code{$code} = [ $land, $midden / $factor ];
            $tabel_land{$land} = [ $code, $midden / $factor ];
        }

        #if ($land =~ /.*?zwitserland.*?/i ) { print STDERR "zwitserland\n"; last frop };
    }
}

#Bepaal wat we zoeken
my $commandline;
if ( defined( $ARGV[0] ) ) {
    $commandline = $ARGV[0];
    $commandline =~ s/,/./;
} else {
    print "Geef landcode en bedrag dat je wilt omrekenen";
    exit 1;
}

my $koers = 0;
my ( $code, $land, $bedrag );

if ( $commandline =~ /^(\w{3})\s+(.*?)$/ ) {
    $code   = uc($1);
    $bedrag = $2;
    if ( defined $tabel_code{$code} ) {
        $koers = $tabel_code{$code}[1];
        $land  = $tabel_code{$code}[0];

        #print "Gevonden(1) $code , $bedrag, $koers, $land \n";
    } else {
        print "Onbekende landcode.\n";
        exit 1;
    }
} elsif ( $commandline =~ /^(\w*?)\s+(\d.*?)$/ ) {
    $land   = lc($1);
    $bedrag = $2;
    if ( defined $tabel_land{$land} ) {
        $koers = $tabel_land{$land}[1];
        $code  = $tabel_land{$land}[0];

        #print "Gevonden(2) $land , $bedrag, $koers, $code \n"
    } else {
        print "Snap landcode of land niet...\n";
        exit 1;
    }
} else {
    print "Geef landcode en bedrag dat je wilt omrekenen\n";
    exit 1;
}

if ( ( $koers > 0 ) && ( $bedrag =~ /^-?\d+\.?\d*$/ ) ) {
    my $a = sprintf( "%.2f", $bedrag / $koers );
    my $b = sprintf( "%.2f", $bedrag * $koers );
    print "$bedrag $code is $a euro. $bedrag euro is $b $code ($land).\n";
} else {
    print "Sorry, snap iets niet, is het bedrag wel in cijfers?\n";
}
