#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# joost@dnd.utwente.nl

use strict;
use LWP::UserAgent;

my ( $taal, $woord, $prut ) = split ' ', $ARGV[0], 3;

$taal  = lc($taal);
$woord = lc($woord);

my %taalurl = (
    'en' => "DutchEnglish",
    'ne' => "EnglishDutch",
    'fn' => "DutchFrench",
    'nf' => "FrenchDutch",
    'nd' => "GermanDutch",
    'dn' => "DutchGerman",
    'ni' => "ItalianDutch",
    'in' => "DutchItalian",
    'ns' => "SpanishDutch",
    'sn' => "DutchSpanish",
    'np' => "PortugueseDutch",
    'pn' => "DutchPortuguese",
    'nl' => "LatinDutch",
    'ln' => "DutchLatin",
    'nz' => "SwedishDutch",
    'zn' => "DutchSwedish",
    'na' => "AfrikaansDutch",
    'an' => "DutchAfrikaans"

    #    'ne' => "EsperantoDutch",
    #    'en' => "DutchEsperanto"
);

unless ( ( defined $taalurl{$taal} ) && defined $woord ) {
    print "Geef bestaande taalcode en 1 woord. (Bv. \"vertaal ne bier\")\n";
    exit 0;
}

# bepaal juiste pagina
my $url = "http://dictionaries.travlang.com/" . $taalurl{$taal} . "/dict.cgi?query=$woord&max=20";

#Haal pagina  op
my $ua = new LWP::UserAgent;

#Set agent name, vooral niet laten weten dat we een script zijn
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $result  = $ua->request($request);

unless ( $result->is_success ) {
    print "Error opening page\n";
    exit 0;
}

my $content = $result->content;

#alles tussen <pre> en </pre>
$content =~ s/^.*?<pre>(.*?)<\/pre>.*?$/$1/is;

my @lines = split /^/m, $content;

# Zoek de goede regel
my $result;
my $aantal = 0;
foreach my $line (@lines) {
    if ( $line =~ /^(\S+)/i ) {
        $result .= "$1 ";
        $aantal++;
    }
}

if ($aantal) {
    print "$woord: $result\n";
} else {
    print "Niets gevonden\n";
}
