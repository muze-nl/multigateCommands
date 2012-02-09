#!/usr/bin/perl

use strict;
use DateTime;
use DateTime::Event::Sunrise;

my $tz = 'Europe/Amsterdam';

# locations
my %locations = ( # lc(name) => [ name, lat, long ]
	# City hall Enschede: f = 52 13' 13.5" N, l = 6 53' 50.8" E
	'enschede' => [ 'Enschede', 52.22041, 6.89744 ],
);

open LOC, '<', 'xearth.markers' or die "Cannot op xearth.markers\n";

while(<LOC>) {
	if ( /^\s*(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+"([\w'. -]+)"/ ) {
		my ($lat, $long, $loc) = ($1, $2, $3);
		$locations{lc($loc)} = [ $loc, $lat, $long ];
	}
}

close LOC; 

# default location
my $location = 'Enschede';

my $loc = shift;
if (defined $loc && $loc =~ /\S/) {
	$loc =~ s/^\s+//;
	$loc =~ s/\s+$//;
	$location = $loc;
}

$location = "\u\L$location";
unless (defined $locations{lc($location)}) {
	print "Lokatie '$location' niet gevonden.\n";
	exit 0;
}

($location, my $lat, my $long) = @{$locations{lc($location)}};

sub DateTime::Event::Sunrise::carp {
	my $msg = shift;
	chomp $msg;
	print "[$location] $msg\n";
	exit 0;
}

my $dt = DateTime->now;

my $sunrise = DateTime::Event::Sunrise->new( longitude => $long, latitude => $lat, iteration => 1 );

my $op    = $sunrise->sunrise_datetime($dt);
my $onder = $sunrise->sunset_datetime($dt);

$op->set_time_zone($tz);
$onder->set_time_zone($tz);

print "[$location] zon op ", $op->hms, " zon onder ", $onder->hms, "\n";
