#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# joost@dnd.utwente.nl
# Haalt het meest recente file-nieuws van tt op en scrijft deze naar STDOUT
# Niet kort of heel efficient, maar werkt prima :)

# Frans van Dijk (`36`)
# fransd@scintilla.utwente.nl
# Volgende aanpassingen:
#  - Als er geen argument gegeven wordt alleen een opsomming geven.
#  - Betere controle of er een volgende pagina is door te kijken of de huidige pagina een link 'volgende subpagina' bevat.
#  - Mogelijk gemaakt dat 730-10 en verder worden opgevraagd ipv 730-010
#  - Nieuwe json bron url (26-04-2015)

use strict;
use HTML::Entities();
use LWP::UserAgent;
use JSON;
my $ua = new LWP::UserAgent;
my $json = new JSON;

#Set agent name, vooral niet laten weten dat we een script zijn
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $args = shift @ARGV;
my %wegen;

sub get_url {
    my $url = shift;
    my $request = new HTTP::Request( 'GET', $url );
    $request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
    $request->header( "Accept-Encoding" => "gzip,deflate" );
    $request->header( "Accept-Language" => "en-us, en;q=0.5" );
    $request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

    return $ua->request($request)->content;
}

sub parse_page {
    my $content = shift;
    eval {
        $content = $json->decode($content);
        die unless $content->{'content'};
    };
    if (my $e = $@) {
        #print "Could not decode JSON: $e";
        print "Geen geldig antwoord ontvangen van de server.";
        exit;
    }
    #get everything between <pre> </pre>
    if ( $content->{'content'} ) {
        my $lastpage = 1;
        if ( $content->{'nextSubPage'} =~ /730-\d+/ ) {
            $lastpage = 0;
        }
        $content = $content->{'content'};
        $content =~ s/&#xF0[0-9a-f]{2};//g;
        $content =~ s/.*?Files:.*?\n(.*)Bron:ANWB.*?/$1/si;
        $content =~ s/<span.*?>//sgi;
        $content =~ s/<\/span>//sgi;
        $content =~ s/\n -/\r/g;
        $content =~ s/\n+//g;
        $content =~ s/\r/\n -/g;
        $content =~ s/<a .*?>(\d{3}).*?<\/a>/($1),/gi;
        $content =~ s/<a .*? class="(red|green|yellow|cyan)" .*?>.*?<\/a>//gi;

        $content = HTML::Entities::decode($content);

        my $last_weg;
        my @lines = split /\n/, $content;
        foreach my $line (@lines) {
            if ( $line =~ /^\s+?-\s+?(.*?) (.*)/ ) {
                $last_weg = $1;
                $wegen{$last_weg} .= $2;
            } else {
                if ( $line =~ /\*+/ ) {
                    $last_weg = "rest";
                    $wegen{$last_weg} .= $line;
                }
            }
        }
        return $lastpage;
    } else {
        return undef;
    }
}



my $base_url = 'http://teletekst-data.nos.nl/json/730-';
my $t = '?t='.time.'0000';
my $page_index = 1;

my $next = 1;
while ($next) {
    my $url = $base_url . sprintf("%02d", $page_index) . $t;
    #print $url ."\n";
    my $lastpage = parse_page( get_url($url) );
    if ( defined $lastpage ) {
        if ($lastpage == 1) {
            $next = 0;
        }
    } else {
        $next = 0;
    }
    $page_index++;
}

delete $wegen{"rest"};

my $output;

unless ( $args eq "" ) {
    my @argjes = split " ", $args;
    foreach my $arg (@argjes) {
        $arg = uc($arg);
        if ( defined $wegen{$arg} ) {
            $wegen{$arg} =~ s/\s{2,}/ /g;
            $output .= $arg . " " . $wegen{$arg} . "\n";
        }
    }
    if ( $output eq "" ) {
        $output = "Geen files gevonden voor aangegeven traject\n";
    }
}
else {
    foreach my $key ( keys %wegen ) {
        $wegen{$key} =~ s/\s{2,}/ /g;
        $output .= "$key, ";# . $wegen{$key} . "\n";
    }
    if ( $output eq "" ) {
        $output = "Er zijn op dit moment geen files\n";
    } else {
        $output =~ s/(.*), /$1/;
        $output =~ s/(.*),/$1 en/;
        $output = "Er zijn momenteel files op: $output\n";
    }
}

print $output;
