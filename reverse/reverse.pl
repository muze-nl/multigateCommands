#!/usr/bin/perl -w

# Reversing a string by character
# CtlAltDel (Wouter Commandeur)

$commandline = join " ", @ARGV;

$revwords = reverse($commandline);

print $revwords;
