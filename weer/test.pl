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

$request = new HTTP::Request( 'GET', "http://www.knmi.nl/voorl/weer/weermain.html" );
$request->referer("http://www.knmi.nl/voorl/weer/");
$response = $ua->request($request);
$html     = $response->content;
#$html =~ s/\n/ /g;

$html =~ m/Het weer.*?td>.*?<td(.*?)<\/td>/s;

my $weer = $1;

$weer =~ s/<a.*?<\/a>//;
$weer =~ s/<.*?>//g;
$weer =~ s/^.*?>//;
$weer =~ s/\n/ /g;
$weer =~ s/\r//g;
$weer =~ s/(\s+)/ /g;
$weer =~ s/\.\.\.//g;
print "$weer (Bron: KNMI)\n";
