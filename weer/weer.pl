#!/usr/bin/perl
#
# Haal het weer op van de knmi RSS reed. (http://www.knmi.nl/rss_feeds/)
#
# In elkaar gebeund door Wieger op basis van !rss van Casper Joost.
#

use strict;
use warnings;

use XML::RSS;
use LWP::UserAgent;

my $url = 'http://www.knmi.nl/rssfeeds/knmi-rssweer.cgi';

my $rss = new XML::RSS;
my $ua  = new LWP::UserAgent;


my $request = new HTTP::Request( 'GET', $url );
my $response = $ua->request($request);

if ( $response->is_success() ) {
	my $content = $response->content;
	eval { $rss->parse($content); };
	if ($@) {
		print "Error parsing $url\n";
		exit;
	}
	my $i1 = @{ $rss->{'items'} }[0]->{'description'};
	my $i2 = @{ $rss->{'items'} }[1]->{'description'};
	$i1 = $1 if $i1 =~ /\s*(.*?)<br>/ms;
        $i2 = $1 if $i2 =~ /\s*(.*?)<br>/ms;
	print "$i1 $i2 (Bron: KNMI)\n";
} else {
	print "Error retrieving url: $url\n";
}
