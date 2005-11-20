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

$request = new HTTP::Request( 'GET', "http://cms.enschede.nl/stadenschede/winkelen/");
$response = $ua->request($request);
$html     = $response->content;

$html =~ s|.*<h3>Koopzondagen voor het <a href="#kernwinkelapparaat" ar:type="to anchor">kernwinkelapparaat</a> in het kalenderjaar 2005:</h3>||sm;
$html =~ /<ul>(.+?)<\/ul>.+?<ul>(.+?)<\/ul>.*/s;

$binnen = $1;
$buiten = $2;

$binnen =~ s/<.+?>//g;
$buiten =~ s/<.+?>//g;

print "BINNEN:\n";
print $binnen;
print "BUITEN:\n";
print $buiten;
