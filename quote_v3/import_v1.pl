#!/usr/bin/perl -w

use strict;
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

my $file = shift;
die "'$file' is not a file!\n"
	unless -f $file;

quote_set_next_id(1);

open FILE, "< $file";
while (my $quote = <FILE>) {
	chomp $quote;
	$quote =~ s/\r$//;
	$quote = trim($quote);
	my $res = quote_add($quote, undef, undef);
	die "quote add error: $res\n" unless $res > 0;
}
close FILE;

print "All quotes imported.\n";
