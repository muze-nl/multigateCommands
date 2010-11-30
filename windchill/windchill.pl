#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;

## Get a certain URL
my $url = "http://www.knmi.nl/actueel/";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

# $result contains the String that will be returned to the user
my $result;

#print STDERR $content;

my $location_name;
if ( defined( $ARGV[0] ) && $ARGV[0] =~ /^([\w ]+)$/ ) {
    $location_name = $1;
    $result        = "Er is een fout opgetreden... ($1 is geen locatie volgens ".$url." ?)";
} else {
    $location_name = "Twenthe";
    $result        = "Er is een fout opgetreden... !windchill kapot?";
}

if ( $content =~ /$location_name.*?\n.*?\n.*?(-?[0-9\.]+).*?\n.*?\n.*?\n.*?([0-9\.]+)/im ) {
    my $temp = $1;
    my $wind = $2;

    my $oldchill = 0.045 * ( 5.49 * sqrt($wind) + 5.81 - 0.56 * $wind ) * ( 1.8 * $temp - 59.4 ) + 33;
    my $newchill = 13.13 + 0.62 * $temp - 13.95 * ( $wind**0.16 ) + 0.486 * $temp * ( $wind**0.16 );
    $result = sprintf( "oldchill: %.1f , newchill: %.1f\n", $oldchill, $newchill );
}

print $result;
