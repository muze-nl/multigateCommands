#!/usr/bin/perl -w
use strict;
my @first = (
    "Onvoldoende bescherming tegen",       "Onderzoek naar",
    "Nieuwe geluidsopnames gevonden over", "Stijgend kritiek op",
    "Eindelijk uitsluitsel over",          "Snelle verslechtering van",
    "Wetenschappers ontdekken",            "Hevige gevechten over",
    "Winst en hogere omzet uit",           "Aanvalsplan tegen",
    "Mogelijk verbod van",                 "Granaten afgevuurd op",
    "Boetes voor",                         "Groot onderzoek naar",
    "In cel wegens",                       "Eminems ex onthult",
    "Woede over",                          "Hevige opspraak over",
    "Patty Brard betaalt",                 "Nieuwe onthullingen over",
    "President Bush verklaart:",           "Bram Peper ontkent",
    "Uitsluitsel gegeven over",            "Topman stapt op na",
    "Osama Bin Laden dreigt met",          "Grootschalige controles over",
    "Algehele verwarring over",
);

my @second = (
    "Nederlands kamp",         "pesten",               "vastbinden patienten",          "aardverschuiving",
    "bomaanslagen",            "scholierenexperiment", "Nederlands kabinet",            "jongeren",
    "kwartaalwinst Ebay",      "moslim extremisten",   "Premier Balkenende",            "Koninklijk huis",
    "grootschalige ontslagen", "diepgaand onderzoek",  "nieuw bewijs",                  "onthullende feiten",
    "blikseminslagen",         "belastingfraude",      "dopinggebruik",                 "grote olieramp",
    "gezellige mensen",        "nucleair afval",       "vuurwerkrampen",                "zedenschandaal",
    "dijkdoorbraken",          "illegale hennepteelt", "gedoogbeleid omtrent softdrugs",
);

my @third = (
    "in Irak",                         "op het werk",
    "in Afghanistan",                  "in verpleeghuis",
    "in Indonesie",                    "op de vrije markt",
    "bij Motorola",                    "in Hollywood",
    "onder een brug",                  "op de rails",
    "in een treinstation",             "nabij de A1",
    "in het hoofdkantoor van Philips", "op straat",
    "van de baan",                     "op de werkvloer",
    "in een nabijgelegen land",        "in de middenlandse zee",
    "in de Kalverstraat",              "van het Irakese volk",
    "in diverse concerns",             "bij verschillende bedrijven",
    "op het universiteitsterrein",     "in een nabij gelegen militair kamp",
);

my $result = $first[ rand(@first) ] . " " . $second[ rand(@second) ] . " " . $third[ rand(@third) ];

print "$result\n";
