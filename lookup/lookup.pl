#!/usr/bin/perl -w

use strict;

$| = 1;

if ( !defined $ARGV[0] ) {
    print "Syntax: lookup <ip_nummer | hostname>\n";
    exit(1);
}

my $arg = $ARGV[0];
my $line;
my $hostname;
my $src;
my $type;
my $dst;
my $cname = 0;
my $count = 0;
my $result;

if ( open( INPUT, "-|" ) ) {
    if ( $arg =~ /\d+\.\d+\.\d+\.\d+/ ) {
        $hostname = "onbekend";
        while ( $line = <INPUT> ) {
            chomp $line;

            # This matches the output of the BIND host program
            if ( $line =~ /domain name pointer/ ) {
                ( undef, undef, undef, undef, $hostname ) = split ( ' ', $line );
            } elsif ( $line =~ /Name:/ ) {    # And this matches the NIKHEF version
                ( undef, $hostname ) = split ( ' ', $line );
            }
        }
        print "IP nummer $arg is $hostname\n";
    } else {
        $hostname = $arg;
        while ( $line = <INPUT> ) {
            chomp $line;

            # This matches the output of the BIND version
            if ( $line =~ /has address/ ) {
                ( $src, undef, undef, $dst ) = split ( ' ', $line );
                $type = "A";
            } elsif ( $line =~ /is an alias/ ) {
                ($src) = split ( ' ', $line );
                $type = "CNAME";
            } else {    # And this matches the NIKHEF version
                ( $src, $type, $dst ) = split ( ' ', $line );
            }
            if ( ( $type eq "CNAME" ) && ( !$cname ) ) {
                $hostname = $src;
                $cname    = 1;
            } elsif ( $type eq "A" ) {
                $count++;
                if ( !$cname ) {
                    $hostname = $src;
                }
                if ( $count > 1 ) {
                    $result .= ", " . $dst;
                } else {
                    $result .= $dst;
                }
            }
        }
        print "Host $hostname heeft ";
        if ( $count == 0 ) {
            print "geen IP nummer\n";
        } else {
            printf "IP nummer%s %s\n", ( $count == 1 ) ? "" : "s", $result;
        }
    }
    close(INPUT);
} else {
    exec( 'host', $arg )
      or die "Can't exec host: $!";
}
