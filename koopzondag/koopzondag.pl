#!/usr/bin/perl -w
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl

use LWP::UserAgent;
use HTTP::Cookies;
use Date::Manip;
use Data::Dumper;

&Date_Init( 'Language=Dutch', 'DateFormat=non-US' );

sub verwerk {
	my ($text) = @_;
	
	$date = ParseDate($text);
	$secs = &UnixDate($date,"%s");
	if($secs+86399 > time()) {
		return 1;
	}
	return 0;
}

$ua = new LWP::UserAgent;

#### allerlei fijne definities en initialisaties ########

@agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);

$agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

$request = new HTTP::Request( 'GET', "http://cms.enschede.nl/nl/stadenschede/winkelen/");
$response = $ua->request($request);
$html     = $response->content;

$html =~ s|.*p>Koopzondagen voor de <b>binnenstad</b> in 2006:</p>||sm;

$html =~ /<ul>(.+?)<\/ul>.+?<ul>(.+?)<\/ul>.*/s;

$binnen = $1;
$buiten = $2;

$binnen =~ s/<.+?>//g;
$buiten =~ s/<.+?>//g;


foreach $text (split(/\n/,$binnen)){
	if($text !~ /^[ 	]*$/ ) {
		$text =~ s/\(.+?\)//g;
		if( verwerk($text) ){
			print 'Binnen de singel: '. $text." | ";
			last
		}
	}
}

foreach $text (split(/\n/,$buiten)){
	if($text !~ /^[ 	]*$/ ) {
		$text =~ s/\(.+?\)//g;
		if( verwerk($text) ){
			print 'Buiten de singel: '. $text."\n";
			last
		}
	}
}
