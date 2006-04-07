#!/usr/bin/perl -w 

# casper@joost.student.utwente.nl

#### allerlei fijne definities en initialisaties ########
use strict;

my $tijdstip;
my $dummy;

my @output  = ();
my $datadir = "../tv/data";

## Welke zenders zijn beschikbaar?
my %zenders;
opendir( BIN, $datadir ) or die "Can't open $datadir: $!";
while ( defined( my $file = readdir BIN ) ) {
    if ( ( -T "$datadir/$file" ) && ( -s "$datadir/$file" ) ) {
        $zenders{ lc($file) } = $file;
    }    #hash from lowercase to realname
}
close BIN;

my %aliases = (
    "ned1"    => "nederland1",
    "ned2"    => "nederland2",
    "ned3"    => "nederland3",
    "brt1"    => "vrt_tv1",
    "tv1"     => "vrt_tv1",
    "belgie1" => "vrt_tv1",
    "v8"      => "fox",
    "vacht"   => "fox",
    "disc"    => "discovery",
    "rtlvijf" => "rtl5",
    "rtlvier" => "rtl4"
);

my $thishour   = int( (localtime)[2] );
my $thisminute = int( (localtime)[1] );

#0 tot 6 wordt 24 tot 30
if ( $thishour < 6 ) {
    $thishour += 24;
}

####### Handige subjes :) #########

#
# nu(zender, tijd, aantal) 
# geeft voor zender de huidige en volgende aantal-1 programma's
# 

sub nu {
    my ( $nuzender, $nutijd ) = @_;

    #print STDERR "nu: ($nuzender, $nutijd, $nuaantal )\n";

    $nutijd =~ /(\d+)[\.:](\d+)/;
    my ( $nuhour, $numinute ) = ( $1, $2 );
    if ( $nuhour < 6 ) { $nuhour += 24 }

    ##Haal "pagina" voor nuzender op
    $nuzender = $zenders{ lc($nuzender) };
    open( ZENDER, "< $datadir/$nuzender" ) or die "Cannot open $nuzender\n";
    my @lines = <ZENDER>;
    close ZENDER;

    my ( $ftijd,  $film,  $lnaam,  $beschrijving,  $prut );     #buffer voor "huidige regel"
    my ( $vftijd, $vfilm, $vlnaam, $vbeschrijving, $vprut );    #buffer voor "vorige regel"
    my $found = 0;
    my @out;
    my $line;
    my $laatste = "opdezestringmatchtechtniksQWERTY";
    foreach $line (@lines) {
        ( $ftijd, $film, $lnaam, $beschrijving, $prut ) = split /\xb6/, $line;
        $ftijd =~ /(\d+)[\.:](\d+)/;
        my ( $fhour, $fminute ) = ( $1, $2 );
        if ( $fhour < 6 ) { $fhour += 24; }
        if ( ( ( ( $fhour < $nuhour ) || ( ( $fhour == $nuhour ) && ( $fminute < $numinute ) ) ) ) ) {

            #bewaar gegevens als vorige regel
            ( $vftijd, $vfilm, $vlnaam, $vbeschrijving, $vprut ) = ( $ftijd, $film, $lnaam, $beschrijving, $prut );
        } else {
            $found++;

            #vorige was wat we zochten
            return "$vlnaam: $vbeschrijving";
        }
    }

    #laatste programma:
    if ( ( $found < 2 ) && ( not( "$ftijd $lnaam" eq $laatste ) ) ) {
        return "$vlnaam: $vbeschrijving";
    }

}

sub max2 {
    my ( $a, $b ) = @_;
    if ( $a > $b ) {
        return $a;
    } else {
        return $b;
    }
}

sub min2 {
    my ( $a, $b ) = @_;
    if ( $a < $b ) {
        return $a;
    } else {
        return $b;
    }
}

#
# Speciaal om op tijd te sorteren. Wil een tijd in 2e veld van $a en $b
#
sub bytime {
    my ( $frop,  $tijda, $frop2 ) = split /\s/, $a, 3;
    my ( $frop3, $tijdb, $frop4 ) = split /\s/, $b, 3;
    my ( $uura, $minuuta ) = split /[\.:]/, $tijda;
    my ( $uurb, $minuutb ) = split /[\.:]/, $tijdb;

    if ( $uura < 6 ) { $uura += 24 }
    if ( $uurb < 6 ) { $uurb += 24 }

    #verzin een score verloop... (kan beter :)
    my ( $ascore, $deltaa, $bscore, $deltab );

    #Verschil in minuten tussen nu en (a , b)
    $deltaa = ( 60 * $uura + $minuuta ) - ( 60 * $thishour + $thisminute );
    $deltab = ( 60 * $uurb + $minuutb ) - ( 60 * $thishour + $thisminute );

    if ( $deltaa >= 0 ) {
        $ascore = 20 - ( $deltaa / 18 );    #20 - 1/18 t
    } else {
        $ascore = 20 + ( $deltaa / 6 );    #20 + 1/6 t
        if ( $deltaa < 60 ) {
            $ascore -= 10;
        }
    }

    if ( $deltab >= 0 ) {
        $bscore = 20 - ( $deltab / 18 );
    } else {
        $bscore = 20 + ( $deltab / 6 );
        if ( $deltab < 60 ) {
            $bscore -= 10;
        }

    }

    return $bscore <=> $ascore;
}

#
# Geeft een gesorteerde lijst met n films van alle zenders
#

sub films {
    my $aantal = shift;
    my $zender;
    my @resultlist;
    foreach $zender ( values %zenders ) {
        open( ZENDER, "< $datadir/$zender" );
        my @lines = <ZENDER>;
        close ZENDER;
        my $line;
        foreach $line (@lines) {
            my ( $ftijd, $film, $lnaam, $beschrijving, $prut ) = split /\xb6/, $line;
            if ( $film eq "F" ) {
                push @resultlist, "$zender: $ftijd $lnaam";
            }
        }
    }
    my @sortedresult = sort { bytime } @resultlist;
    return ( splice @sortedresult, 0, $aantal );
}

#
# Geeft een gesorteerde lijst met n programma's van alle zenders
# Voldoend aan zoekterm
#

sub zoek {
    my ( $zoekterm, $aantal ) = @_;
    my $zender;
    my @resultlist;
    foreach $zender ( values %zenders ) {
        open( ZENDER, "< $datadir/$zender" );
        my @lines = <ZENDER>;
        close ZENDER;
        my $line;
        foreach $line (@lines) {
            my ( $ftijd, $film, $lnaam, $beschrijving, $prut ) = split /\xb6/, $line;
            if ( ( $lnaam =~ /$zoekterm/i ) && ( $lnaam !~ /Trekking/i ) ) {
                push @resultlist, "$zender: $ftijd $lnaam";
            }
        }
    }
    my @sortedresult = sort { bytime } @resultlist;
    return ( splice @sortedresult, 0, $aantal );
}

sub isZender {
    my $zender = shift;
    foreach ( keys %zenders ) {
        if ( $_ eq lc($zender) ) { return 1; }
    }
    return 0;
}

my $zoekzender = $ARGV[0];
if ( defined( $aliases{ lc($zoekzender) } ) ) {
    $zoekzender = $aliases{ lc($zoekzender) };
}

unless ( ( defined $zoekzender ) && isZender($zoekzender) ) {
    print "Welke zender zei je?\n";
    exit 0;
}

#0 tot 6 wordt 24 tot 30
if ( $thishour < 6 ) {
    $thishour += 24;
}

my $tijdzoek = "$thishour.$thisminute";

print nu( $zoekzender, $tijdzoek );

