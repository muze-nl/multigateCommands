#!/usr/bin/perl

use strict;
use LWP::UserAgent;

my $ua = new LWP::UserAgent;

#Set agent name, vooral niet laten weten dat we een script zijn
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $number = 3;

my $zoek    = $ARGV[0];
my @results = ();
if ( $zoek =~ /^\d{4}$/ ) {

    my $request = new HTTP::Request( 'GET', "http://www.utwente.nl/cgi-bin/gids/zoekgids.pl?zoeknaar=$zoek&pagina=zoekgids.html" );
    my $content = $ua->request($request)->content;

    my @frop = ( $content =~ m|<TR VALIGN=TOP>(.*?)</TR>|sg );

    foreach my $entry (@frop) {
        if ( my @fields = ( $entry =~ m|<TD>(.*?)</TD>|gs ) ) {
            map { s/&nbsp;// } @fields;
            map { s/<.*?>//gi } @fields;
            map { s/^\s*// } @fields;
            map { s/\s*$// } @fields;
            if ( $fields[0] == $zoek ) {
                push @results, "$fields[0] $fields[2] ($fields[3])";
            }
        }
    }

    if ( @results == 0 ) {

        #zoek op campus:
        open FOO, "<acasa.txt";
        my @lijst = <FOO>;
        close FOO;

        my @nummers = grep /^$zoek/, @lijst;

        if ( @nummers == 1 ) {
            my ( $nummer, $adres ) = split ":", $nummers[0], 2;
            print "$nummer: $adres";
            exit 0;
        } else {
            print "Niets gevonden\n";
            exit 0;
        }
    }
    if ( @results > $number ) {
        print scalar @results, " resultaten. Eerste $number zijn:\n";
        for ( my $i = 0 ; $i < $number ; $i++ ) {
            print $results[$i] . "\n";
        }
    } else {
        foreach my $item (@results) {
            print "$item \n";
        }
    }
} else {
    print "Geef 4-cijferig nummer\n";
}
