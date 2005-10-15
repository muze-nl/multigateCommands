#!/usr/bin/perl -w
use strict;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

if ( $commandline =~ /^(\d+)/ ) {
    print scalar localtime($1), "\n";
} else {
    print "Geef aantal seconden na 1 januari 1970\n";
}
