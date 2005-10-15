#!/usr/bin/perl -w

my $rot13 = $ARGV[0];
$rot13 =~ tr/a-zA-Z/n-za-mN-ZA-M/;
print "$rot13\n";

#! /bin/bash
# Author: Bas van Sisseren <bas@dnd.utwente.nl>
#
#echo "$*" | /usr/bin/tr 'A-Za-z' 'N-ZA-Mn-za-m'
