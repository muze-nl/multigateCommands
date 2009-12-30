#!/usr/bin/perl -w

use strict;

my @linker_rechter = qw/ linker rechter /;
my @hand_voet = qw/ hand voet /;
my @kleur = qw/ rood groen blauw geel /;

print $linker_rechter[rand@linker_rechter], $hand_voet[rand@hand_voet], ' op ', $kleur[rand@kleur], "\n";
