#!/usr/bin/perl -w
use strict;

open HIST, "<history.txt";
my @history = <HIST>;
close HIST;

my $result;

if ( !$ARGV[0] eq "" ) {
    my @subhistory = grep /\Q$ARGV[0]\E/i, @history;
    my $count = @subhistory;
    if ( $count == 0 ) {
        $result = "Geen gegevens gevonden\n";
    } elsif ( $count == 1 ) {
        $result = $subhistory[0];
    } else {
        print "$count resultaten gevonden. Een ervan is:\n";
        $result = $subhistory[ rand(@subhistory) ];
    }
} else {
    $result = $history[ rand(@history) ];
}

$result =~ s/\s+/ /g;
print $result , "\n";
