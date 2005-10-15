#!/usr/bin/perl -w
#
# Casper Joost Eyckelhof , 2002 

use strict;

use lib '../../lib/';
use Multigate::Config qw( getconf readconfig );

readconfig("../../multi.conf");

my $version = getconf('multiversion');

print "Multigate version: \"$version\" running\n";
