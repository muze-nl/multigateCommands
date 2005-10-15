#!/usr/bin/perl -w
# Copyright 2002, Casper Eyckelhof

use LWP::UserAgent;
use HTTP::Cookies;
use URI::Escape;

$ua = new LWP::UserAgent;

$commandline = $ARGV[0];
$commandline =~ /^(\d{4}\s*[A-Za-z]{2})\s*(\d+)/;

( $postcode, $nummer ) = ( $1, $2 );

if ( !( ( defined $postcode ) && ( defined $nummer ) ) ) {
    print "Geef postcode en huisnummer. Vb: 1234AB 56\n";
    exit 0;
}

$postcode = uri_escape($postcode);
$postcode =~ s/%20/+/g;
$nummer = uri_escape($nummer);
$nummer =~ s/%20/+/g;

@agents = (
    "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)", "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)",
    "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)",     "Mozilla/4.0 (compatible; MSIE 5.0; Windows 95) Opera 6.01  [en]"
);

$agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

$request = new HTTP::Request( 'GET', "http://www.tpgpost.nl/cgi-bin/pzm-p.pl?postcode=$postcode&huisnummer=$nummer" );
$response = $ua->request($request);
$content  = $response->content;

if ( $content =~
    /^.*?<td>Straatnaam<b>\s*(.*?)<br>\s*<\/b>Huisnummer<b>\s*(.*?)<br>\s*<\/b>Woonplaats<b><b>\s*(.*?)<\/b>\s*<br>\s*<\/b>Postcode<b>\s*(.*?)<br>.*?$/si
  )
{
    $straat = $1;
    $huis   = $2;
    $plaats = $3;
    $code   = $4;

    print "$code $huis: $straat te $plaats\n";
} else {
    print "$postcode $nummer lijkt niet te bestaan\n";

}
