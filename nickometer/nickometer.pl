#!/usr/bin/perl -w
#
# Lame-o-Nickometer frontend
#
# (c) 1998 Adam Spiers <adam.spiers@new.ox.ac.uk>
#
# You may do whatever you want with this code, but give me credit.
#

use strict;

use vars qw($VERSION $verbose);
$verbose = 0;

require 'nickoback.pl';

my $user = $ENV{'MULTI_REALUSER'};
my $arg  = $ARGV[0];

if ( ( !defined $arg ) || ( $arg eq "" ) ) {
    $arg = $user;
}

my $percentage = &nickometer($arg);

if ( $arg eq "CtlAltDel" ) {
    $percentage = "100";
}

print "$arg scores $percentage% on the Lame-o-Nickometer\n";
