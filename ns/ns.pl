#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# joost@dnd.utwente.nl
# Haalt het meest recente NS-nieuws van tt op en scrijft deze naar STDOUT
# Niet kort of heel efficient, maar werkt prima :)

use HTML::Entities();
use LWP::UserAgent;

$ua = new LWP::UserAgent;

#Set agent name, vooral niet laten weten dat we een script zijn
$agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

#$ua->proxy( "http", "http://www.area53.nl:4242/" ); #temporary proxy

$url = "http://teletekst.nos.nl/tekst/751-01.html";    # what else???

##Haal pagina  op
$request = new HTTP::Request( 'GET', $url );
$request->referer('http://portal.omroep.nl/');
$request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
$request->header( "Accept-Encoding" => "gzip,deflate" );
$request->header( "Accept-Language" => "en-us, en;q=0.5" );
$request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );
$content = $ua->request($request)->content;

#get everything between <pre> </pre>
if ( $content =~ /<pre>/ ) {
    $content =~ s/^.*?<pre>.*?\n(.*?)<\/pre>.*?$/$1/si;
    $content =~ s/\*+//g;
    $content =~ s/<font .*?>//sgi;
    $content =~ s/<\/font>//sgi;
    $content =~ s/<A HREF=".*?html">(\d{3})<\/A>/($1),/gi;
    $content =~ s/\n+//g;
    $content =~ s/\.{2,}//g;
    $content =~ s/([,.])/$1 /g;
    $content =~ s/\s{2,}/ /g;
    $content =~ s/^\s//;
    $content =~ s/<A HREF=".*?html">(\d{3})<\/A>/($1),/gi;
    $content =~ s/volledig nieuwsoverzicht.*?$//i;
    $content =~ s/,\s*$//;
    $content =~ s/^(.*?ProRail).*$/$1/i;
    $content =~ s/volgende nieuws.*$//i;
    $content = HTML::Entities::decode($content);

    print $content . "\n";

} else {
    print "Status onbekend\n";
}
