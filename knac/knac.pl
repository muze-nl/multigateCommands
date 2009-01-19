#! /usr/bin/perl -w

use strict;
use LWP::UserAgent;

my $url = "http://www.knac.com/text1.txt";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my @lines = split /\n/, $content;
my $first_line = shift @lines;

$first_line =~ /^text1=<b>NOW PLAYING<\/b>: ([^<]*)<br><b>BY:<\/b>( )?([^ ].*)\r$/;
my ( $song, $artist ) = ( ucfirst( lc($1) ), ucfirst( lc($3) ) );

if ( $song ne "" and $artist ne "" ) {
    print "$artist - $song\n";
} elsif ( $song ne "" ) {
    print "$song\n";
} else {
    print "Sorry, no information available...\n";
}
