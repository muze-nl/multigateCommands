#!/usr/bin/perl -w

use lib '../../lib';

#User management from multigate
use Multigate::Users;
use Multigate::Util;

## Import available environment variables

my $address  = $ENV{'MULTI_USER'};        # address of invoking user
my $user     = $ENV{'MULTI_REALUSER'};    # multigate username of invoking user
my $protocol = $ENV{'MULTI_FROM'};        # protocol this command was invoked from

$address = stripnick($address);           #make sure we do not have irc-channels in database

Multigate::Users::init_users_module();

my $result  = set_preferred_protocol( $user, $protocol );
my $result2 = set_main_address( $user,       $protocol, $address );

print "Setting followme to ($protocol, $address) for $user.\n";

Multigate::Users::cleanup_users_module();
