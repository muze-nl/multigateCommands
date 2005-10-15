#!/usr/bin/perl
use strict;
use LWP::UserAgent;

use Geo::METAR;
use strict;

## Import available environment variables

my $address       = $ENV{'MULTI_USER'};            # address of invoking user
my $user          = $ENV{'MULTI_REALUSER'};        # multigate username of invoking user
my $userlevel     = $ENV{'MULTI_USERLEVEL'};       # userlevel of invoking user
my $from_protocol = $ENV{'MULTI_FROM'};            # protocol this command was invoked from
my $to_protocol   = $ENV{'MULTI_TO'};              # protocol where output will be sent
my $command_level = $ENV{'MULTI_COMMANDLEVEL'};    # level needed for this command
my $is_multicast  = $ENV{'MULTI_IS_MULTICAST'};

my $commandline = defined $ARGV[0] ? uc( $ARGV[0] ) : '';

my %locations = ();
open CODES, "<icao3.txt";                          #icao3.txt is combined from 2 icao sources
while ( my $line = <CODES> ) {
    chomp $line;
    my ( $code, $location ) = split ' ', $line, 2;
    $locations{$code} = $location;
}
close CODES;

if ( $commandline =~ /^[A-Za-z]{4}$/ ) {

    #Check location code

    unless ( $locations{$commandline} ) {
        print "Unknown location code: $commandline\n";
        exit 0;
    }

    ## Get a certain URL
    my $url = "http://weather.noaa.gov/cgi-bin/mgetmetar.pl?cccc=$commandline";

    my $ua = new LWP::UserAgent;

    #Set agent name, we are not a script! :)
    my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
    $ua->agent($agent);

    my $request = new HTTP::Request( 'GET', $url );
    my $content = $ua->request($request)->content;

    my @lines = split /^/m, $content;

    my $metarcode;
    foreach my $line (@lines) {

        #print "-->$line";
        if ( $line =~ /^($commandline .*)$/ ) {    # if it matches something
            $metarcode = $1;
        }
    }

    my $m = new Geo::METAR;
    $m->metar($metarcode);

    #print $m->dump;

    my $c_temp = $m->C_TEMP;
    my $date   = $m->DATE;
    my $time   = $m->TIME;
    my $wind_r = $m->WIND_DIR_ENG;
    my $wind_s = $m->WIND_KTS;

    #    if ($user eq 'wiggy') {
    #       $time = "No time";
    #    }

    print "Weather at $locations{$commandline} ($time). Temperature: $c_temp (C). Wind: $wind_r $wind_s (knots)\n";
    print "Code: $metarcode \n" unless ($is_multicast);
} else {
    print "Geef METAR ID, zie bijvoorbeeld http://www.gironet.nl/home/aviator1/icao4/icao4.htm\n";
    my @hints = ();

    ## Zoek match
    foreach my $code ( keys %locations ) {
        if ( $locations{$code} =~ /\Q$commandline\E/i ) {
            push @hints, $code;
        }
    }
    if (@hints) {
        print "Misschien bedoel je ", ( join " of ", ( splice @hints, 0, 4 ) ), "?\n";
    }
}
