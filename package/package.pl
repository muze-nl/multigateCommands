#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use URI::Escape;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my $maxaantal = 5;

$commandline = uri_escape($commandline);

## Get a certain URL
#my $url =
#  "http://packages.debian.org/cgi-bin/search_contents.pl?word=$commandline&searchmode=searchfilesanddirs&case=insensitive&version=stable&arch=i386";
my $url =
  "http://packages.debian.org/search?searchon=contents&keywords=$commandline&mode=exactfilename&suite=stable&arch=any";
my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

# Glue a few lines together, so we can actually search
$content =~ s/<td>\s+<a/<td><a/og;
$content =~ s/<\/a>\s+<\/td/<\/a><\/td/og;
$content =~ s/<\/td>\s+<td>/<\/td><td>/og;

my @lines = split /^/m, $content;
my @result = ();
my $count = 0;
foreach my $line (@lines) {
    if ( $line =~ m/^\s*<td class="file">(.*?)<span class="keyword">(.*?)<\/span><\/td><td><a href="(.*?)">(.*?)<\/a><\/td>\s*$/ ) {
    	$count++;
    	push @result, "$4: $1$2" if $count <= 5;
    }
}

if (scalar @result) {
    print map { ($_, "\n") } @result;
} else {
    print "Package \"$commandline\" niet gevonden\n";
}

