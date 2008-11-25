#!/usr/bin/perl
#
# Genereert goede nieuwe formats voor tv programma's 
# CJ 2008 (verveeld in de trein, buiten sneeuwt het)
#
use strict;
use warnings;

my @who = ("sterren", "koks", "buren", "krantenbezorgers", "tuinmannen", "voetballers");
my @extra_who = ("de kinderen van", "schoonmoeders van", "vrouwen van");
my @what = ("dansen", "koken", "tuinieren", "zingen", "schaatsen", "lezen", "zwemmen", "klussen", "" );
my @where = ("op het ijs", "in de tuin", "in de keuken", "in zee", "op het strand", "in de sneeuw", "op een berg", "op de camping", "in een tent", "" );

my $format = $who[int rand(@who)] . " " . $what[int rand(@what)] . " " . $where[int rand(@where)] . ".";

if (rand() < 0.15) {
   $format = $extra_who[int rand(@extra_who)] . " " . $format;	
}	

$format = ucfirst($format);

if (rand() < 0.10) {
   $format = "HELP! " . $format;	
}

print $format , "\n";