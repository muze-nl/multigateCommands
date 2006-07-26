#!/usr/bin/perl -w
use strict;

## Import available environment variables

my $address       = $ENV{'MULTI_USER'};            # address of invoking user
my $user          = $ENV{'MULTI_REALUSER'};        # multigate username of invoking user
my $userlevel     = $ENV{'MULTI_USERLEVEL'};       # userlevel of invoking user
my $from_protocol = $ENV{'MULTI_FROM'};            # protocol this command was invoked from
my $to_protocol   = $ENV{'MULTI_TO'};              # protocol where output will be sent
my $command_level = $ENV{'MULTI_COMMANDLEVEL'};    # level needed for this command
my $is_multicast  = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)


my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my ($expression, $payload) = split $commandline, 2;

my @lines = split /\n/, $payload;

my @result = grep { /$expression/ } @lines;

