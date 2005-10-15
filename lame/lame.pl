#!/usr/bin/perl -w
use strict;

sub cmd_lamer {
    my ($data) = @_;
    if ($data) {
        my $x;
        $_ = $data;
        s/./$x=rand(6);$x>3?lc($&):uc($&)/eg;
        s/a/4/gi;
        s/c/(/gi;
        s/d/|)/gi;
        s/e/3/gi;
        s/f/|=/gi;
        s/h/|-|/gi;
        s/i/1/gi;
        s/k/|</gi;
        s/l/|_/gi;
        s!m!/\\/\\!gi;
        s!n!/\\/!gi;
        s/o/0/gi;
        s/s/Z/gi;
        s/t/7/gi;
        s/u/|_|/gi;
        s!v!\\/!gi;
        s!w!\\/\\/!gi;
        print "$_\n";
    }
}
cmd_lamer( join ( ' ', @ARGV ) );

