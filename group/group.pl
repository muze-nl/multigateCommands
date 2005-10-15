#!/usr/bin/perl -w

use lib '../../lib/';

#User management from multigate
use Multigate::Users;

my $realuser    = $ENV{'MULTI_REALUSER'};
my $userlevel   = $ENV{'MULTI_USERLEVEL'};            # userlevel of invoking user
my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my $adminlevel = 500;                                 #from this level up, no admin rights needed

#make a connection to the user-database
Multigate::Users::init_users_module();

my ( $command, $rest ) = split ' ', $commandline, 2;

# Options for command: list add remove setadmin unsetadmin

if ( lc($command) eq "list" ) {
    if ($rest) {

        unless ( group_exists($rest) ) {
            print "Group $rest does not exist" if ( $userlevel >= $adminlevel );
            exit 1;
        }
        unless ( ( $userlevel >= $adminlevel ) or ( get_group_admin_flag( $rest, $realuser ) eq "yes" ) ) {
            print "You are not an admin for $rest";
            exit 1;
        }

        my @members = ();
        foreach my $member ( get_group_members($rest) ) {
            if ( get_group_admin_flag( $rest, $member ) eq 'yes' ) {
                push @members, "$member (admin)";
            } else {
                push @members, $member;
            }
        }
        print join ", ", @members;
    } else {
        print "list what?\n";
    }
} elsif ( lc($command) eq "add" ) {
    my ( $group, $user ) = split " ", $rest, 2;
    my $protocol;

    if ( $user =~ /(\w+):(\w+)/ ) {
        $user     = $1;
        $protocol = $2;
    }

    unless ( ( $userlevel >= $adminlevel ) or ( get_group_admin_flag( $group, $realuser ) eq "yes" ) ) {
        print "You are not an admin for $group\n";
        exit 1;
    }
    if ( user_exists($user) ) {
        if ( add_group_member( $group, $user ) ) {
            print "Adding $user to $group\n";
            if ( defined $protocol ) {
                if ( my $bla = set_group_protocol( $group, $user, $protocol ) ) {
                    print "Setting group-protocol for $group,$user to $protocol, \"$bla\"\n";
                } else {
                    print "Failed setting group-protocol for $group,$user to $protocol\n";
                }
            }
        } else {
            print "Failed adding $user to $group\n";
        }
    } else {
        print "usage: group add groupname username\n";
    }

} elsif ( ( lc($command) eq "remove" ) or ( lc($command) eq "del" ) ) {
    my ( $group, $user ) = split " ", $rest, 2;

    unless ( ( $userlevel >= $adminlevel ) or ( get_group_admin_flag( $group, $realuser ) eq "yes" ) ) {
        print "You are not an admin for $group";
        exit 1;
    }

    if ( user_in_group( $group, $user ) ) {
        my $result = remove_group_member( $group, $user );
        print "Removing $user from $group: $result";
    } else {
        print "user \"$user\" not in group \"$group\"\n";
    }

} elsif ( lc($command) eq "setadmin" ) {
    my ( $group, $user ) = split " ", $rest, 2;

    unless ( ( $userlevel >= $adminlevel ) or ( get_group_admin_flag( $group, $realuser ) eq "yes" ) ) {
        print "You are not an admin for $group";
        exit 1;
    }

    if ( user_exists($user) ) {
        my $result = set_group_admin_flag( $group, $user );
        print "Setting adminflag for $user on $group: $result";
    } else {
        print "usage: group setadmin groupname username\n";
    }

} elsif ( lc($command) eq "unsetadmin" ) {
    my ( $group, $user ) = split " ", $rest, 2;

    unless ( ( $userlevel >= $adminlevel ) or ( get_group_admin_flag( $group, $realuser ) eq "yes" ) ) {
        print "You are not an admin for $group";
        exit 1;
    }

    if ( user_exists($user) ) {
        my $result = unset_group_admin_flag( $group, $user );
        print "Removing adminflag for $user on $group: $result";
    } else {
        print "usage: group setadmin groupname username\n";
    }

} elsif ( lc($command) eq "listgroups" ) {
    if ( $userlevel >= $adminlevel ) {
        print join ", ", list_groups();
    }
} else {
    print "unknown option: $command\n";
}

Multigate::Users::cleanup_users_module();
