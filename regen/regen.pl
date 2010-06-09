#!/usr/bin/perl -w

use strict;
use LWP::UserAgent;
use HTTP::Cookies;

my @user_agents = (
		'Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)'
	);

my $ua = LWP::UserAgent->new(
		#Set agent name, we are not a script! :)
		agent		=> $user_agents[rand @user_agents],
		cookie_jar	=> HTTP::Cookies->new(),
	);

# locations
my %locations = (		# [ lat, long ]
		# City hall Enschede: f = 52 13' 13.5" N, l = 6 53' 50.8" E
		'Enschede'	=> [ 52.22041,  6.89744 ],
);

if (open LOC, '<', '../zon/xearth.markers') {
	# FIXME: we need a global database for this
	while(<LOC>) {
		if ( /^\s*(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+"([\w'. -]+)"/ ) {
			my ($lat, $long, $loc) = ($1, $2, $3);
			$locations{$loc} = [ $lat, $long ];
#	        print "$loc : $lat $long\n";
		}
	}
	close LOC; 
} else {
	warn "Cannot open xearth.markers: $!\n";
}

# default location
my $location = 'Enschede';

my $loc = join(' ', @ARGV);
$loc =~ s/\s+/ /g;
$loc =~ s/\A\s//;
$loc =~ s/\s\z//;
$loc .= ' ';

my $do_ascii = 0;
my $do_color = 0;

while ($loc =~ s/\A--(\w+) //) {
	my $opt = lc $1;
	if ($opt eq 'ascii') {
		$do_ascii++;
	} elsif ($opt eq 'color') {
		$do_color++;
	} else {
		print "Onbekende optie '$opt'.\n";
		exit 0;
	}
}

if (defined $loc && $loc =~ /\S/) {
	$loc =~ s/^\s+//;
	$loc =~ s/\s+$//;
	$location = $loc;
}

my @locs = grep { lc($location) eq lc($_) } keys %locations;
unless (@locs == 1) {
	print "Lokatie '$location' niet gevonden.\n";
	exit 0;
}
$location = $locs[0];

my ($lat, $long) = @{$locations{$location}};

my $url = "http://gps.buienradar.nl/getrr.php?lat=$lat&lon=$long";
my $response = $ua->get($url);

unless ($response->is_success) {
	print "Kan buienradar.nl niet bereiken.\n";
	exit 0;
}

my $data = $response->content;

unless ($data =~ /\A(\d{3}\|\d{2}:\d{2}\r?\n)+\z/) {
	print "Kan buienradar.nl gegevens niet verwerken.\n";
	exit 0;
}

my @res = (); # [ begin, end, value ]
my $ascii = undef;
my $i = 0;
while ($data =~ s/\A(\d{3})\|(\d{2}:\d{2})\r?\n//) {
	my ($waarde, $tijd) = ($1, $2);

	$ascii //= "$tijd|";

	$waarde =~ s/\A0+(\d)/$1/;

	if ($waarde == 0) {
		$waarde = 'droog';
		$ascii .= ' ';
	} else {
		$waarde = 10 ** (($waarde - 109)/32);

		$ascii
			.= $waarde < 1.000 ? '_'  # motregen
			:  $waarde < 10.00 ? '.'  # regen
			:  $waarde < 20.00 ? '-'  # veel regen
			:  $waarde < 100.0 ? '~'  # hoosbui
			:  '`';                   # mayhem?

		if ($waarde < 1.0) {
			$waarde = 'motregen';
		} else {
			$waarde = sprintf '%.3f mm/h', $waarde;
		}
	}

	$ascii .= '|' if $i++ % 6 == 5;

	if (@res && $res[-1][2] eq $waarde) {
		$res[-1][1] = $tijd;
	} else {
		push @res, [ $tijd, $tijd, $waarde ];
	}
}

my $out = "\cC2[\cC12$location\cC2]\cC ";
if ($do_ascii) {
	$out .= $ascii;
} else {
	$out .= join("\cC14;\cC ", map { ($_->[0]eq$_->[1]?$_->[0]:$_->[0] . '-' . $_->[1]) . ":\cC10 ". $_->[2]."\cC" } @res);
}
$out .= "\cC14 (Bron: buienradar.nl)\cC\n";

$out =~ s/\cC(?:\d+(?:,\d+)?)?//g unless $do_color;

print $out;
