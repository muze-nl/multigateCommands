#!/usr/bin/perl -w
# Casper Eyckelhof /  06-01-2003 / After teletekst layout change

use strict;
use LWP::UserAgent;
use HTML::Entities();

my $baseurl = "http://teletekst.nos.nl/tekst/";    # what else???
my $url;

if ( $ARGV[0] =~ m|(\d{3})[-/](\d+)| ) {
    my $sub = $2;
    if ( $sub < 10 ) { $sub = "0$sub" }
    $url = "$baseurl$1-$sub.html";
} elsif ( $ARGV[0] =~ /(\d{3})/ ) {
    $url = $baseurl . $1 . "-01.html";
} else {
    $url = $baseurl . "101-01.html";
}

## Get a certain URL
my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
$request->referer('http://portal.omroep.nl/');

$request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
$request->header( "Accept-Encoding" => "gzip,deflate" );
$request->header( "Accept-Language" => "en-us, en;q=0.5" );
$request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

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
    $content =~ s/\s{2,}/ /g;
    $content =~ s/^\s//;
    $content = HTML::Entities::decode($content);
    $content =~ s/(volgende|index.*?) nieuws.*$//i;    #index tv nieuws financieel sport
    $content =~ s/(volgende|index.*?).*?nieuws.*$//i;    #volgende nosnieuws financieel nossport
    print $content . "\n";
} else {
    print "Pagina niet gevonden\n";
}
