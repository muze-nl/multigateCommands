#!/usr/bin/perl -w

my $userlevel = $ENV{'MULTI_USERLEVEL'};    # userlevel of invoking user

my $rank = "Ensign";

if ( $userlevel >= 1000 ) {
    $rank = "Admiral";
} elsif ( $userlevel >= 500 ) {
    $rank = "Captain";
} elsif ( $userlevel >= 100 ) {
    $rank = "Commander";
} elsif ( $userlevel >= 50 ) {
    $rank = "Lieutenant";
}

print "$rank, stardate is ";
print `/home/multilink/multigate/commands/stardate/stardate`;
exit 0;
