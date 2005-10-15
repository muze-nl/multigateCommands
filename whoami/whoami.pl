#!/usr/bin/perl -w
use strict;

my $user  = $ENV{'MULTI_REALUSER'};
my $level = $ENV{'MULTI_USERLEVEL'};

if ( $user eq "pietjepuk" ) {
    $user .= " (" . $ENV{'MULTI_USER'} . ")";
}

print "$user has level $level\n";

