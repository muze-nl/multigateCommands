#! /usr/bin/perl -w

use strict;
use warnings;

use LWP::UserAgent;

my $nummer = $ARGV[0];

my $url = "http://www.detelefoongids.nl/static/netnummers.html";

my $result = "fout: nummer niet gevonden, of !netnummer stuk...";
if (defined $nummer and $nummer =~ m/0\d+/) {
	my $ua = new LWP::UserAgent;
	my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
	$ua->agent($agent);
	my $request = new HTTP::Request( 'GET', $url );
	my $content = $ua->request($request)->content;
	if (defined $content) {
		($result) = $content =~ m!<td class="name">$nummer</td>\s*<td>\s*([^<]*?)\s*</td>!im;
		$result = "niet gevonden" unless defined $result;
	}
} else {
	$result = "fout: geen (zinnig) netnummer meegegeven";
}

print $result, "\n";
