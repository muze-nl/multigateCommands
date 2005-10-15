#!/usr/bin/perl -w

foreach $key ( sort keys(%ENV) ) {
    print "$key = $ENV{$key}\n" if ( $key =~ /multi/i );
}
