#!/usr/bin/perl -w
use strict;
use Socket;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

#find 4 octets

my $a = int rand(255); 
my $b = int rand(255);
my $c = int rand(255);
my $d = int rand(255);

if ($commandline =~ /^ut/i) {
   $a = 130;
   $b = 89;
}
if ($commandline =~ /^snt/i) {
   $a = 130;
   $b = 89;
   $c = 175;
}

my $address = "$a.$b.$c.$d";
my $name = gethostbyaddr( pack( "C4", ( split m|\.|, $address ) ), AF_INET );
my $resolved = defined $name ? $name : "Not resolved";

print "$address ($resolved)\n";
