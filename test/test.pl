#!/usr/bin/perl -w

#if ( $ARGV[0] =~ /(\d+)/ ) {
#    print "a" x $1, "\n";
#}

foreach $key ( sort keys(%ENV) ) {
    print "$key = $ENV{$key}\n" if ( $key =~ /multi/i );
}

# No-public-response hack
#exit 0 if ( $ENV{'MULTI_USER'} =~ /^#\w+/ );

#print "\$ENV{'MULTI_IS_MULTICAST'} = ". $ENV{'MULTI_IS_MULTICAST'};
