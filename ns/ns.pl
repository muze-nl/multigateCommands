#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# joost@dnd.utwente.nl
# Haalt het meest recente NS-nieuws van tt op en scrijft deze naar STDOUT
# Niet kort of heel efficient, maar werkt prima :)

# Frans van Dijk (`36`)
# fransd@scintilla.utwente.nl
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

#$ua->proxy( "http", "http://www.area53.nl:4242/" ); #temporary proxy
#
my $sub;

if ( $ARGV[0] =~ m|(\d+)| ) {
	$sub = $1;
	if ( $sub < 10 ) { $sub = "0$sub" }
} else {
	$sub = '01';
}

my $t = '?t='.time.'0000';
my $url = "http://teletekst-data.nos.nl/json/751-$sub$t";


##Haal pagina  op
my $request = new HTTP::Request( 'GET', $url );
$request->referer('http://portal.omroep.nl/');
$request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
$request->header( "Accept-Encoding" => "gzip,deflate" );
$request->header( "Accept-Language" => "en-us, en;q=0.5" );
$request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );
my $content = $ua->request($request)->content;
print "STOEK! Probeer het later nog eens." unless $content =~ /^\{/;
$content = $json->decode($content);
$content = $content->{'content'};

if ( $content ) {
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
    $content =~ s/volledig nieuwsoverzicht.*?$//i;
    $content =~ s/,\s*$//;
    $content =~ s/^(.*?ProRail).*$/$1/i;
    $content =~ s/S P O O R W E G E N actueel //i;
    $content =~ s/volgende nieuws.*$//i;
    $content =~ s/plan uw reis op ns.*$//i;
    $content = HTML::Entities::decode($content);

    print $content . "\n";

} else {
    print "Status onbekend\n";
}
