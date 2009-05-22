#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use HTML::Entities();

my ( $min, $hour ) = (localtime)[ 1 .. 2 ];
my $day = sprintf "%02d", (localtime)[3];
my $month = sprintf "%02d", (localtime)[4] + 1;
my $year = (localtime)[5] + 1900;

#print "$day $hour:$min $month $year\n";

## Get a certain URL
my $url = "http://www.classicfm.nl/index.php?playlist=$year$month$day";
#print STDERR "Getting url: $url\n";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/5.0 (compatible; MSIE 5.5; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

#print STDERR $content;


my @lines = ( $content =~ m|<td valign="top">0?$hour:\d+</td><td valign="top">\d+:\d+</td><td valign="top">.*?</td>|sgi );
my $result;
foreach my $line (@lines) {
    $line =~ s/\n//g;
    # print STDERR "Line: $line\n";

    if ( $line =~ m|<td valign="top">$hour:(\d+)</td><td valign="top">\d+:\d+</td><td valign="top">(.*?)</td>|i ) {
        my $startmin = $1;
        #print STDERR "Startmin = $startmin\n";
        $result = $2 unless ( $startmin > $min );
    }
}

$result = HTML::Entities::decode($result);
$result =~ s/(<.*?>)/ /g;
$result =~ s/\s+/ /g;
print "$result\n";
