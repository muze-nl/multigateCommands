#!/usr/bin/perl -w

$commandline = join " ", @ARGV;

#$commandline = lc($commandline);
print "\U$commandline\n";

