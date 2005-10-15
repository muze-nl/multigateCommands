#!/usr/bin/perl -w

use strict;

# usage !units <number> ["]<from unit>["] ["]<to unit>["]

my $arg = shift;

unless ($arg) {
    usage: print 'usage !units [<number>] ["]<from unit>["] ["]<to unit>["] [<number>]', "\n";
    exit 0;
}

my ( $n, $f, $t );

if ( $arg =~ /^\s*(\d+\.?\d*)\s+"(.+)"\s+"(.+)"\s*$/ ) {
    $n = $1;
    $f = $2;
    $t = $3;
} elsif ( $arg =~ /^\s*(\d+\.?\d*)\s+(\S+)\s+(\S+)\s*$/ ) {
    $n = $1;
    $f = $2;
    $t = $3;
} elsif ( $arg =~ /^\s*"(.+)"\s+"(.+)"\s+(\d+\.?\d*)\s*$/ ) {
    $n = $3;
    $f = $1;
    $t = $2;
} elsif ( $arg =~ /^\s*(\S+)\s+(\S+)\s+(\d+\.?\d*)\s*$/ ) {
    $n = $3;
    $f = $1;
    $t = $2;
} elsif ( $arg =~ /^\s*(\S+)\s+(\S+)\s*$/ ) {
    $n = 1;
    $f = $1;
    $t = $2;
} elsif ( $arg =~ /^\s*"(.+)"\s+"(.+)"\s*$/ ) {
    $n = 1;
    $f = $1;
    $t = $2;
} else {
    goto usage;
}

#print "'/usr/bin/units', '-q', '-v', \"$n $f\", $t\n";

my $pid = open( U, '-|' ) || exec '/usr/bin/units', '-q', '-v', "$n $f", $t;

unless ($pid) {
    print "Cannot start /usr/bin/units!?\n";
    exit 0;
}

my $line = <U>;    # The first line of output is interresting

while (<U>) { }
;                  # discard the rest;

close U;

print $line;

exit 0;
