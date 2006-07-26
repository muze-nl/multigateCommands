#!/usr/bin/perl -w
# Simple grep for multi-commands
# case insensitive; needs more errorchecking

use strict;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my ($expression, $payload) = split " ", $commandline, 2;

my @lines = split /\xb6/, $payload;
my @result = grep { /$expression/i } @lines;

print join("\n", @result);