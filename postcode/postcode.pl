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

$request =
  new HTTP::Request( 'GET',
    "http://www.tpgpost.nl/zoeken/resultaatscherm.phtml?action=checkpc&postcode=$postcode&huisnummer=$nummer" );
$response = $ua->request($request);
$content  = $response->content;

#<td height="20" colspan="2">Het resultaat van uw zoekopdracht is:</td>
#  </tr>
#  <tr> 
#    <td width="130" height="60">&nbsp;</td>
#    <td height="60"> 
#      <b>Fransche Brug 12<BR>2371BE  ROELOFARENDSVEEN</b>       </td>
#  </tr>
#print STDERR $content;

$content =~ s/&nbsp;//g;

if ( $content =~ m|^.*?Het resultaat van uw zoekopdracht is:</td>.*?<b>(.*?)\s($nummer)<br>(\d{4}\w{2})\s*(.*?)</b>.*?|si ) {
    $straat = $1;
    $huis   = $2;
    $plaats = $4;
    $code   = $3;

    print "$code $huis: $straat te $plaats\n";
} else {
    print "$postcode $nummer lijkt niet te bestaan\n";
}
