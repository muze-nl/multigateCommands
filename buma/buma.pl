#!/usr/bin/perl -w
use strict;
my @first = (
    "Ik kan nu geen bier drinken",
    "Ik kan nu niet programmeren",
    "We kunnen niet langer blijven",
    "We kunnen niet komen",
    "Ik heb al 3 dagen niet geirced",
    "Ik kan nu niet nerden",
    "Het komt niet zo goed uit als jullie nu koffie willen drinken",
    "We kunnen niet blijven eten",
    "Ik kon vanochtend weer niet uitslapen",
    "Ik weet dat het feest nog niet eens is begonnen, maar we moeten nu weg",
    "Ik kan niet meer nadenken",
    "Ik moet nu echt naar bed",
    "Ik kan niet meer naar Normaal",
);

my @second = (
    "we geen babysitter konden vinden",
    "de gordijnen gewassen moeten worden",
    "het gras nog gemaaid moet worden",
    "de kleine ons altijd om 5 uur 's ochtends wakker maakt",
    "we nog naar de ouderavond moeten",
    "we morgen vroeg naar de Efteling willen",
    "de stationwagen nog gestofzuigd moet worden",
    "de heg nog geknipt moet worden",
    "de rolcontainer nog naar voren gebracht moet worden",
    "de auto nog gewassen moet worden",
    "m'n schoonmoeder een week lang op bezoek is",
    "we in de file stonden bij de creche",
    "de appelstroop tegen het plafond zat",
    "de nicht van de broer van m'n zwager bevallen is",
    "ik de krultang nog moet repareren",
    "er alleen maar babyvoedsel in de koelkast staat",
    "sesamstraat over 30 minuten begint",
    "we nog een caravan moeten gaan uitzoeken",
    "de caravan nog gewassen moet worden",
    "de kinderkamer nog behangen moet worden",
    "we morgen naar de voetbalwedstrijd van onze jongste moeten",
    "we de oudste van ons nog naar blokfluitles moeten brengen",
    "het eten anders koud wordt",
    "de ramen nog gelapt moeten worden",
    "de kinderen nu achter de PC zitten",
    "om 7:30 de aannemer voor de deur zal staan",
    "ik mijn bonsai-knipkruk nog moet schilderen",
    "er een oud-ijzerboer de fietswrakken komt ophalen"
);

my $result = $first[ rand(@first) ] . " omdat " . $second[ rand(@second) ] . ".";

print "$result\n";
