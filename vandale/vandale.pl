#!/usr/bin/perl -w
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl

# enhanced by Bas van Sisseren (tsd)
# bas@dnd.utwente.nl

use strict;
use LWP::UserAgent;
use URI::Escape;
use HTML::Entities;

my $address       = $ENV{'MULTI_USER'};            # address of invoking user
my $user          = $ENV{'MULTI_REALUSER'};        # multigate username of invoking user
my $userlevel     = $ENV{'MULTI_USERLEVEL'};       # userlevel of invoking user
my $from_protocol = $ENV{'MULTI_FROM'};            # protocol this command was invoked from
my $to_protocol   = $ENV{'MULTI_TO'};              # protocol where output will be sent
my $command_level = $ENV{'MULTI_COMMANDLEVEL'};    # level needed for this command
my $is_multicast  = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)


my $max_words = $is_multicast ? 1 : 4;

if ( !( defined $ARGV[0] ) || ( $ARGV[0] =~ /^\s*$/ ) ) {
    print "Geef zoekterm\n";
    exit 0;
}

my $zoekwoord = $ARGV[0];

my $ua = new LWP::UserAgent;

my @agents = (
    "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)", "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)",
    "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)",     "Mozilla/4.0 (compatible; MSIE 5.0; Windows 95) Opera 6.01  [en]"
);

my $agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

$zoekwoord =~ s/\s//g;
$zoekwoord = uri_escape($zoekwoord);

my $zoek_url = "http://www.vandale.nl/vandale/opzoeken/woordenboek/?zoekwoord=$zoekwoord";

my $request = new HTTP::Request( 'GET', $zoek_url );
$request->referer("http://www.vandale.nl/");
$request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
$request->header( "Accept-Encoding" => "gzip" );
$request->header( "Accept-Language" => "en" );
$request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );

my $response = $ua->request($request);
my $content  = $response->content;

my $data = $content;
$data =~ s/\n\s+/\n/g;
$data =~ s/<br[^>]*>/\n/ig;
$data =~ s/<dd[^>]*>/\n  /ig;
$data =~ s/<u[^>]*>(.*?)<\/u[^>]*>/\c_$1\c_/ig;
$data =~ s/<[^>]*>//g;
$data = decode_entities($data);

#print "===>\n$data\n<===\n";

$data =~ s/\r//g;

$data =~ s/^.*?\nRESULTAAT[^\n]*\n//s
	or do {
			print "Woord '$zoekwoord' niet gevonden.\n";
			exit 0;
		};

$data =~ s/\nCopyright.*?$//s
	or do {
			print "Woord '$zoekwoord' niet gevonden.\n";
			exit 0;
		};

$data =~ s/^\n+//;
$data =~ s/\n\n+/\n\n/g;
$data =~ s/\n+$//;

my @words = split /\n\n/, $data;
my @out = ();

while (@words && ($max_words-- > 0)) {
	my $w = shift @words;
    if ($w =~ m/Dit woord staat niet in het gratis woordenboek/i) {
        $max_words++;
        next;
    }
    $w =~ s/^\d+//g;
	$w =~ s/\xc2\xa0/\n/g;
	$w =~ s/\xc2\xb7/./g;
    $w =~ s/\x80\x82//g;
    $w =~ s/â//g;
	push @out, $w;
}

print join("\n", @out)."\n";
