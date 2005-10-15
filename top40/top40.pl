#!/usr/bin/perl -w
#Copyright script: Casper Joost Eyckelhof
#Copyright top40: respective owner (currently wanadoo)

@top40 = `w3m -dump http://www.wanadoo.nl/top40/charts/index_1.html`;
my @chart = ();

foreach $nummer (@top40) {
    if ( $nummer =~ /\d{1,2}\s+([-\d]+)\s+([-\d]+)\s+(.*?)\s-\s(.*?)\s+#.*$/ ) {
        $vorig       = $1;
        $aantalweken = $2;
        $artiest     = $3;
        $song        = $4;
        push @chart, "$artiest - $song (vw: $vorig ; aw: $aantalweken)";
    }
}

my $pos;
if ( ( defined $ARGV[0] ) && ( $ARGV[0] =~ /\d+/ ) ) {
    $pos = $ARGV[0];
} else {
    $pos = 1;
}

if ( ( $pos < 1 ) || ( $pos > 40 ) ) {
    $pos = 1;
}

print "Nummer $pos in de top-40 is: $chart[$pos-1]\n";
