#!/usr/bin/perl -w
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl

use LWP::UserAgent;
use HTTP::Cookies;
use strict;

#### allerlei fijne definities en initialisaties ########
my $ua     = new LWP::UserAgent;
my @agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);
my $agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

my $baseurl     = "http://www.aex.nl/scripts/pop/kb.asp?taal=nl&alf=";
my $commandline = $ARGV[0];

$commandline = "aex" unless ( defined $commandline );

sub getFonds {
    my $fonds = shift;
    $agent = @agents[ int( rand(@agents) ) ];
    $ua->agent($agent);
    my $request = new HTTP::Request( 'GET', $baseurl . $fonds );
    my $response = $ua->request($request);
    my $html     = $response->content;

    my @lines = split /\n/, $html;
    my @values = ();
    foreach my $line (@lines) {
        if ( $line =~ /^(\d+\.\d{2})/ ) {
            push @values, $1;
        }
    }
    my ( $current, $hoog, $laag, $open, $vorigslot ) = ( $values[0], $values[3], $values[4], $values[5], $values[6] );
    my %thisfonds = (
        "naam"      => $fonds,
        "koers"     => $current,
        "hoog"      => $hoog,
        "laag"      => $laag,
        "vorigslot" => $vorigslot,
        "open"      => $open
    );
    return %thisfonds;
}

sub america {
    my $fonds = shift;

    my $url = "http://www.fd.nl/TopMarkets.asp?Context=N%7C0&BgColor=%23E5E4D9";

    my $request = new HTTP::Request( 'GET', $url );
    my $response = $ua->request($request);
    my $html     = $response->content;
    my @lines    = split /\n/, $html;
    my %values   = ();
    foreach my $line (@lines) {

        ##   print "--> $line\n";
        ##                 AEX</a></td><td class="tabletekst" align="right">281,09</td><td class="tabletekst" align="right"><span style="color: #FF0000">-2,67%</span>
        if ( $line =~
            m|(\w+)</a></td><td class="tabletekst" align="right".*?>(\d+.*?,\d{2})</td><td class="tabletekst" align="right".*?><span style="color: #FF0000">(.*?)\%</span>|
          )
        {
            my $key  = lc($1);
            my $val  = $2;
            my $perc = $3;
            $val =~ s/\.//g;
            $val =~ s/,/./g;
            $values{$key} = $val;

            #print "HIT: $key - $val\n";

            if ( lc($fonds) eq $key ) {
                print "$fonds: $val ($perc)\n";
                exit 0;
            }

        }
    }
    print "Sorry, $fonds niet gevonden\n";
    exit 0;
}

if ( ( $commandline =~ /^aex/i ) || ( $commandline =~ /^nasd/i ) || ( $commandline =~ /^dow/i ) ) {
    my %values = america($commandline);
    if ( defined $values{koers} ) {
        print
          "$commandline: $values{koers}  open=$values{open}  hoogste=$values{hoog}  laagste=$values{laag}  slot vorig=$values{vorigslot} verschil="
          . sprintf( "%.2f", ( $values{koers} - $values{vorigslot} ) ) . "\n";
    } else {
        print "Bestaat $commandline wel? Kan het niet vinden.\n";
    }
} else {
    my %values = getFonds($commandline);
    if ( defined $values{koers} ) {
        print
          "$commandline: $values{koers}  open=$values{open}  hoogste=$values{hoog}  laagste=$values{laag}  slot vorig=$values{vorigslot} verschil="
          . sprintf( "%.2f", ( $values{koers} - $values{vorigslot} ) ) . "\n";
    } else {
        print "Bestaat $commandline wel? Kan het even niet vinden.\n";
    }
}
