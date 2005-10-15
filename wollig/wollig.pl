#!/usr/bin/perl -w
use strict;
my @first = (
    "creatief ",   "een stukje ", "holistisch ", "existentieel ", "lichamelijk ", "geestelijk ",
    "spiritueel ", "religieus ",  "dynamisch "
);
my @second = (
    "omvattend ",  "vervullend ",    "sociaal ",   "vermenselijkend ", "wezenlijk ", "groepsmatig ",
    "natuurlijk ", "binnenwerelds ", "innerlijk ", "kritisch "
);
my @third = (
    "aanreiken",   "duiden",             "omvatten",       "invoelen",           "verwerken", "anders-zijn",
    "jezelf-zijn", "naar-de-ander-gaan", "verwerkelijken", "vermaatschappelijken"
);

my $result = $first[ rand(@first) ] . $second[ rand(@second) ] . $third[ rand(@third) ];

print "$result\n";
