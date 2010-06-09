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

my $loc = shift;
if (defined $loc && $loc =~ /\S/) {
	$loc =~ s/^\s+//;
	$loc =~ s/\s+$//;
	$location = $loc;
}

$location = "\u\L$location";
unless (defined $locations{$location}) {
	print "Lokatie '$location' niet gevonden.";
	exit 0;
}

my ($lat, $long) = @{$locations{$location}};

my $url = "http://gps.buienradar.nl/getrr.php?lat=$lat&lon=$long";
my $response = $ua->get($url);

unless ($response->is_success) {
	print "Kan buienradar.nl niet bereiken.\n";
	exit 0;
}

my $data = $response->content;

unless ($data =~ /\A(\d{3}\|\d{2}:\d{2}\r?\n)*\z/) {
	print "Kan buienradar.nl gegevens niet verwerken.\n";
	exit 0;
}

my @res = (); # [ begin, end, value ]
while ($data =~ s/\A(\d{3})\|(\d{2}:\d{2})\r?\n//) {
	my ($waarde, $tijd) = ($1, $2);

	if ($waarde eq '000') {
		$waarde = 'droog';
	} else {
		$waarde = sprintf '%.3f mm/h', 10 ** (($waarde - 109)/32);
	}
	if (@res && $res[-1][2] eq $waarde) {
		$res[-1][1] = $tijd;
	} else {
		push @res, [ $tijd, $tijd, $waarde ];
	}
}

print join('; ', map { ($_->[0]eq$_->[1]?$_->[0]:$_->[0] . '-' . $_->[1]) . ': '. $_->[2] } @res), " (Bron: buienradar.nl)\n";
