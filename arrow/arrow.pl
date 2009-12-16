#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl
# thanks to michael for finding new playlist url

use strict;
use warnings;

use LWP::UserAgent;
use URI;

use XML::Simple;

my $commandline = $ARGV[0];
$commandline = (defined $commandline) ? $commandline : '';

my $type = 'jazz';
my $url = "http://www.crossmediaventures.com/xmlinserter/ArrowJazz.xml";
if ($commandline =~ /rock/ ) {  #somewhere
  $type = 'rock';
  $url = "http://www.crossmediaventures.com/xmlinserter/ArrowRock.xml";
}

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my $data = XMLin($content);

my ($song, $artist, $album) = ($data->{'Current'}->{'titleName'}, $data->{'Current'}->{'artistName'}, $data->{'Current'}->{'albumName'});
if ($song ne "" and $artist ne "" and $album ne "") {
	print "$artist - $song  [Album: $album]\n";
}
else {
	print "Sorry, no information available...\n";
}

