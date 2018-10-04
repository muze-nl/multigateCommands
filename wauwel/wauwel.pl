#!/usr/bin/perl -w
use strict;
my @first = (
    "geïntegreerde ", "collectieve ",  "parallelle ",      "graduele ",
    "schematische ",  "formatieve ",   "optimale ",        "gesynchroniseerde ",
    "functionele ",   "optionele ",    "geobjectiveerde ", "uitgekristalliseerde ",
    "normatieve ",    "progressieve ", "decentrale ",      "centrale ",
    "strategische ",  "pseudo-",       "duurzame ",        "ingebouwde ",
    "innoverende", ", "community-driven", "exponentiële",  "circulaire",
    "revitaliserende"
);
my @second = (
    "beleids",   "rationaliserings", "systeem",       "management",  "productiviteits", "normaliserings",
    "structuur", "utiliteits",       "ontwikkelings", "organisatie", "smart-", "herstructurerings",
    "innovatie", "concept"
);
my @third = (
    "standaardisatie", "synthese",  "inschaling",   "mobiliteit",    "analyse",    "programmering",
    "fasering",        "projectie", "stabilisatie", "flexibiliteit", "rapportage", "participatie",
    "bevordering",     "blockchain", "maatschappij", "programma's",  "ontwikkeling", "omgeving"
    
);

my $result = $first[ rand(@first) ] . $second[ rand(@second) ] . $third[ rand(@third) ];

print "$result\n";
