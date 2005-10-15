#!/usr/bin/perl -w
use strict;

## Import available environment variables

my $address       = $ENV{'MULTI_USER'};            # address of invoking user
my $user          = $ENV{'MULTI_REALUSER'};        # multigate username of invoking user
my $userlevel     = $ENV{'MULTI_USERLEVEL'};       # userlevel of invoking user
my $from_protocol = $ENV{'MULTI_FROM'};            # protocol this command was invoked from
my $to_protocol   = $ENV{'MULTI_TO'};              # protocol where output will be sent
my $command_level = $ENV{'MULTI_COMMANDLEVEL'};    # level needed for this command
my $is_multicast  = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

# Do something interesting here

my $strootjestatefile = "strootjestate";
my $rv;
my $aantal;
my $maxlengte = 10;

if ( $commandline =~ /^knip/i ) {
    $commandline =~ s/^knip //g;
    if ( !$commandline =~ /^\d/ ) {
        print("Hoeveel strootjes moet ik knippen?");
        exit;
    }
    $rv = open STROOTJES, "> $strootjestatefile";
    unless ( defined $rv ) {
        print("Kan geen strootjes knippen");
        exit("Kan geen nieuw bestand aanmaken");
    }
    print STROOTJES "$user $commandline $commandline pietjepuk $maxlengte\n";
    close STROOTJES;
    print("Er zijn strootjes geknipt");
} else {
    $rv = open STROOTJES, "< $strootjestatefile";
    unless ( defined $rv ) {
        print("Er zijn nog geen strootjes geknipt");
        exit;
    }
    my $line = <STROOTJES>;
    close STROOTJES;
    my @spline = split ( / /, $line );
    my $hand          = $spline[0];
    my $totaal        = $spline[1];
    my $aantal        = $spline[2];
    my $sigaar        = $spline[3];
    my $shorteststraw = $spline[4];
    my $hoeveelste    = $totaal - $aantal + 1;

    if ( $aantal == 0 ) {
        print("De strootjes zijn op, knip eerst nieuwe strootjes met knip <aantal>");
        exit;
    }
    print "$user trekt het ${hoeveelste}e strootje uit $totaal geknipte strootjes uit de hand van $hand en het is ";
    my $lengte = rand($maxlengte);
    $lengte = sprintf( "%.1f", $lengte );
    print "${lengte} cm lang\n";

    if ( $lengte < $shorteststraw ) {
        $shorteststraw = $lengte;
        $sigaar        = $user;
    }

    if ( $aantal == 1 ) {
        print "$sigaar is de sigaar";
    }

    $aantal--;
    $rv = open STROOTJES, "> $strootjestatefile";
    unless ( defined $rv ) {
        print("het stro is op");
        exit;
    }
    print STROOTJES "$hand $totaal $aantal $sigaar $shorteststraw\n";
    close STROOTJES;
}


