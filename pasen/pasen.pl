#!/usr/bin/perl -w
use Date::Calc;
use strict;

my $year = $ARGV[0];

my %maand = (
    1  => "januari",
    2  => "februari",
    3  => "maart",
    4  => "april",
    5  => "mei",
    6  => "juni",
    7  => "juli",
    8  => "augustus",
    9  => "september",
    10 => "oktober",
    11 => "november",
    12 => "december"
);

unless ( defined $year && $year =~ /^\d+$/ ) {
    $year = (localtime)[5] + 1900;
    my ($y, $m, $d) = Date::Calc::Easter_Sunday($year);
    if ($m < ((localtime)[4]+1)) {
      $year++;
    } elsif (($m == (localtime)[4]+1) && ($d <= localtime[3])) {
      $year++;
    }
}

if ( $year < 1583 ) {
    print "Te lang geleden\n";
    $year = (localtime)[5] + 1900;
}

my ( $y, $m, $d ) = Date::Calc::Easter_Sunday($year);
print "Pasen $year valt op $d $maand{$m}\n";
