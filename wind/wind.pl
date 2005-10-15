#!/usr/bin/perl -w
# Gekopieerd van Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl
# Beunpoging door gwen op het tweede deel

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

$request = new HTTP::Request( 'GET', "http://www.knmi.nl/voorl/weer/seinkust.html" );
$request->referer("http://www.knmi.nl/voorl/weer/");

$response = $ua->request($request);
$html     = $response->content;
$html =~ s/\n/ /g;

$html =~ m|<li>(.*?)</li>|;

$result = "$1 (Bron: KNMI)\n";
$result =~ s/warning.*//gi;
$result =~ s/<br>/ /g;
$result =~ s/<.*?>//g;
$result =~ s/\s+/ /g;
print $result;
