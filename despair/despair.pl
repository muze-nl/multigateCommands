#!/usr/bin/perl -w
use strict;

open TXT, "< despair.txt";
my @lines = <TXT>;
close TXT;

if (defined $ARGV[0] and $ARGV[0] =~ /^\w+$/) {
    my $commandline = $ARGV[0];
    foreach my $line (@lines) {
       my ($key, $value) = split ':', $line, 2;
       if (lc($key) =~ /\Q$commandline\E/o) {
          print $line;
          exit 0;
       }
    }
}

#Falltru if no match


print $lines[ int( rand(@lines) ) ];