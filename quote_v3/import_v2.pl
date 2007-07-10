#!/usr/bin/perl -w

use strict;
use Storable qw/ retrieve /;
use QuoteDB qw/ :DEFAULT quote_set_next_id /;

die "New quote database is not empty!\n"
	unless quote_count == 0;

die "Usage: $0 <filename>\n"
	unless @ARGV == 1;

sub trim {
	my $quote = shift;
	$quote =~ s/^\s+//;
	$quote =~ s/\s+\z//;
	return $quote;
}

sub date_time_unix {
	my $t = shift;
	return undef unless defined $t;
	my ($sec, $min, $hour, $mday, $mon, $year) = gmtime($t);
	return sprintf '%04u-%02u-%02uT%02u:%02u:%02uZ',
		$year+1900, $mon+1, $mday, $hour, $min, $sec;
}

my $file = shift;
die "'$file' is not a file!\n"
	unless -f $file;

my $q = retrieve($file);
$q->{new_id} ||= 1;
$q->{quotes} ||= {};
quote_set_next_id($q->{new_id});

foreach my $quote_id (sort { $a <=> $b } keys %{$q->{quotes}}) {
	my $qq        = $q->{quotes}{$quote_id};
	my $quote     = trim($qq->{text});
	my $real_user = $qq->{realuser};
	my $time      = date_time_unix($qq->{time_added});
	my $res = quote_add($quote, $real_user, $time, $quote_id);
	die "quote add error: $res\n" unless $res > 0;

	foreach my $realuser (keys %{$qq->{votes}}) {
		my $vote = $qq->{votes}{$realuser};
		my $res = quote_vote($quote_id, $realuser, $vote);
		die "quote vote error: $res\n" unless $res == 1;
	}
}

print "All quotes imported.\n";
