#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use URI::Escape;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my $maxaantal = 5;

$commandline = uri_escape($commandline);

## Get a certain URL
my $url =
  "http://packages.debian.org/cgi-bin/search_contents.pl?word=$commandline&searchmode=searchfilesanddirs&case=insensitive&version=stable&arch=i386";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my @lines = split /^/m, $content;
my @result = ();
my $aantal = 0;
foreach my $line (@lines) {
    if ( $line =~ /^(\S+)\s+<a href="http:\/\/packages.debian.org\/stable.*?>(.*?)<\/a>/i ) {    # if it matches something
        $aantal++;
        push @result, "$1 : $2" if ( $aantal <= $maxaantal );
    }
}

if (@result) {
    print join "\n", @result;
} else {
    print "Package \"$commandline\" niet gevonden\n";
}

