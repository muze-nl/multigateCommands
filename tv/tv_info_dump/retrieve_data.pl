#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use HTTP::Cookies;

use config;

my $base_url = 'http://www.tvgids.nl/zoeken/?q=&d=0&z=%i&t=&g=&v=0';

my @user_agents = (
		"Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
		"Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)",
		"Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)",
		"Mozilla/4.0 (compatible; MSIE 5.0; Windows 95) Opera 6.01  [en]",
		"Mozilla/5.0 (X11; U; IRIX IP32; en-US; rv:1.0.0) Gecko/20020606"
	);

my $ua = LWP::UserAgent->new(
		agent		=> $user_agents[rand @user_agents],
		cookie_jar	=> HTTP::Cookies->new(),
	);

$ua->default_headers->header(
		Accept			=> 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png',
		Accept_Language	=> 'en',
		Accept_Charset	=> 'iso-8859-1,*,utf-8',
	);

sub shuffle { map { $_->[1] } sort { $a->[0] <=> $b->[0] } map { [ rand(), $_ ] } @_ }

# request cookie
my $req = HTTP::Request->new( GET => 'http://www.tvgids.nl/' );
my $res = $ua->request($req);

foreach my $channel (shuffle keys %channels) {
	next if -f 'data/'.$channel;

	sleep 5 + rand(5);

	my $url = sprintf $base_url, $channel;
	my $req = HTTP::Request->new( GET => $url );
	$req->referer( 'http://www.tvgids.nl/' );
	my $res = $ua->request($req);

	open my $out, '>', 'data/'.$channel;
	print $out $res->content;
	close $out;
}
