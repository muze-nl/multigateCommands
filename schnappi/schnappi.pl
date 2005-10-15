#!/usr/bin/perl -w
use strict;

my $text = <<EOT;
Ich bin Schnappi das kleine Krokodil
komm aus Aegypten das liegt direkt am Nil
zuerst lag ich in einem Ei
dann schni schna schnappte ich mich frei
schni schna schnappi schnappi schnappi schnapp
schni schna schnappi schnappi schnappi schnapp
Ich bin Schnappi das kleine Krokodil
hab scharfe Zaehne und davon ganz schoen viel
ich schnapp mir was ich schnappen kann
ja schnapp zu weil ich das so gut kann
Ich bin Schnappi das kleine Krokodil
ich schnappe gern das ist mein Lieblingsspiel
ich schleich mich an die Mama ran
und zeig ihr wie ich schnappen kann
ich bin Schnappi das kleine Krokodil
und vom Schnappen da krieg ich nicht zuviel,
ich beiss den Papi kurz ins Bein
und dann dann schlafe ich einfach ein
EOT

my @lines = split /\n/, $text;
print $lines[ int( rand(@lines) ) ];

