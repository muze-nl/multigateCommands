#!/usr/bin/perl -w

# Reversing a string word by word
# CtlAltDel (Wouter Commandeur)

$commandline = join " ", @ARGV;

$revwords = join ( " ", reverse split ( " ", $commandline ) );

print $revwords;
