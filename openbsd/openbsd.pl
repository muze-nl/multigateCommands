#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;

## Import available environment variables

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';
my $url;
if ( $commandline =~ /^(\d)\.(\d)$/ ) {
    $url = "http://www.openbsd.org/errata$1$2.html";
} else {
    $url = "http://www.openbsd.org/errata.html";
}

## Get a certain URL

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my @lines = split /^/m, $content;

# $result contains the String that will be returned to the user
my $result = "Geen errata gevonden :)";

# $needed is the program that is requested. 0 = the current program, 1 = next etc.

foreach my $line (@lines) {
    if ( $line =~ /009000\"\>\<strong\>(.*)\<\/strong>/i ) {
        $result = $1;
        last;
    }
}

print $result;
