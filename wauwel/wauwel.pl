#!/usr/bin/perl -w
use strict;
my @first = (
    "geïntegreerde ", "collectieve ",  "parallelle ",      "graduele ",
    "schematische ",  "formatieve ",   "optimale ",        "gesynchroniseerde ",
    "functionele ",   "optionele ",    "geobjectiveerde ", "uitgekristalliseerde ",
    "normatieve ",    "progressieve ", "decentrale ",      "centrale ",
    "strategische ",  "pseudo-",       "duurzame "
);
my @second = (
    "beleids",   "rationaliserings", "systeem",       "management", "productiviteits", "normaliserings",
    "structuur", "utiliteits",       "ontwikkelings", "organisatie"
);
my @third = (
    "standaardisatie", "synthese",  "inschaling",   "mobiliteit",    "analyse",    "programmering",
    "fasering",        "projectie", "stabilisatie", "flexibiliteit", "rapportage", "participatie",
    "bevordering"
);

my $result = $first[ rand(@first) ] . $second[ rand(@second) ] . $third[ rand(@third) ];

print "$result\n";
