#!/usr/bin/perl -w
# ATAK.nl rss feed lezen, en kijken of er 'vandaag' iets te doen is
# Peter vd Weijden
#
use strict;
use LWP::Simple;
use XML::RSS;

my $istedoen = "";

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime time;
$mon++;
if($mon < 10) {
	$mon = "0".$mon;
}
if($mday < 10) {
	$mday = "0".$mday;
}
$year = $year+1900;
my $rssdate = "$mday-$mon-$year";

my $rss = new XML::RSS;

my $content = "";
my $file = "http://www.atak.nl/pub/atak.xml";


$content = get($file);
if ($content =~ m/^(\s\n)?$/) {
	print "Er is iets mis gegaan. atak.nl down ?\n";
} elsif ($content =~ m/404 - PAGE/) {
	print "Er is iets mis gegaan. de rss feed is kwijt ?\n";
} else {
$content =~ s/description/nothinghere/ig;
$content =~ s/link/nt/ig;
$content =~ s/act\:date/description/ig;
$content =~ s/act\:time/link/ig;
# parse the RSS content
$rss->parse($content);

# Zoek 'vandaag'
my $item;
#print $rss->as_string;
foreach $item (@{$rss->{'items'}}) {
	if ($item->{'title'} =~ m/^\Q$rssdate\E: (.*)$/) {
		$istedoen .= "$item->{'title'}\n";
	}

}

if ($istedoen =~ m/^(\s\n)?$/) {
	print "Er staat niets in de agenda voor vandaag.\n";
} else {
	print $istedoen;
}
	
}

