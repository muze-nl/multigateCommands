#!/usr/bin/perl -w 

# Script om in de televisie van vandaag te zoeken
# Geschreven in het kader van DND Progathon 2000
# Copyright: Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl
#
# Gebaseerd op v1.0 door Ylebre en Titanhead
# v2.0: 16 Januari 2000; gegevens van multiguide
# v2.1: 19 Januari 2000; commandline paramater "film"
# v3.0: 28 Juni 2001; zoek in lokale cache, gemaakt met tvdump
# v3.1: 28 Augustus 2001; snapt ook zender als argument (wat is er nu op zender?)
# v4.0: 25 Februari 2002; nog meer commandline opties + slimmer sorteren
# v4.1: 13 Augustus 2004; grapje met "iets leuks"

#### allerlei fijne definities en initialisaties ########
use strict;

my $maxoutput = 25;
my $aantal    = 5;
my $aantalset = 0;

my $filmzoeken = 0;
my $nuoptv     = 0;
my $straksoptv = 0;
my $tijdstip;
my $dummy;

my @output  = ();
my $datadir = "./data";

my $is_multicast = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)

## Welke zenders zijn beschikbaar?
my %zenders;
opendir( BIN, $datadir ) or die "Can't open $datadir: $!";
while ( defined( my $file = readdir BIN ) ) {
    if ( ( -T "$datadir/$file" ) && ( -s "$datadir/$file" ) ) {
        $zenders{ lc($file) } = $file;
    }    #hash from lowercase to realname
}
close BIN;

# alles dat in de "tv nu" getoond moet worden
my @nuzenderlijst = qw(Nederland1 Nederland2 Nederland3 RTL4 RTL5 SBS6 Net5 Yorin BBC1 BBC2 Veronica);

my %aliases = (
    "ned1"    => "nederland1",
    "ned2"    => "nederland2",
    "ned3"    => "nederland3",
    "brt1"    => "vrt_tv1",
    "tv1"     => "vrt_tv1",
    "belgie1" => "vrt_tv1",
    "ketnet"  => "ketnet_canvas",
    "canvas"  => "ketnet_canvas",
    "brt2"    => "ketnet_canvas",
    "v8"      => "veronica",
    "fox"     => "veronica",
    "disc"    => "discovery",
    "rtlvijf" => "rtl5",
    "rtlvier" => "rtl4"
);

my %nulijst = ();
my $item;
foreach $item (@nuzenderlijst) {
    $nulijst{ lc($item) } = 1;
}

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
    my ( $nuzender, $nutijd, $nuaantal ) = @_;

    print STDERR "nu: ($nuzender, $nutijd, $nuaantal )\n";

    $nutijd =~ /(\d+)\.(\d+)/;
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
        $ftijd =~ /(\d+)\.(\d+)/;
        my ( $fhour, $fminute ) = ( $1, $2 );
#        if ( $fhour < 6 ) { $fhour += 24; }
        if ( ( ( ( $fhour < $nuhour ) || ( ( $fhour == $nuhour ) && ( $fminute < $numinute ) ) ) ) ) {
            print STDERR "Bewaren als laatste regel: $ftijd, $film, $lnaam, $beschrijving, $prut\n";
            #bewaar gegevens als vorige regel
            ( $vftijd, $vfilm, $vlnaam, $vbeschrijving, $vprut ) = ( $ftijd, $film, $lnaam, $beschrijving, $prut );
        } else {
            $found++;
            print STDERR "found, nuaantal = $found, $nuaantal\n"; 
            #vorige was wat we zochten
            if ( $found <= $nuaantal ) {
                if ( $found == 1 ) {
                    push @out, "$vftijd $vlnaam";
                    $laatste = "$vftijd $vlnaam";
                    if ( $nuaantal > 1 ) {    #en meteen de huidige ook, anders verdwijnt die volgende loop
                        $found++;
                        push @out, "$ftijd $lnaam";
                        $laatste = "$ftijd $lnaam";
                    }
                } else {
                    push @out, "$ftijd $lnaam";
                    $laatste = "$ftijd $lnaam";
                }
            }
        }
    }

    #laatste programma:
    if ( ( $found < $nuaantal ) && ( not( "$ftijd $lnaam" eq $laatste ) ) ) {
        push @out, "$ftijd $lnaam (eindtijd onbekend)";
    }
    print STDERR "OUT = " , join(' : ', @out);
    return (@out);
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
    my ( $uura, $minuuta ) = split /\./, $tijda;
    my ( $uurb, $minuutb ) = split /\./, $tijdb;

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
            if ( ( $lnaam =~ /\Q$zoekterm\E/i ) && ( $lnaam !~ /Trekking/i ) ) {
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

if ( ( @ARGV == 0 ) || ( $ARGV[0] eq "" ) ) {
    print "tv <zoekterm> doet het beter.\n";
} else {
    my $zoekstring = $ARGV[0];

    # Preprocessing for special stuff
    if ($zoekstring =~ /^iets leuks$/i) {
         my @opties = keys %zenders;
         $zoekstring = $opties[ int rand @opties ];  # random zender
    }


    ## Extra goodies/opties uit $zoekstring halen

    if ( $zoekstring =~ /^(.*?\s*)(\d{1,2}[.:]\d{2})\s*(.*?)$/ ) {
        $zoekstring = $1 . " " . $3;
        $tijdstip   = $2;
        $tijdstip =~ s/:/./;

        # We doen dus alsof het nu een andere tijd is:
        # Jaja, bah bah, globaal (maar anders kan sort er niet bij)

        ( $thishour, $thisminute ) = split /\./, $tijdstip, 2;

        #0 tot 6 wordt 24 tot 30
        if ( $thishour < 6 ) {
            $thishour += 24;
        }

        if ( $zoekstring =~ /^\s*$/ ) {
            $nuoptv = 1;
        }    #alleen een tijd, verder niks
    }

    if ( $zoekstring =~ /^(.*?)\s(\d+)$/ ) {
        $zoekstring = $1;
        $aantal     = min2( $2, $maxoutput );
        $aantalset  = 1;
    }

    if ( $zoekstring =~ /^film\s*(.*?)$/i ) {
        $filmzoeken = 1;
        $zoekstring = $1;
    }

    #remove trailing and prefix whitespace 
    $zoekstring =~ s/^\s+//;
    $zoekstring =~ s/\s+$//;

    if ( lc($zoekstring) eq "nu" ) {
        $nuoptv = 1;
    }

    if ( lc($zoekstring) eq "straks" ) {
        $straksoptv = 1;
    }

    if ( defined( $aliases{ lc($zoekstring) } ) ) {
        $zoekstring = $aliases{ lc($zoekstring) };
    }

    ## Alle opties zijn uit de zenderstring gehaald, er zit nu nog in:
    #  zender of zoekterm

    if ( $nuoptv || ( $straksoptv && ( defined $tijdstip ) ) ) {
        my $tijdzoek = "$thishour.$thisminute";
        if ( defined $tijdstip ) {
            $tijdzoek = $tijdstip;
        }
        foreach (@nuzenderlijst) {
            if ( isZender($_) ) {
                my @result = nu( $_, $tijdzoek, 2 );
                my ( $tijd,  $prog )  = split /\s/, $result[0], 2;
                my ( $tijd2, $dummy ) = split /\s/, $result[1], 2
                  if ( defined $result[1] );
                $tijd2 = '??.??' unless defined $tijd2;
                push @output, "$_: $tijd - $tijd2 $prog", if defined($prog);
            }
        }
    } elsif ($straksoptv) {
        my $tijdzoek = "$thishour.$thisminute";
        if ( defined $tijdstip ) {
            $tijdzoek = $tijdstip;
        }
        foreach (@nuzenderlijst) {
            if ( isZender($_) ) {
                my @result = nu( $_, $tijdzoek, 3 );
                my ( $tijd, $prog ) = split /\s/, $result[1], 2,
                  if ( defined $result[1] );
                my ( $tijd2, $dummy ) = split /\s/, $result[2], 2,
                  if ( defined $result[2] );
                $tijd2 = '??.??' unless defined $tijd2;
                push @output, "$_: $tijd - $tijd2 $prog", if defined($prog);
            }
        }
    } elsif ($filmzoeken) {
        push @output, films($aantal);    #veel logica is sub films zelf
    } elsif ( isZender($zoekstring) ) {
        my $tijd = "$thishour.$thisminute";
        if ( defined $tijdstip ) {
            $tijd = $tijdstip;
        }
        $aantal = 1 unless $aantalset;
        my @tussenresult = nu( $zoekstring, $tijd, $aantal + 1 );
        my $i;

        #for ($i=0; $i < max2( (@tussenresult-1), $aantal); $i++) {
        for ( $i = 0 ; $i < min2( scalar(@tussenresult), $aantal ) ; $i++ ) {
            my ( $tijd, $prog ) = split /\s/, $tussenresult[$i], 2;
            my $tijd2;
            if ( defined( $tussenresult[ $i + 1 ] ) ) {
                ( $tijd2, $dummy ) = split /\s/, $tussenresult[ $i + 1 ], 2;
            } else {
                $tijd2 = '??.??';
            }
            push @output, "$tijd - $tijd2: $prog", if ( defined $prog );
        }
    } else {

        # "Gewone" zoekterm
        push @output, zoek( $zoekstring, $aantal );
    }

    # ANTISPAM: Exit if multicast and > 3 lines
    if ( $is_multicast && ( @output > 3 ) ) {
        exit 0;
    }

    ### Afdrukken uitvoer ###
    foreach (@output) {
        print "$_\n";
    }

    # Geen uitvoer...
    if ( @output == 0 ) {
        print "Geen programma's gevonden\n";
    }

}
