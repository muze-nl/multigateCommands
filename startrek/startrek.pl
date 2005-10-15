#!/usr/bin/perl 
# Zoekt naar Star Trek, vandaag en morgen, op eurotv
# geschreven door C.J. Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl
# Zaterdag 7 Augustus 1999

use LWP::Simple;

#### allerlei fijne definities en initialisaties ########

$base_url = "http://www.eurotv.com/";
%dagen    = (
    Sun => Zondag,
    Mon => Maandag,
    Tue => Dinsdag,
    Wed => Woensdag,
    Thu => Donderdag,
    Fri => Vrijdag,
    Sat => Zaterdag
);

%zenders = (
    ne1   => "Nederland 1",
    ne2   => "Nederland 2",
    ne3   => "Nederland 3",
    rtl4  => "RTL 4",
    rtl5  => "RTL 5",
    sbs   => "SBS 6",
    tv10  => "Fox",
    veron => "Veronica",
    bbc1  => "BBC 1",
    bbc2  => "BBC 2"
);

$thisday = $dagen{ ( Sun, Mon, Tue, Wed, Thu, Fri, Sat )[ (localtime)[6] ] };

###### gebruik "nederland 1"-pagina voor datum-->nummer #####
$content = get( $base_url . "/slne1.htm" );
@lines   = split /^/m, $content;

foreach $line (@lines) {
    if ( $line =~ /$thisday/ ) {
        $vandaag_htm = ( split /\"/, $line )[1];
        $vandaag_nr  = ( split //,   $vandaag_htm )[0];    #dit is dus het "zenderprefix" van vandaag
                                                           #print $vandaag_htm, $vandaag_nr;
    }
}

##alle zenders voor vandaag checken op startrek ##

foreach $zender ( keys %zenders ) {
    $content = get( $base_url . $vandaag_nr . "a" . $zender . ".htm" );    #de programma's op $zender vandaag
    @lines = split /^/m, $content;
    foreach $line (@lines) {
        if ( $line =~ /star trek/i ) {
            $line =~ s/<.*?>//g;
            $line =~ s/\r//g;
            $line =~ s/\t//g;
            print "Vandaag $zenders{$zender}   " . "$line";
        }
    }
}

##alle zenders voor morgen checken op startrek ##
## alvast erbij als lekkermakertje ##
$vandaag_nr++;
foreach $zender ( keys %zenders ) {
    $content = get( $base_url . $vandaag_nr . "a" . $zender . ".htm" );    #de programma's op $zender morgen
    @lines = split /^/m, $content;
    foreach $line (@lines) {
        if ( $line =~ /star trek/i ) {
            $line =~ s/<.*?>//g;
            $line =~ s/\r//g;
            $line =~ s/\t//g;
            print "Morgen $zenders{$zender}   " . "$line";
        }
    }
}
print "\n";
