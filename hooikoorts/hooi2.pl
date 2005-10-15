#!/usr/bin/perl -w
# Marco Alink /  28-05-2003 / show hooikoorts tt 709

use strict;
use LWP::UserAgent;
use HTML::Entities();

my $baseurl = "http://teletekst.nos.nl/tekst/709-01.html";    # what else???
my $url;

$url = "$baseurl";

## Get a certain URL
my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
$request->referer('http://portal.omroep.nl/');
$request->header( "Accept" =>
    'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,text/css,*/*;q=0.1'
);
$request->header( "Accept-Encoding" => "gzip, deflate, compress" );
$request->header( "Accept-Language" => "en-us, en;q=0.80, ko;q=0.60, zh;q=0.40, ja;q=0.20" );
$request->header( "Accept-Charset"  => "utf-8, *" );

my $content = $ua->request($request)->content;

#get everything between <pre> </pre>
if ( $content =~ /<pre>/ ) {
    $content =~ s/^.*?<pre>.*?\n(.*?)<\/pre>.*?$/$1/si;
    $content =~ s/\*+//g;
    $content =~ s/<font .*?>//sgi;
    $content =~ s/<\/font>//sgi;
    $content =~ s/<A HREF=".*?html">(\d{3}).*?<\/A>/($1),/gi;
    $content =~ s/\n+//g;
    $content =~ s/\.{2,}//g;
    $content =~ s/([,.])/$1 /g;

    #$content =~ s/\s{2,}/ /g;
    $content =~ s/^\s//;
    $content =~ s/^.*?luidt://;
    $content =~ s/\s{2}((?:\w\s)+)\s/-->$1<--/g;
    $content =~ s/Leids Universitair.*$//i;
    $content =~ s/\s{2,}/ /g;
    $content = HTML::Entities::decode($content);
    $content =~ s/(volgende|index.*?) nieuws.*$//i;    #index tv nieuws financieel sport
    print $content . "\n";
} else {
    print "Pagina niet gevonden\n";
}
