#!/usr/bin/perl -w

use lib '../../lib';

#User management from multigate
use Multigate::Users;

my $realuser    = $ENV{MULTI_REALUSER};
my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

Multigate::Users::init_users_module();

my ( $protocol, $rest ) = split ' ', $commandline, 2;

#Even tijdelijk....

if ( $protocol and ( $protocol =~ /sms/i ) ) {
    print "Even geen sms-followme ivm accounting\n";
    exit 0;
}

if ( $protocol && get_userlevel($realuser) ) {

    #special case: unset followme
    if ( lc($protocol) eq "remove" ) {
        my $res = unset_preferred_protocol($realuser);
        print "unset followme-address for $realuser\n";
        exit 0;
    }

    unless ( protocol_exists($protocol) ) {
        print "protocol \"$protocol\" unknown\n";
        exit 0;
    }
    my $result = set_preferred_protocol( $realuser, $protocol );
    print "preferred protocol for $realuser: $protocol\n";

} else {
    my $result = get_preferred_protocol($realuser);
    $result = "none" unless ($result);
    print "Current preferred protocol for $realuser: $result\n";
}

Multigate::Users::cleanup_users_module();
