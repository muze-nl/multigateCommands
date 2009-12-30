#! /usr/bin/perl -w

use strict;
use LWP::UserAgent;
use URI;

use XML::Simple;

my $commandline = $ARGV[0];
$commandline = (defined $commandline) ? $commandline : '';

my $index = 'Current'; # XML contains 'Current' and 'Next'
if ($commandline =~ /next/ ) {  #somewhere  
  $index = 'Next';
}

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
my $ua = new LWP::UserAgent;
$ua->agent($agent);

my $url = "http://www.radio2.nl/data/dalet/onair.xml";
my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my $data = XMLin($content);

my ($song, $artist, $album) = ($data->{$index}->{'titleName'}, $data->{$index}->{'artistName'}, $data->{$index}->{'albumName'});

#check for references in xml-structure, we want strings!
$artist = 'none' if (ref $artist ne '');
$album  = 'none' if (ref $album ne '');

if ($song ne "" and $artist ne "" and $album ne "") {
	print "$artist - $song  [Album: $album]\n";
}
else {
	print "Sorry, no information available...\n";
}

