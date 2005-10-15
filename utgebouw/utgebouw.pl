#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;

my $is_multicast        = $ENV{'MULTI_IS_MULTICAST'};
my $multicast_max_lines = 3;

my @output = ();

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';
my ( $cmd, $arg ) = split /\s+/, $commandline, 2;

unless ( $cmd =~ m/nr|naam|afko/ and defined $arg and $arg =~ m/\w/ ) {
    print "syntax error, please read the help\n";
    exit(1);
}

open( FILE, "<utgebouw.txt" ) or die "$! does not exist!";
my @lines = <FILE>;

my $line;
foreach $line (@lines) {
    chomp($line);
    my ( $nr, $naam, $afko, $tel, $oud, $nroud ) = split /,/, $line;

    if ( ( $cmd eq "nr" and ( $nr eq $arg || lc($nroud) eq lc($arg) ) )
        || ( $cmd eq "naam" and ( $naam =~ m/\Q$arg\E/i || $oud =~ m/\Q$arg\E/i ) )
        || ( $cmd eq "afko" and lc($afko) eq lc($arg) ) )
    {
        push ( @output, "$oud($nroud) -> $naam($nr) [$afko]" );
    }
}

if ( @output <= 0 ) {
    print "No results\n";
} elsif ( @output > $multicast_max_lines and $is_multicast ) {
    print "Too much output, please try again on non-multicast protocol";
} else {
    my $outline = join ( "\n", @output );
    print "$outline\n";
}
