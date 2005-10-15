#!/usr/bin/perl 
# Script om in de televisie van vandaag te zoeken
# Geschreven in het kader van DND Progathon 2000
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl
#
# Gebaseerd op v1.0 door Ylebre en Titanhead
# v2.0: 16 Januari 2000; gegevens van multiguide
# v2.1: 19 Januari 2000; commandline paramater "film"
# v3.0: 28 Juni 2001; zoek in lokale cache, gemaakt met tvdump
# v3.1: 28 Augustus 2001; snapt ook zender als argument (wat is er nu op zender?)

#### allerlei fijne definities en initialisaties ########

$maxoutput = 5;
@output    = ();
$datadir   = "/home/multilink/multigate/commands/tv2/data";

$thishour   = int( (localtime)[2] );
$thisminute = int( (localtime)[1] );

#0 tot 6 wordt 24 tot 30
if ( $thishour < 6 ) {
    $thishour += 24;
}

if ( @ARGV == 0 ) {
    print "tv <zoekterm> doet het beter.\n";
} else {

    ### alle zenders voor vandaag checken op zoekstring (argv) ###

    opendir( BIN, $datadir ) or die "Can't open $dir: $!";
    ZENDERS:
    while ( defined( $file = readdir BIN ) ) {
        if ( -T "$datadir/$file" ) {

            ##Haal "pagina" voor 1 zender op
            open( ZENDER, "< $datadir/$file" );
            @lines = <ZENDER>;
            close ZENDER;
            if ( lc($file) eq lc( $ARGV[0] ) ) {
                my ( $nutijd, $nu );
                foreach $line (@lines) {
                    ( $ltijd, $film, $lnaam, $beschrijving, $prut ) = split /\xb6/, $line;
                    $ltijd =~ /(\d+):(\d+)/;
                    $lhour = int($1);
                    if ( $lhour < 6 ) { $lhour += 24; }
                    $lminute = $2;
                    if ( ( ( ( $lhour < $thishour ) || ( ( $lhour == $thishour ) && ( $lminute <= $thisminute ) ) ) ) ) {
                        $nutijd     = $ltijd;
                        $nu         = $lnaam;
                        $vorige_uur = $lhour;
                    } else {
                        if ( $nutijd > 23 ) { $nutijd -= 24; }
                        if ( $ltijd > 23 )  { $ltijd  -= 24; }
                        print "$file: $nutijd - $ltijd $nu";
                        exit 0;
                    }
                }
                print "$file: tot $nutijd was $nu";
                exit 0;
            } else {

                ##Regel voor regel doorwerken
                foreach $line (@lines) {
                    ( $ltijd, $film, $lnaam, $beschrijving, $prut ) = split /\xb6/, $line;
                    $ltijd =~ /(\d+):(\d+)/;
                    $lhour = $1;
                    if ( $lhour < 6 ) { $lhour += 24; }

                    ##Check op zoekstring
                    if ( ( ( $ARGV[0] =~ /film/i ) && ( $film eq "F" ) ) || ( $lnaam =~ /@ARGV/i ) ) {

                        ##Controleer of het niet allang voorbij is
                        ##en bewaar het programma in @output
                        if ( $thishour - 2 < $lhour ) {
                            if ( $lnaam !~ /trekking/i ) {    #Niet al die loterijen als je startrek zoekt!
                                $found = "$file " . "$ltijd $lnaam";
                                $found =~ s/\n//g;
                                push @output, $found;

                                ##Stop als je maxima hoeveelheid "hits" hebt"
                                if ( @output == $maxoutput ) { last ZENDERS }
                                ;    #stoppen met zoeken
                            }
                        }
                    }
                }
            }
        }
    }
    closedir(BIN);

    ### Afdrukken uitvoer ###

    if ( @output + 0 == 0 ) {
        print "Geen programma's gevonden.\n";
    } else {
        foreach $progje (@output) { print $progje. "\n" }
    }
}
