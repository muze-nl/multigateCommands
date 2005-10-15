#!/usr/bin/perl -w

use strict;
use lib '../../lib/';
use LWP::UserAgent;
use Data::Dumper;

my $arg = $ARGV[0];

if(!defined($arg)) {
	print "consult help\n";
	exit;
}

# Yes, LWP is less clean than SOAP, but SOAP is limited to 1000 queries/day
sub countGoogle($) {
	my $query=shift;
	my $ua = new LWP::UserAgent;
	my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
	$ua->agent($agent);

	my $url="http://www.google.com/search?q=$query";
	my $req=new HTTP::Request( 'GET', $url);
	my $con=$ua->request($req)->content;
	my @lines = split /^/m, $con;
	foreach my $line (@lines) {
		if($line=~m|Results <b>\d+</b> - <b>\d+</b> of about <b>([0-9,]+)</b> for <b>|) {
			my $ret=$1;
			$ret=~s/,//g;
			return $ret;
		}
	}
	return -1;
}

my @terms=split /\s+/, $arg;
if($arg=~/,/) {
	my @terms=split /,\s+/, $arg;
}

my %res;
foreach my $term (@terms) {
	$res{$term}=countGoogle($term);
}

my $highest="-1";
my $winner="none";
foreach my $term (@terms) {
	if($res{$term}>$highest) {
		$highest=$res{$term};
		$winner=$term;
	}
}

my @rest;
foreach my $term (@terms) {
	next if $term eq $winner;
	push @rest, "$term : ".$res{$term};
}
print "$winner : $highest (vs ". join (",", @rest) .")\n";
