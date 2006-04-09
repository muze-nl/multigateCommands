#!/usr/bin/perl -w 

# Script om in de televisie van vandaag te zoeken
# Geschreven in het kader van DND Progathon 2000
# Copyright: Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl
#
# Gebaseerd op v1.0 door Ylebre en Titanhead
# v2.0: 16 Januari 2000; gegevens van multiguide
# v2.1: 19 Januari 2000; commandline paramater "film"
# v3.0: 28 Juni 2001; zoek in lokale cache, gemaakt met tvdump
# v3.1: 28 Augustus 2001; snapt ook zender als argument (wat is er nu op zender?)
# v4.0: 25 Februari 2002; nog meer commandline opties + slimmer sorteren
# v4.1: 13 Augustus 2004; grapje met "iets leuks"
# v5.0: 22 Mei 2005; rewrite of a lot of subs, general code cleanup and some minor fixes (angel_7th)

#### allerlei fijne definities en initialisaties ########
use strict;
use warnings;

my $maxoutput = 25;
my $aantal    = 5;
my $aantalset = 0;

my $filmzoeken = 0;
my $nuoptv     = 0;
my $straksoptv = 0;
my $tijdstip;
my $dummy;

my @output  = ();
my $datadir = "./data";

if( ! -e $datadir ) {
	print "Instaleer de data fetcher cronjob of een symlink naar een bestaande data directory\n";
	exit 0;
}

my $is_multicast = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)

## Welke zenders zijn beschikbaar?
my %zenders;
opendir( BIN, $datadir ) or die "Can't open $datadir: $!";
while ( defined( my $file = readdir BIN ) ) {
	if ( ( -T "$datadir/$file" ) && ( -s "$datadir/$file" ) ) {
		$zenders{ lc($file) } = $file;
	}    #hash from lowercase to realname
}
close BIN;

# alles dat in de "tv nu" getoond moet worden
my @nuzenderlijst = qw(Nederland1 Nederland2 Nederland3 RTL4 RTL5 SBS6 Net5 RTL7 BBC1 BBC2 Veronica);

my %aliases = (
		"ned1"    => "nederland1",
		"ned2"    => "nederland2",
		"ned3"    => "nederland3",
		"brt1"    => "vrt_tv1",
		"tv1"     => "vrt_tv1",
		"belgie1" => "vrt_tv1",
		"ketnet"  => "ketnet_canvas",
		"canvas"  => "ketnet_canvas",
		"brt2"    => "ketnet_canvas",
		"v8"      => "veronica",
		"fox"     => "veronica",
		"disc"    => "discovery",
		"rtlvijf" => "rtl5",
		"rtlvier" => "rtl4",
		"yorin"   => "rtl7",
        "tien"    => "talpa",
		);

my %nulijst = ();
my $item;
foreach $item (@nuzenderlijst) {
	$nulijst{ lc($item) } = 1;
}

my $thishour   = int( (localtime)[2] );
my $thisminute = int( (localtime)[1] );

#0 tot 6 wordt 24 tot 30
if ( $thishour < 6 ) {
	$thishour += 24;
}

####### Handige subjes :) #########

### Start of angel_7th rewrite code

#
# Sub to convert a string time to a pair of numbers, while correcting for a natural day-night rythm
#

sub convert_time($) {
	my $tijd = shift;
	my ( $hour, $minute ) = $tijd =~ /(\d+)[\.:](\d+)/;
	if ( $hour < 6 ) { $hour += 24; }
	return ($hour, $minute);
}

#
# Adaptation of time-scoring to normal datastructures;
#
sub sort_time_score($) {
	my $program = shift;
	my $delta = (60 * $program->{'hour'} + $program->{'minute'} ) - (60 * $thishour + $thisminute );

	my $score;
	if ( $delta >= 0 ) {
		$score = 20 - ( $delta / 18 );    #20 - 1/18 t
	} else {
		$score = 20 + ( $delta / 6 );    #20 + 1/6 t
		if ( $delta < 60 ) {
			$score -= 10;
		}
	}

	return $score;
}

#
# Adaptation of sub bytime to a normal datastructure
#
sub sort_time() {
	return sort_time_score($b) <=> sort_time_score($a);
}

#
# Sub to load all program info for a zender
#
# returns a arrayref of hashrefs containing the following keys:
#
# line : the literal line from the file
# list : the list (tijd, film, naam, beschrijving, prut) as used in other (older) subs
# zender : the channel
#
# tijd
# film
# naam
# beschrijving
# prut
#
# hour
# minute
#
# vtijd : the end time of the program
# vhour
# vminute

sub load_zender($) {
	my $zender = shift;
	open( ZENDER, "< $datadir/$zender" ) or die "Cannot open $zender\n";
	my @lines = <ZENDER>;
	close ZENDER;
	chomp @lines;

	my @results = ();
	while (@lines) {
		my $line = shift @lines;
		my @list = split /\xb6/, $line;
		my ( $tijd, $film, $naam, $beschrijving, $prut ) = @list;

		my ($vtijd, $vhour, $vminute) = ('??.??', 31, 00); # Ugly magic number, 30 is max hour

		if (defined $lines[0]) { # We can determine an end time
			($vtijd) = $lines[0] =~ m/^(.*?)\xb6/;
			($vhour, $vminute) = convert_time($vtijd);
		}

		my ($hour, $minute) = convert_time($tijd);

		my $prog_ref = {
			zender => $zender,
			line => $line,
			list => \@list,

			tijd => $tijd,
			film => $film,
			naam => $naam,
			beschrijving => $beschrijving,
			prut => $prut,

			hour => $hour,
			minute => $minute,

			vtijd => $vtijd,
			vhour => $vhour,
			vminute => $vminute,
		};

		push @results, $prog_ref;
	}

	return \@results;
}

#
# Adaptation of the zoek sub
#
sub search($$) {
	my ( $term, $count ) = @_;
	my $regex = qr{\Q$term\E}i;
	#patch voor gwen, laser en diddlien:
    if (lc($term) eq 'csi') {
       $regex = qr{$regex|(Crime Scene Investigation)}i;
    }
    my @resultlist;
	foreach my $zender ( values %zenders ) {
		my @programs = @{load_zender($zender)};
		foreach my $program (@programs) {
			my $naam = $program->{'naam'};
			if ( ( $naam =~ /$regex/ ) && ( $naam !~ /Trekking/i ) ) { # but... WHY?!
				push @resultlist, $program;
			}
		}
	}
	my @sortedresult = sort { sort_time } @resultlist;
	my @results = splice @sortedresult, 0, $aantal;
	return \@results;
}

#
# subs to pretty-print program structures
#
sub program_to_string_short($) {
	my $program = shift;
	return $program->{'zender'} . ' : ' . $program->{'tijd'} . ' - ' . $program->{'vtijd'} . ' ' . $program->{'naam'};
}

#
# Rewrite of sub films to return a sorted list of n films
#

sub films($) {
	my $aantal = shift;
	my @resultlist;
	foreach my $zender ( values %zenders ) {
		my @programs = @{load_zender($zender)};
		foreach my $program (@programs) {
			if ( $program->{'film'} eq "F" ) {
				push @resultlist, $program;
			}
		}
	}
	my @sortedresult = sort { sort_time } @resultlist;
	my @results = splice @sortedresult, 0, $aantal;
	return \@results;
}

#
# now(zender, tijd, aantal) 
# geeft voor zender de huidige en volgende aantal-1 programma's
#
# Rewrite of nu()
# 

sub now {
	my ( $nuzender, $nutijd, $nuaantal ) = @_;

	my ( $nuhour, $numinute ) = convert_time($nutijd);
	my @programs = @{ load_zender($zenders{lc($nuzender)}) };

	my $found = 0;
	while (@programs) {
		my $program = $programs[0];
		if ($program->{'vhour'} < $nuhour or ($program->{'vhour'} == $nuhour and $program->{'vminute'} < $numinute)) {
			shift @programs
		} else {
			last;
		}
	}

	my @results = splice @programs, 0, $aantal;
	return \@results;
}

### End of angel_7th rewrite code

sub min2 {
	my ( $a, $b ) = @_;
	if ( $a < $b ) {
		return $a;
	} else {
		return $b;
	}
}

sub isZender {
	my $zender = shift;
	foreach ( keys %zenders ) {
		if ( $_ eq lc($zender) ) { return 1; }
	}
	return 0;
}

if ( ( @ARGV == 0 ) || ( $ARGV[0] eq "" ) ) {
	print "tv <zoekterm> doet het beter.\n";
} else {
	my $zoekstring = $ARGV[0];

# Preprocessing for special stuff
	if ($zoekstring =~ /^iets leuks$/i) {
		my @opties = keys %zenders;
		$zoekstring = $opties[ int rand @opties ];  # random zender
	}


## Extra goodies/opties uit $zoekstring halen

	if ( $zoekstring =~ /^(.*?\s*)(\d{1,2}[.:]\d{2})\s*(.*?)$/ ) {
		$zoekstring = $1 . " " . $3;
		$tijdstip   = $2;
		$tijdstip =~ s/:/./;

# We doen dus alsof het nu een andere tijd is:
# Jaja, bah bah, globaal (maar anders kan sort er niet bij)

		( $thishour, $thisminute ) = split /\./, $tijdstip, 2;

#0 tot 6 wordt 24 tot 30
		if ( $thishour < 6 ) {
			$thishour += 24;
		}

		if ( $zoekstring =~ /^\s*$/ ) {
			$nuoptv = 1;
		}    #alleen een tijd, verder niks
	}

	if ( $zoekstring =~ /^(.*?)\s(\d+)$/ ) {
		$zoekstring = $1;
		$aantal     = min2( $2, $maxoutput );
		$aantalset  = 1;
	}

	if ( $zoekstring =~ /^film\s*(.*?)$/i ) {
		$filmzoeken = 1;
		$zoekstring = $1;
	}

#remove trailing and prefix whitespace 
	$zoekstring =~ s/^\s+//;
	$zoekstring =~ s/\s+$//;

	if ( lc($zoekstring) eq "nu" ) {
		$nuoptv = 1;
	}

	if ( lc($zoekstring) eq "straks" ) {
		$straksoptv = 1;
	}

	if ( defined( $aliases{ lc($zoekstring) } ) ) {
		$zoekstring = $aliases{ lc($zoekstring) };
	}

## Alle opties zijn uit de zenderstring gehaald, er zit nu nog in:
#  zender of zoekterm

	if ( $nuoptv || ( $straksoptv && ( defined $tijdstip ) ) ) {
		my $tijdzoek = "$thishour.$thisminute";
		if ( defined $tijdstip ) {
			$tijdzoek = $tijdstip;
		}
		foreach (@nuzenderlijst) {
			my $zender = lc($_);
			if ( isZender($zender) ) {
				my $results = now( $zender, $tijdzoek, 1 );
				unless (scalar @{$results} < 1) {
					push @output, program_to_string_short($results->[0]);
				}
			}
		}
	} elsif ($straksoptv) {
		my $tijdzoek = "$thishour.$thisminute";
		if ( defined $tijdstip ) {
			$tijdzoek = $tijdstip;
		}
		foreach (@nuzenderlijst) {
			my $zender = lc($_);
			if ( isZender($zender) ) {
				my $results = now( $zender, $tijdzoek, 2 );
				unless (scalar @{$results} < 2) {
					push @output, program_to_string_short($results->[1]);
				}
			}
		}
	} elsif ($filmzoeken) {
		@output = map { program_to_string_short($_) } @{films($aantal)};
	} elsif ( isZender($zoekstring) ) {
		my $zender = lc($zoekstring);
		my $tijd = "$thishour.$thisminute";
		if ( defined $tijdstip ) {
			$tijd = $tijdstip;
		}
		$aantal = 1 unless $aantalset;
		@output = map { program_to_string_short($_) } @{now( $zoekstring, $tijd, $aantal )};
	} else {
		@output = map { program_to_string_short($_) } @{search($zoekstring, $aantal)};
	}

### Afdrukken uitvoer ###
	foreach (@output) {
		print "$_\n";
	}

# Geen uitvoer...
	if ( @output == 0 ) {
		print "Geen programma's gevonden\n";
	}

}
