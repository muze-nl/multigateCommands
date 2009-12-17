#!/usr/bin/perl -w 
# Arjan Opmeer (Ado)
# ado@dnd.utwente.nl

use strict;

use URI::Escape;
use LWP::UserAgent;
use JSON;
use HTML::Entities;

# What are we looking for?
my $query = "internet";
if (defined $ARGV[0]) {
	$query = uri_escape($ARGV[0]);
}
my $url = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=$query";

# Quote van Google:
# "Applications MUST always include a valid and accurate http referer header
#  in their requests. In addition, we ask, but do not require, that each
#  request contains a valid API Key."
#
# Use this as the referer header
my $referer = "http://ringbreak.dnd.utwente.nl";

# Create a new UserAgent and JSON instance
my $ua = new LWP::UserAgent;
my $json = new JSON;

# Create a new Request instance
my $request = HTTP::Request->new(GET => $url);
# and set the required referer header
$request->headers->referer($referer);

# Fetch the requested page
my $response = $ua->request($request);
if (!$response->is_success) {
	print "Error performing Google search\n";
	print $response->status_line, "\n";
	exit 1;
}

# JSON decode the search response
my $decoded = $json->decode($response->content);
# This is the first result (top of the page)
my $result = $decoded->{'responseData'}->{'results'}[0];

if (not defined $result) {
	print "No search results\n";
	exit;
}

my $foundurl = $result->{'url'};
my $foundtitle = decode_entities($result->{'titleNoFormatting'});

print $foundurl , "   [ ", $foundtitle , " ]\n";

