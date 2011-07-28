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
my $do_exact = 0;

while ($loc =~ s/\A--(\w+) //) {
	my $opt = lc $1;
	if ($opt eq 'ascii') {
		$do_ascii++;
	} elsif ($opt eq 'color') {
		$do_color++;
	} elsif ($opt eq 'colour') {
		$do_color++;
	} elsif ($opt eq 'exact') {
		$do_exact++;
	} else {
		print "Onbekende optie '$opt'.\n";
		exit 0;
	}
}

if ($loc =~ /\S/) {
	$loc =~ s/^\s+//;
	$loc =~ s/\s+$//;
	if (lc($loc) eq 'aan' || lc($loc) eq 'uit') {
		print "Niet genoeg rechten.\n";
		exit 0;
	}
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
while ($data =~ s/\A(\d{3})\|(\d{2}:\d{2})\r?\n//) {
	my ($waarde, $tijd) = ($1, $2);

	$ascii //= "$tijd\cC14,1|";

	$waarde =~ s/\A0+(\d)/$1/;

	if ($waarde == 0) {
		$waarde = 'droog';
		$ascii .= "\cC15,1 ";
	} else {
		$waarde = 10 ** (($waarde - 109)/32);

		$ascii
			.= $waarde < 0.400 ? "\cC3,1_"  # motregen
			:  $waarde < 1.000 ? "\cC9,1."  # regen
			:  $waarde < 10.00 ? "\cC8,1-"  # veel regen
			:  $waarde < 50.00 ? "\cC4,1~"  # hoosbui
			:  "\cC5,1`";             # mayhem?

		if ($do_exact) {
			$waarde = sprintf '%.3f mm/h', $waarde;
		} elsif ($waarde < 0.4) {
			$waarde = 'motregen';
		} elsif ($waarde < 1.0) {
			$waarde = 'regen';
		} elsif ($waarde < 10.0) {
			$waarde = 'veel regen';
		} elsif ($waarde < 50.0) {
			$waarde = 'hoosbui';
		} else {
			$waarde = 'total mayhem';
		}
	}

	$ascii .= "\cC14,1|" if $tijd =~ /:[25]5\z/;

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
	$out .= join("\cC14;\cC ", map { ($_->[0]eq$_->[1]?$_->[0]:$_->[0] . "\cC14-\cC\c_\c_" . $_->[1]) . "\cC14:\cC10 ". $_->[2]."\cC" } @res);
}
$out .= "\cC\cC14 (Bron: buienradar.nl)\cC\n";

$out =~ s/\cC(?:\d+(?:,\d+)?)?//g unless $do_color;

print $out;
