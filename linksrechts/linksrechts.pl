#!/usr/bin/perl -w

use strict;
use warnings;
binmode STDOUT, ":utf8";

my @janee = (
	"links",
	"\x{2190}",
	"\x{21FD}",
	"\x{21B0}",
	"rechts",
	"\x{2192}",
	"\x{21B1}",
);
print $janee[ rand(@janee) ] . "\n";
