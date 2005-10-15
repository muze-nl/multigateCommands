#!/usr/bin/perl -w
use strict;

my $binnenland = 2;
my $buitenland = 2;
my $sport      = 0;
my $net        = 1;
my $economie   = 1;

use LWP::UserAgent;
use HTTP::Cookies;
my $ua = new LWP::UserAgent;

# sanity checks on a resultstring
sub check_result {
    my $result = shift;
    return ( length($result) < 350 );
}

my @agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);

my $agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', "http://nu.nl/deeplink_xml/" );
$request->referer("http://nu.nl/");
my $response = $ua->request($request);
my @html     = split /\n/, $response->content;

my %nu      = ();
my $section = "unknown";
foreach my $line (@html) {
    if ( $line =~ /<section name="(.*?)">/i ) {
        $section = $1;
    } elsif ( $line =~ m|<document href="(.*?)">(.*?)</document>|i ) {
        my $headline = $2;
        push @{ $nu{$section} }, $headline;
    } else {

        #print "No match: $line\n";
    }

}

my @selectie = ();

# Selecteer headlines:

push @selectie, splice( @{ $nu{'Binnenland'} }, 0, $binnenland );
push @selectie, splice( @{ $nu{'Buitenland'} }, 0, $buitenland );
push @selectie, splice( @{ $nu{'Sport'} },      0, $sport );
push @selectie, splice( @{ $nu{'Net'} },        0, $net );
push @selectie, splice( @{ $nu{'Economie'} },   0, $economie );

if (@selectie) {
    print join ( ", ", @selectie ), " (bron: nu.nl)\n";
} else {
    print "Geen nieuws nu\n";
    exit 0;
}

