#!/usr/bin/perl -w
#
# fmylife script

use strict;
use XML::Simple;
use LWP::UserAgent;
use HTML::Entities;
use Data::Dumper;

my $commandline = join(' ', @ARGV);

my $url;
if ($commandline eq '' || $commandline eq 'last') {
	$url = "http://www.fmylife.com/";
} elsif ($commandline =~ /\A[1-9]\d*?\z/ || $commandline eq 'random') {
	$url = "http://www.fmylife.com/$commandline";
} else {
	print "You need help.\n";
	exit;
}

my $ua  = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $response = $ua->request($request);
unless ( $response->is_success() ) {
	print "Server returned an error.\n";
	exit;
}

my $content = $response->content;
unless ($content =~ /\A.*?<div class="post"(?: [^>]*?)?><p>(.*?)<\/div>/s) {
	print "Could not parse server response.\n";
	exit;
}
my $res = $1;

unless ($res =~ /\A<a href="\/\w+\/(\d+)" class="fmllink">(.*?)<\/p>/) {
	print "Could not parse server response.\n";
	exit;
}
my $fml_id = $1;
my $text = $2;

$text =~ s/<[^>]*?>//g;
$text =~ s/\s+FML\s*\z//;
print "$text (FML ID: $fml_id)\n";
