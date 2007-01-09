#!/usr/bin/perl -w
use strict;
use Socket;

my $invoer = $ARGV[0];

unless ( $invoer =~ /^[a-f0-9]{8}$/i ) {
    print "Foute invoer\n";
    exit 0;
}

my @bytes = ( $invoer =~ /(..)/g );

my $address = join '.', map { hex($_) } @bytes;
my $name = gethostbyaddr( inet_aton($address), AF_INET );

unless ( defined $name ) {
    $name = "Not resolved";
}

print "$address ($name)\n";
