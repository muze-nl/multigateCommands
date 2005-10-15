#!/usr/bin/perl -w
#
# Calculcator for multigate
# (C) 2002 Wieger Opmeer
#

use strict;

use Safe;
use BSD::Resource;

use constant pi => 3.14159265358979;
use constant e  => 2.718281828459045;

sub log10 {
    my $n = shift;
    return log($n) / log(10);
}

sub log2 {
    my $n = shift;
    return log($n) / log(2);
}

sub fac {
    my $f = shift;
    my $s = 1;
    my $i;
    for ( $i = 2 ; $i <= $f ; $i++ ) {
        $s *= $i;
    }
    return $s;
}

sub r2d { $_[0] * 180.0 / pi }

sub tan {
    my $z = shift;
    return sin($z) / cos($z);
}

my $calc = new Safe;

$calc->permit_only(qw( time localtime gmtime padany :base_math :base_core ));

$calc->share(qw( pi e log10 log2 fac rad tan ));

my $arg = $ARGV[0];

$arg =~ s/,/./g;

setrlimit(RLIMIT_VMEM, 8*1024*1024, -1);
setrlimit(RLIMIT_CPU, 2, -1);
setrlimit(RLIMIT_CORE, 0, -1);

$SIG{'__WARN__'} = sub { die $_[0] };

my $res = $calc->reval($arg);

$SIG{'__WARN__'} = 'DEFAULT';

if ( defined($res) ) {
    print "$res\n";
} else {
    my $error = $@;
    $error =~ s/^(.+) at (.+)$/$1/;
    print "Error: ", $error;
}

