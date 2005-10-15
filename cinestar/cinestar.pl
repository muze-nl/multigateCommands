#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use HTML::Entities();

## Import available environment variables

my $is_multicast = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)


## Get a certain URL
my $url = "http://www.cinestar.nl/programma1.htm";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my @lines = split /^/m, $content;

my @result = ();
foreach my $line (@lines) {
    if ( $line =~ /<p><span class="Kop">(.*)<br>$/i ) {    # if it matches something
        my $regel = $1;
        $regel =~ s|<.*?>||g;
        $regel =~ s|\s+$||;
        push @result, $regel;
    }
}

# print something, 
# use escape like this: $result = HTML::Entities::decode($result);

print HTML::Entities::decode( join '; ', @result );
