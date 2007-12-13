#!/usr/bin/perl -w

use strict;

my $args = join ' ', @ARGV;
unless ($args =~ /^[1-9]\d*$/) {
	print "Usage: !rfcinfo <id>\n";
	exit 1;
}

if ($args > 9999) {
	print "rfc id not found.\n";
	exit 1;
}

$args = sprintf '%04u', $args;

my $url = 'http://ftp.snt.utwente.nl/pub/docs/rfc/rfc-index.txt';
system('wget', '-q', '-O', 'rfc-index.txt', $url);

open F, '<', 'rfc-index.txt'
	or do {
			print "rfc index file not found.\n";
			exit 1;
		};

while (my $line = <F>) {
	if ($line =~ /^\Q$args\E /) {
		print $line;
		while (my $line = <F>) {
			if ($line =~ /^\s*$/) {
				close F;
				exit 0;
			}
			print $line;
		}
		exit 0;
	}
}

close F;

print "rfc id not found.\n";
