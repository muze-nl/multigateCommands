#! /usr/bin/perl -w

use strict;
use LWP::UserAgent;
use URI;

use XML::Simple;

my $url = "http://www.radio2.nl/data/dalet/onair.xml";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my $data = XMLin($content);

my ($song, $artist, $album) = ($data->{'Current'}->{'titleName'}, $data->{'Current'}->{'artistName'}, $data->{'Current'}->{'albumName'});

#check for references in xml-structure, we want strings!
$artist = 'none' if (ref $artist ne '');
$album  = 'none' if (ref $album ne '');

if ($song ne "" and $artist ne "" and $album ne "") {
	print "$artist - $song  [Album: $album]\n";
}
else {
	print "Sorry, no information available...\n";
}

