#! /usr/bin/perl -w

use strict;
use LWP::UserAgent;
use URI;

my $url = "http://www.epicrockradio.com/";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my ($link) = $content =~ m!"(http://www\.audiorealm\.com/findcd\.html\?artist=[^&]*&title=[^&]*&album=[^&"]*)"!;

my $uri = URI->new( $1 );

my (undef, $artist, undef, $song, undef, $album) = $uri->query_form();

if ($song ne "" and $artist ne "" and $album ne "") {
	print "$artist - $song  [Album: $album]\n";
}
else {
	print "Sorry, no information available...\n";
}

