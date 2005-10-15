#!/usr/bin/perl
# Apr 01 2003 Jorik Jonker
use strict;

my $word;
my $output;
my @wordarr;
my $count;
my $c;

foreach $word (@ARGV) {
    $word =~ tr/A-Z/a-z/;

    $word =~ s/\bmijn\b/muh/g;

    $word =~ s/([^ieo])en([^ngaoe])/$1uh$2/g;
    $word =~ s/([^ieo])e\b/$1uh/g;

    $word =~ s/(\w)je(s)?\b/$1juh$2/g;
    $word =~ s/([^ioer])es\b/$1uz/g;

    $word =~ s/s/z/g;
    $word =~ s/([^eo ])er\b/$1ah/g;
    $word =~ s/ch/g/g;
    $word =~ s/\?/¿/g;
    $word =~ s/\beven\b/ff/g;

    $word =~ s/(.)(.)/\u$1\l$2/g;

    $output .= " $word";

}
$output =~ s/^ //g;

print "$output\n";
