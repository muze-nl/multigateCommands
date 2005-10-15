#!/usr/bin/perl -w
use strict;

use lib '../../lib/';

#User management from multigate
use Multigate::Users;

my $realuser  = $ENV{'MULTI_REALUSER'};
my $userlevel = $ENV{'MULTI_USERLEVEL'};            # userlevel of invoking user
my $box       = defined $ARGV[0] ? $ARGV[0] : '';

unless ( $box ne '' ) {
    print "Saldo van welke box?\n";
    exit 0;
}

#make a connection to the user-database
Multigate::Users::init_users_module();

my $cur_amount = get_box( $box, $realuser );
if ( defined $cur_amount ) {
    print "Current balance of '$box' for '$realuser': $cur_amount\n";
} else {
    print "Problem getting balance of box '$box' for '$realuser'. Does it exist?\n";
}

Multigate::Users::cleanup_users_module();
