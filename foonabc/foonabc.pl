#!/usr/bin/perl -w
use strict;

my %table = (
    a => "Anton",
    b => "Bernard",
    c => "Cornelis",
    d => "Dirk",
    e => "Eduard",
    f => "Ferdinand",
    g => "Gerard",
    h => "Hendrik",
    i => "Izaak",
    j => "Jan",
    k => "Karel",
    l => "Lodewijk",
    m => "Marie",
    n => "Nico",
    o => "Otto",
    p => "Pieter",
    q => "Quotiënt",
    r => "Rudolf",
    s => "Simon",
    t => "Teunis",
    u => "Utrecht",
    v => "Victor",
    w => "Willem",
    x => "Xantippe",
    y => "Ypsilon",
    z => "Zaandam"
);

my $input = $ARGV[0];

$input =~ s/\W//g;
$input =~ s/([A-Za-z])/$table{lc($1)} /g;

print $input, "\n";

