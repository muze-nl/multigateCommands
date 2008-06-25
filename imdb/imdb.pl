#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use URI::Escape;
use HTTP::Cookies;
use HTML::Entities();

## Import available environment variables

my $address       = $ENV{'MULTI_USER'};            # address of invoking user
my $user          = $ENV{'MULTI_REALUSER'};        # multigate username of invoking user
my $userlevel     = $ENV{'MULTI_USERLEVEL'};       # userlevel of invoking user
my $from_protocol = $ENV{'MULTI_FROM'};            # protocol this command was invoked from
my $to_protocol   = $ENV{'MULTI_TO'};              # protocol where output will be sent
my $command_level = $ENV{'MULTI_COMMANDLEVEL'};    # level needed for this command

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

## Get a certain URL

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $cookie_jar = HTTP::Cookies->new;

my $request = new HTTP::Request( 'GET', "http://www.imdb.com/" );
my $response = $ua->request($request);
$cookie_jar->extract_cookies($response);

sub lookup_title {
	my $titel = shift;
	$titel =~ s/^\s+//;
	$titel =~ s/\s+$//;

	my $t = uri_escape($titel);
	$t =~ s/%20/+/g;
	my $url = "http://www.imdb.com/find?q=$t;s=all";

	#print STDERR "getting $url\n";
	#sleep 2;

	$request = new HTTP::Request( 'GET', $url );
	$cookie_jar->add_cookie_header($request);
	$response = $ua->request($request);

	if ( $response->headers->title() =~ /IMDb\s+search/i ) {
		my @lines    = $response->content;
		my $gevonden = 0;
		my $id;
		while ( !$gevonden && ( my $line = shift @lines ) ) {
			#print $line;
			if ( $line =~ m|<a href="/title/(tt\d+)/.*?">|i ) {
				$gevonden = 1;
				$id       = $1;
				last;
			}
		}

		if (!defined $id) {
			print "Film '$titel' niet gevonden.\n";
			return;
		}

		$url = "http://www.imdb.com/title/$id/";
		$request = new HTTP::Request( 'GET', $url );
		$cookie_jar->add_cookie_header($request);
		$response = $ua->request($request);

	} elsif ( $response->headers->title() =~ /The Internet Movie Database \(IMDb\)/i ) {
		print "Film '$titel' niet gevonden.\n";
		return;
	}
   
	$url = $response->base(); #we might have been redirected...
	my @html = $response->content;

	my $alles = join '', @html;

	#print $alles;
	$alles =~ /.*?<title>(.*?)<\/title>.*?/si;
	my $naam = "$1 ";
	
	#<div class="info">
	#<h5>Director:</h5>
	#<a href="/name/nm0000229/">Steven Spielberg</a><br/>
	#
	#</div>
	
	$alles =~ /.*?Director:<\/h5>.*?>(.*?)<\/a>.*?/si;
	my $regisseur = "$1 ";
	
	#<div class="info">
	#<h5>Plot:</h5>
	#When a gigantic great white shark begins to menace the small island community of Amity, a police chief, a marine scientist and grizzled fisherman set out to stop it. <a class="tn15more inline" href="/title/tt0073195/plotsummary" onClick="(new Image()).src='/rg/title-tease/plotsummary/images/b.gif?link=/title/tt0073195/plotsummary';">full summary</a> | <a class="tn15more inline" href="synopsis">full synopsis (warning! may contain spoilers)</a>
	#
	#</div>
	
	
	$alles =~ /.*?Plot:<\/h5>\s*(.*?)<a.*?/si;
	my $plot = "$1 ";

	# <b>User Rating:</b> 
	# <b>8.3/10</b>  
	$alles =~ /.*?<b>User Rating:<\/b>\s*<b>(\d*\.\d*)\/10<\/b>.*?/si;
	my $rating = "$1 ";
	my $result = "$naam. Regisseur: $regisseur. Plot outline: $plot Rating: $rating. (Zie: $url)";
	$result =~ s/\n//g;
	$result =~ s/<.*?>//g;
	$result =~ s/\s{2,}/ /g;
	$result =~ s/\s\././g;

	$result = HTML::Entities::decode($result);
	print "$result\n";
}

if ( @ARGV < 1 ) {
	print "Te weinig argumenten.\n"
} else {
    my $title  = $commandline;
    my @titles = split ';', $title;

    foreach my $title (@titles) {
        # strip !tv context
        # example: "RTL5 : 20:30 - 22:25 Imagine me and you"
        $title =~ s/^\w+\s+:\s+[0-9?]{1,2}:[0-9?]{1,2}\s+-\s+[0-9?]{1,2}\:[0-9?]{1,2}\s+(.*)$/$1/;
		lookup_title($title);
    }
}
