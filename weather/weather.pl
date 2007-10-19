#!/usr/bin/perl -w
# Arjan Opmeer (Ado)
# ado@dnd.utwente.nl

use strict;
use LWP::UserAgent;
use URI::Escape;
use HTML::Entities;

#
# SEARCH CITY
#
my $where = uri_escape(uc($ARGV[0]));
my $url = "http://weather.cnn.com/weather/citySearch?search_term=$where&filter=true&csiID=csi2";

# Create a new useragent instance
my $ua = new LWP::UserAgent;

# Set agent name. Don't let the other side know that we are a script
my $agent = 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)';
$ua->agent($agent);

# Fetch the requested page
my $httpresult = $ua->get($url);
if (!$httpresult->is_success) {
	print "Error opening cities search page\n";
	exit 1;
}
my $content = $httpresult->content;

# Pfah, we need no steenking XML parser! Nothing a bit of regexp abracadabra can't do
my @locations;
while ($content =~ m|<LOCATION\s*?code\s*?=\s*?\"(.*?)\"\s*?city\s*?=\s*?\"(.*?)\"\s*?stateorcountry\s*?=\s*?\"(.*?)\"\s*?zip\s*?=\s*?\"(.*?)\"\s*?/>|sg) {
	my $locinfo = {};
	$locinfo->{'code'} = $1;
	$locinfo->{'city'} = decode_entities($2);
	$locinfo->{'soc'} = decode_entities($3);
	$locinfo->{'zip'} = $4;
	push(@locations, $locinfo)
}

if (scalar(@locations) == 0) {
	# Hmm, nothing found
	print "Could not find a city matching $ARGV[0].\n";
	exit 0;
} elsif (scalar(@locations) > 1) {
	# Oh noes! Too many cities found
	print "Multiple possibilities: ";
	for my $i (0 .. $#locations) {
		if ($i) {
			print "; ";
		}
		print $locations[$i]->{'city'}, ",", $locations[$i]->{'soc'};
	}
	print "\n";
	exit 0;
}

# This must be the place
my $code = $locations[0]->{'code'};
my $city = $locations[0]->{'city'};
my $soc = $locations[0]->{'soc'};
my $zip = $locations[0]->{'zip'};

#
# GET WEATHER INFO
#
$url = "http://weather.cnn.com/weather/forecast.jsp?celcius=true&locCode=$code&zipCode=$zip";
$httpresult = $ua->get($url);
if (!$httpresult->is_success) {
	print "Error opening weather information page for $city, $soc\n";
	exit 1;
}
$content = $httpresult->content;

#
# CURRENT
# 
# This is (roughly) the current condition part
$content =~ m|.*cnnWeatherForecastCurrentContent(.*?)cnnWeatherForecastCurrentDetails.*|s;
my $currentpart = $1;
# Extract the temperature
$currentpart =~ m|.*cnnWeatherTempCurrent\">(-*\d+)&deg;.*|s;
my $currenttemp = $1;
# And the condition
$currentpart =~ m|.*cnnWeatherConditionCurrent\">(.*)</span>.*|s;
my $currentcond = decode_entities($1);
$currentcond =~ s/^\s*//;
$currentcond =~ s/\s*$//;

#
# TOMORROW
#
my @forecastlist;
my $fcinfo = {};
# This is (roughly) the tomorrow forecast part
$content =~ m|.*cnnWeatherHeader\">Tomorrow(.*?)cnnWireBoxFooter.*|s;
my $tomorrowpart = $1;
$tomorrowpart =~ m|cnnWeatherTimeStamp\">(.*?)</span>|s;
$fcinfo->{'day'} = substr($1, 0, 3);
$fcinfo->{'temps'} = ();
# Extract the temperatures
while ($tomorrowpart =~ m|cnnWeatherTemp\">(-*\d+)&deg;</span>|gs) {
	push(@{$fcinfo->{'temps'}}, $1);
}
# And the condition
$tomorrowpart =~ m|.*cnnWeatherCondition\">(.*)</span>.*|s;
my $tomorrowcond = decode_entities($1);
$tomorrowcond =~ s/^\s*//;
$tomorrowcond =~ s/\s*$//;
$fcinfo->{'cond'} = $tomorrowcond;
push(@forecastlist, $fcinfo);

#
# EXTENDED
#
# This is (roughly) the extended forecast part
$content =~ m|.*<table class=\"cnnWeatherExtForecast\"(.*?)table.cnnWeatherExtForecast.*|s;
my $extendedpart = $1;
# Loop over the table header to get the days
my @extdayslist;
while ($extendedpart =~ m|<td class=\".*?\">\s*?(\w+?)\s*?<br />|gs) {
	push(@extdayslist, $1);
}
# Next loop over the table cells to get temperature and condition
my @extcondlist;
while ($extendedpart =~ m|cnnWeatherExtForecastDetails\">\s*?(-*\d+)&deg;.*?</span>\s*?(-*\d+)&deg;.*?cnnWeatherExtForecastDayCond\">(.*?)</span>|gs) {
	my $extcond = {};
	$extcond->{'temps'} = ();
	push(@{$extcond->{'temps'}}, $1, $2);
	my $cond = decode_entities($3);
	$cond =~ s/^\s*//;
	$cond =~ s/\s*$//;
	$extcond->{'cond'} = $cond;
	push(@extcondlist, $extcond);
}

# Did we read as many cells as there are days?
if (scalar(@extdayslist) != scalar(@extcondlist)) {
	print "Bleh. Forecast data mismatch\n";
	print "It is $currenttemp C ($currentcond) in $city, $soc\n";
	exit 1;
}

# OK. Join them and put them in the forecastlist
for my $i (0 .. $#extdayslist) {
	$fcinfo = {};
	$fcinfo->{'day'} = $extdayslist[$i];
	$fcinfo->{'temps'} = $extcondlist[$i]->{'temps'};
	$fcinfo->{'cond'} = $extcondlist[$i]->{'cond'};
	push(@forecastlist, $fcinfo);
}

#
# OUTPUT
#
# Finally tell the world
print "It is $currenttemp C ($currentcond) in $city, $soc\n";

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
	print $forecastlist[$i]->{'day'}, " ";
	print $forecastlist[$i]->{'temps'}[0], " | ";
	print $forecastlist[$i]->{'temps'}[1], " C ";
	print $forecastlist[$i]->{'cond'};
}
print "\n";
