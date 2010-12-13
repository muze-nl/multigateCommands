#!/usr/bin/perl -w
# Arjan Opmeer (Ado)
# ado@dnd.utwente.nl

use strict;
use LWP::UserAgent;
use URI::Escape;
use HTML::Entities;
use XML::Simple;


#
# SEARCH CITY
#
my $where = "Twenthe,Netherlands";
if (defined $ARGV[0]) {
	$where = uri_escape($ARGV[0]);
}
my $url = "http://weather.cnn.com/weather/citySearch?search_term=$where&filter=true";

# Create a new useragent instance
my $ua = new LWP::UserAgent;

# Set agent name. Don't let the other side know that we are a script
my $agent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
$ua->agent($agent);

# Fetch the requested page
my $httpresult = $ua->get($url);
unless ($httpresult->is_success) {
	print "Error opening cities search page: ";
	print $httpresult->status_line, "\n";
	exit 1;
}
my $content = $httpresult->content;

# And parse the returned XML 
my $xmlref = XMLin($content, ForceArray => 1);

unless (%$xmlref) {
	# An empty list means that nothing was found
	print "Could not find a city matching $where.\n";
	exit 0;
}

if (scalar @{$xmlref->{'LOCATION'}} > 1) {
	# Oh noes! Too many cities found
	print "Multiple possibilities: ";
	my $sep = 0;
	foreach my $location (@{$xmlref->{'LOCATION'}}) {
		if ($sep) {
			print "; ";
		}
		print "$location->{'city'},$location->{'stateorcountry'}";
		$sep = 1;
	}
	print "\n";
	exit 0;
}

# Well, only one left. This must be the place
my $code = $xmlref->{'LOCATION'}[0]->{'code'};
my $city = $xmlref->{'LOCATION'}[0]->{'city'};
my $soc = $xmlref->{'LOCATION'}[0]->{'stateorcountry'};
my $zip = $xmlref->{'LOCATION'}[0]->{'zip'};


#
# GET WEATHER INFO
#
$url = "http://weather.cnn.com/weather/intl/forecast.jsp?celcius=true&locCode=$code&zipCode=$zip";
$httpresult = $ua->get($url);
unless ($httpresult->is_success) {
	print "Error opening weather information page for $city, $soc: ";
	print $httpresult->status_line, "\n";
	exit 1;
}
$content = $httpresult->content;

#
# CURRENT
# 
# This is (roughly) the current condition part
$content =~ m|cnnWeatherForecastCurrentContent(.*?)cnnWeatherForecastCurrentDetails|s;
my $currentpart = $1;
# Extract the temperature and condition
$currentpart =~ m|cnnWeatherTempCurrent\">\s*(-*\d+)&deg;.*cnnWeatherConditionCurrent\">\s*(.*)\s*</span>|s;
my $currenttemp = $1;
my $currentcond = decode_entities($2);


my @forecastlist;

#
# TOMORROW
#
my $fcitem = {};
# This is (roughly) the tomorrow forecast part
$content =~ m|cnnWeatherHeader\">Tomorrow(.*?)cnnWireBoxFooter|s;
my $tomorrowpart = $1;
$tomorrowpart =~ m|cnnWeatherTimeStamp\">(.*?)</span>|s;
# Use only first three letters of day to match extended forecast
$fcitem->{'day'} = substr($1, 0, 3);
# Extract the temperatures and condition
$tomorrowpart =~ m|cnnWeatherTemp\">\s*Hi\s*(-*\d+)&deg;.*cnnWeatherTemp\">\s*Lo\s*(-*\d+)&deg;.*cnnWeatherCondition\">\s*(.*)\s*</span>|s;
$fcitem->{'temphi'} = $1;
$fcitem->{'templo'} = $2;
$fcitem->{'cond'} = decode_entities($3);
push(@forecastlist, $fcitem);

#
# EXTENDED
#
# This is (roughly) the extended forecast part
$content =~ m|<table class=\"cnnWeatherExtForecast\"(.*?)tableCornerBL|s;
my $extendedpart = $1;
# Loop over the table header to get the names of the days
my @extdayslist;
while ($extendedpart =~ m|<td class=\".*?\">\s*?(\w+?)\s*?<br />|gs) {
	push(@extdayslist, $1);
}
# Next loop over the table cells to get the temperatures and condition belonging to each day
my @extcondlist;
while ($extendedpart =~ m|cnnWeatherExtForecastDetails\">\s*?(-*\d+)&deg;.*?</span>\s*?(-*\d+)&deg;.*?cnnWeatherExtForecastDayCond\">\s*(.*?)\s*</span>|gs) {
	my $extcond = {};
	$extcond->{'temphi'} = $1;
	$extcond->{'templo'} = $2;
	$extcond->{'cond'} = decode_entities($3);
	push(@extcondlist, $extcond);
}

# Did we read as many cells as there are days?
if (scalar(@extdayslist) != scalar(@extcondlist)) {
	print "Bleh. Forecast data mismatch!\n";
	print "It is $currenttemp C ( $currentcond ) in $city, $soc\n";
	exit 1;
}

# OK. Join them and put them in the forecastlist
for my $i (0 .. $#extdayslist) {
	$fcitem = {};
	$fcitem->{'day'} = $extdayslist[$i];
	$fcitem->{'temphi'} = $extcondlist[$i]->{'temphi'};
	$fcitem->{'templo'} = $extcondlist[$i]->{'templo'};
	$fcitem->{'cond'} = $extcondlist[$i]->{'cond'};
	push(@forecastlist, $fcitem);
}

#
# OUTPUT
#
# Finally tell the world
print "It is $currenttemp C ( $currentcond ) in $city, $soc\n";

print "Forecast: ";
my $limit = $#forecastlist;
# Limit the number of days on a public channel
if ($ENV{'MULTI_IS_MULTICAST'}) {
	$limit = 2;
}
for my $i (0 .. $limit) {
	if ($i) {
		print "; ";
	}
	print "$forecastlist[$i]->{'day'} ";
	print "$forecastlist[$i]->{'temphi'} | ";
	print "$forecastlist[$i]->{'templo'} ";
	print $forecastlist[$i]->{'cond'};
}
print "\n";
