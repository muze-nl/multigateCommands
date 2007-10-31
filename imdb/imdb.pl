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

my $request = new HTTP::Request( 'GET', "http://former.imdb.com/" );
my $response = $ua->request($request);
$cookie_jar->extract_cookies($response);

sub lookup_title {
	my $titel = shift;
	$titel =~ s/^\s+//;
	$titel =~ s/\s+$//;

	my $t = uri_escape($titel);
	$t =~ s/%20/+/g;
    my $url = "http://former.imdb.com/find?q=$t;s=all";

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

		$url = "http://former.imdb.com/title/$id/";
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
	$alles =~ /.*?Directed by<\/B><BR>.*?>(.*?)<\/A>.*?/si;
	my $regisseur = "$1 ";
	$alles =~ /.*?Plot (Outline|Summary):<\/b>(.*?)<a.*?/si;
	my $plot = "$2 ";

	# <b>8.2/10</b> (26,379 votes)</b>
	$alles =~ /.*?<b>(\d*\.\d*)\/10<\/b> \(\d+.*? votes\).*?/si;
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
