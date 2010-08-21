#!/usr/bin/perl
# Berekent actuele wisselkoersen

use strict;
use warnings;

use Data::Dumper;
use List::MoreUtils qw( any );
use LWP::UserAgent;
use XML::Simple;

my $koersurl = "http://www.abnamro.nl/nl/adviesenrekenmodellen/valuta_centrum_euro_usd_noteringen/js/Euro.xml";

my $ua       = new LWP::UserAgent;
my $request  = new HTTP::Request( 'GET', $koersurl );
my $response = $ua->request($request);

unless ( $response->is_success ) {
    print "Er ging wat mis met het ophalen van $koersurl: " . $response->status_line . "\n";
    exit 1;
}

my $xml = $response->content;

my $ref = XMLin($xml, forcearray => [ 'countercurrency' ]);

#print Dumper($ref);
#exit 0;

my %tabel_code;
my %tabel_land;
my %tabel_valuta;

foreach my $rate ( @{$ref->{rate}} ) {
    #print Dumper($rate);
    my $code = $rate->{'isocode'};
    my $land = lc $rate->{'country_description'};
    my $valuta = lc $rate->{'currency_description'};
    my $koers;
    foreach ( @{$rate->{'countercurrency'}} ) {
        if ($_->{'isocode'} eq 'EUR' ) {
            $koers = $_->{'value'};
            #print "$code $land $valuta $koers\n";
        }
    }

    $tabel_code{$code} = [ $code, $land, $valuta, $koers ];
    $tabel_land{$land} = [ $code, $land, $valuta, $koers ];
    $tabel_valuta{$valuta} = [ $code, $land, $valuta, $koers ];
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
my ( $code, $land, $valuta, $bedrag );

if ( $commandline =~ /^(\d.*?)\s+(\w{3})$/ ) {
    $bedrag = $1;
    $code = uc($2);
} elsif ( $commandline =~ /^(\d.*?)\s+(.*?)$/ ) {
    $bedrag = $1;
    $land = lc($2);
} elsif ( $commandline =~ /^(\w{3})\s+(\d.*?)$/ ) {
    $code   = uc($1);
    $bedrag = $2;
} elsif ( $commandline =~ /^(\w*?)\s+(\d.*?)$/ ) {
    $land   = lc($1);
    $bedrag = $2;
} else {
    print "Geef landcode en bedrag dat je wilt omrekenen\n";
    exit 1;
}

if ( defined $code && defined $tabel_code{$code} ) {
    $koers = $tabel_code{$code}[3];
    $land  = $tabel_code{$code}[1];
    $valuta = $tabel_code{$code}[2];
    #print "Gevonden(1) $code , $bedrag, $koers, $land \n";
} elsif ( defined $land && defined $tabel_land{$land} ) {
    $koers = $tabel_land{$land}[3];
    $code  = $tabel_land{$land}[0];
    $valuta = $tabel_code{$code}[2];
    #print "Gevonden(2) $land , $bedrag, $koers, $code \n"
} elsif ( defined $land && defined $tabel_valuta{$land} ) {
    $valuta = $land;
    $koers = $tabel_valuta{$land}[3];
    $code  = $tabel_valuta{$land}[0];
    $land = $tabel_valuta{$land}[1];
    #print "Gevonden(3) $land , $bedrag, $koers, $valuta, $code \n"
} else {
    print "Snap landcode of land niet...\n";
    exit 1;
}


if ( ( $koers > 0 ) && ( $bedrag =~ /^-?\d+\.?\d*$/ ) ) {
    my $a = sprintf( "%.2f", $bedrag / $koers );
    my $b = sprintf( "%.2f", $bedrag * $koers );
    print "$bedrag $valuta ($code) is $a Euro. $bedrag Euro is $b $valuta ($code) ($land).\n";
} else {
    print "Sorry, snap iets niet, is het bedrag wel in cijfers?\n";
}
