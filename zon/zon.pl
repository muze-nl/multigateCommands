#!/usr/bin/perl -w

use strict;
use Astro::Sunrise;

# locations
my %locations = (		# [ lat, long ]
		# City hall Enschede: f = 52 13' 13.5" N, l = 6 53' 50.8" E
		'Enschede'	=> [ 52.22041,  6.89744 ],
);

open LOC, '<xearth.markers' or die 'Cannot op xearth.markers';

while(<LOC>) {
    if ( /^\s*(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+"([\w'. -]+)"/ ) {
        my ($lat, $long, $loc) = ($1, $2, $3);
        $locations{$loc} = [ $lat, $long ];
#        print "$loc : $lat $long\n";
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
unless (defined $locations{$location}) {
	print "Lokatie '$location' niet gevonden.";
	exit 0;
}

my ($lat, $long) = @{$locations{$location}};

my $op    = sun_rise( $long, $lat );
my $onder = sun_set( $long,  $lat );

print "[$location] zon op $op; zon onder $onder\n";
