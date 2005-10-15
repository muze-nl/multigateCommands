#!/usr/bin/perl -w
use strict;

my $user  = $ENV{'MULTI_REALUSER'};
my $stuff = $ARGV[0];

#print STDERR "Echo: stuff = '$stuff'\n";

if ( defined $stuff ) {
    print "$user zegt: $stuff\n";
}
