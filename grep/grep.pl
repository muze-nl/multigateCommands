#!/usr/bin/perl -w
# Simple grep for multi-commands
# case insensitive; needs more errorchecking

use strict;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my ($expression, $payload) = split " ", $commandline, 2;

my $inverse = 0;
if ($expression eq '-v') { # inverse
	$inverse = 1;
	($expression, $payload) = split " ", $payload, 2;
}

# prepare regexp
$expression = qr/$expression/i;

my @lines = split /\xb6/, $payload;
my @result;
if ($inverse) {
	@result = grep { ! /$expression/ } @lines;
} else {
	@result = grep {   /$expression/ } @lines;
}

print map { $_."\n" } @result;
