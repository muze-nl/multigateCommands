#!/usr/bin/perl 
# Yvo Brevoort (Ylebre)
# ylebre@dnd.utwente.nl
# Haalt het meest recente flits-nieuws van http://www.flitsservice.nl op en
# scrijft deze naar STDOUT

use HTML::Entities();
use LWP::UserAgent;
$ua = new LWP::UserAgent;

#Set agent name, vooral niet laten weten dat we een script zijn
$agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $args = shift @ARGV;

my %wegen;

sub get_url {
    my $url = shift;
    $request = new HTTP::Request( 'GET', $url );
    $request->referer('http://www.flitsservice.nl/');
    $request->header( "Accept"          => '*.*' );
    $request->header( "Accept-Language" => "en-us, en;q=0.80, ko;q=0.60, zh;q=0.40, ja;q=0.20" );
    $request->header( "Accept-Charset"  => "utf-8, *" );
    $content = $ua->request($request)->content;
    return $content;
}

sub parse_page {
    my $content = shift;
    my ( $snelweg, $regionaal );

    if ( $content =~ /(<table.*<\/table>)/si ) {
        if ( $content =~ /(<table.*?snelweg meldingen.*?<\/table>)(.*?)(<table.*?<\/table>)(.*)/si ) {
            $snelweg = $3;
            $content = $4;
        }
        if ( $content =~ /(<table.*?regionale meldingen.*?<\/table>)(.*?)(<table.*?<\/table>)/si ) {
            $regionaal = $3;
        }
    }

    if ( defined $snelweg ) {
        parse_flits($snelweg);
    }
    if ( defined $regionaal ) {
        parse_flits($regionaal);
    }
}

sub parse_flits {
    my $content = shift;
    $content =~ s/<.*?>//sgi;
    foreach my $line ( split "\n", $content ) {
        $line =~ s/^\s+//g;
        $line =~ s/\s{2,}/ /g;
        if ( $line =~ /(radar|laser) (..) ([an]\d+)?(.*)/ ) {
            my $weg = $3;
            if ( defined $weg ) {
                $weg = uc($weg);
                $wegen{$weg} = $line;
            }
        }
    }
}

my $result;

my $url = 'http://flitsservice.com/flitsservice/meldingen/vandaag.aspx';

parse_page( get_url($url) );

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
        $output = "Geen flitsers gevonden voor aangegeven traject\n";
    }
    print $output;
}
else {
    foreach my $key ( keys %wegen ) {
        print "$key - " . $wegen{$key} . "\n";
    }
}
