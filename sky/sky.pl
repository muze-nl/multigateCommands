#!/usr/bin/perl -w
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl

use LWP::UserAgent;
use HTTP::Cookies;

$ua = new LWP::UserAgent;

#### allerlei fijne definities en initialisaties ########

@agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);

$agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

$proxy = "http://proxy.utwente.nl:3128/";

$ua->proxy( "http", $proxy );

$request = new HTTP::Request( 'GET', "http://www.skyradio.nl/main.asp?ChapterID=48" );
$request->referer("http://www.skyradio.nl/");
$request->header( "X-Forwarded-For" => "130.89.226.200" );
$response = $ua->request($request);
$html     = $response->content;
@lines    = split /^/m, $html;
foreach $line (@lines) {
    if ( $line =~ /.*?De komende 10 nummers:<br><br>(.*?)$/ ) {
        @out = split /<br>/, $1;
    }
}

#foreach $song (@out){
#   print "$song\n";
#}

$out[0] =~ /(.*?) - (.*?) - (.*?) \((.*?)\)/;
my ( $start, $song, $artist, $label ) = ( $1, $2, $3, $4 );

print "Now playing on sky radio: $song (by $artist)\n";
