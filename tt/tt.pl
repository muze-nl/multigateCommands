#!/usr/bin/perl -w
# Casper Eyckelhof /  06-01-2003 / After teletekst layout change
# Frans van Dijk   /  26-04-2015 / New json source

use strict;
use LWP::UserAgent;
use HTML::Entities();
use JSON;

my $baseurl = 'http://teletekst-data.nos.nl/json/';
my $url;

my $t = '?t='.time.'0000';

if ( $ARGV[0] =~ m|(\d{3})[-/](\d+)| ) {
    $url = "$baseurl$1-$2$t";
} elsif ( $ARGV[0] =~ /(\d{3})/ ) {
    $url = $baseurl . $1 ."-01" . $t;
} else {
    $url = $baseurl . "101-01" . $t;
}

## Get a certain URL
my $ua = new LWP::UserAgent;
my $json = new JSON;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );

$request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
$request->header( "Accept-Encoding" => "gzip,deflate" );
$request->header( "Accept-Language" => "en-us, en;q=0.5" );
$request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

my $content = $ua->request($request)->content;
print "STOEK! Probeer het later nog eens." unless $content =~ /^\{/;
$content = $json->decode($content);
$content = $content->{'content'};

if ( $content ) {
    #$content =~ s/\*+//g;
    $content =~ s/&#xF0[0-9a-f]{2};//g;
    $content =~ s/<font .*?>//sgi;
    $content =~ s/<\/font>//sgi;
    $content =~ s/<span.*?>//sgi;
    $content =~ s/<\/span>//sgi;
    $content =~ s/<a .*?>(\d{3}).*?<\/a>/($1),/gi;
    $content =~ s/<a .*? class="(red|green|yellow|cyan)" .*?>.*?<\/a>//gi;
    $content =~ s/\n+//g;
    $content =~ s/\.{2,}//g;
    $content =~ s/([,.])/$1 /g;
    $content =~ s/\s{2,}/ /g;
    $content =~ s/^\s//;
    $content = HTML::Entities::decode($content);
    $content =~ s/(volgende|index.*?) nieuws.*$//i;    #index tv nieuws financieel sport
    $content =~ s/(volgende|index.*?).*?nieuws.*$//i;    #volgende nosnieuws financieel nossport
    print $content . "\n";
} else {
    print "Pagina niet gevonden\n";
}
