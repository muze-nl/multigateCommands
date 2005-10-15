#!/usr/bin/perl -w

use lib '../../lib/';

#User management from multigate
use Multigate::Users;

my $realuser    = $ENV{'MULTI_REALUSER'};
my $userlevel   = $ENV{'MULTI_USERLEVEL'};            # userlevel of invoking user
my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my $adminlevel = 600;                                 #from this level up, no admin rights needed

#make a connection to the user-database
Multigate::Users::init_users_module();

my ( $command, $box, $user, $amount ) = split ' ', $commandline, 4;

$user = Multigate::Users::aliastouser($user);

# Options for command: add,delete,inc,dec,get,set

unless ( ( defined $command ) and ( defined $box ) and ( defined $user ) ) {
    print "Usage: box <command> <boxname> <username> [amount]\n";
    exit 1;
}

if ( ( $userlevel < $adminlevel ) and ( ( lc($command) ne 'get' ) or ( $user ne $realuser ) ) ) {
    print "Not allowed\n";
    exit 0;
}

if ( defined $amount ) {
    unless ( $amount =~ /^\d+$/ ) {
        print "Amount should be given in whole numbers\n";
        exit 1;
    }
}

if ( lc($command) eq "add" ) {
    my $res = add_box( $box, $user );
    if ($res) {
        print "Adding box '$box' for user '$user'.\n";
    } else {
        print "A problem occured when adding box '$box' for user '$user'.\n";
    }
} elsif ( ( lc($command) eq "delete" ) or ( lc($command) eq "del" ) ) {
    unless ( defined get_box( $box, $user ) ) {
        print "No such box '$box' for '$user'\n";
        exit 1;
    }
    my $amount = get_box( $box,    $user );
    my $res    = remove_box( $box, $user );
    if ($res) {
        print "Deleted box '$box' for user '$user'. (Units lost: $amount)\n";
    } else {
        print "A problem occured when deleting box '$box' for user '$user'.\n";
    }
} elsif ( ( lc($command) eq "inc" ) ) {
    unless ( defined get_box( $box, $user ) ) {
        print "No such box '$box' for '$user'\n";
        exit 1;
    }
    if ( defined $amount ) {
        my $old_amount = get_box( $box, $user );
        my $res = inc_box( $box, $user, $amount );
        if ($res) {
            my $new_amount = get_box( $box, $user );
            print "Added $amount to '$box' for '$user'. (New balance: $new_amount)\n";
        } else {
            print "A problem occured when adding $amount to '$box' for user '$user'.\n";
        }
    } else {
        print "Usage: box inc $box $user <amount>\n";
    }
} elsif ( lc($command) eq "dec" ) {
    unless ( defined get_box( $box, $user ) ) {
        print "No such box '$box' for '$user'\n";
        exit 1;
    }
    if ( defined $amount ) {
        my $old_amount = get_box( $box, $user );
        my $res = dec_box( $box, $user, $amount );
        if ($res) {
            my $new_amount = get_box( $box, $user );
            print "Deleted $amount from '$box' for '$user'. (New balance: $new_amount)\n";
        } else {
            print "A problem occured when deleting $amount from '$box' for user '$user'.\n";
        }
    } else {
        print "Usage: box inc $box $user <amount>\n";
    }
} elsif ( lc($command) eq "set" ) {
    if ( defined $amount ) {

        #my $old_amount = get_box($box, $user);
        my $res = set_box( $box, $user, $amount );
        if ($res) {
            my $new_amount = get_box( $box, $user );
            print "Set '$box' for '$user' to $new_amount\n";
        } else {
            print "A problem occured when setting '$box' for user '$user' to $amount.\n";
        }
    } else {
        print "Usage: box set $box $user <amount>\n";
    }

} elsif ( lc($command) eq "get" ) {
    my $cur_amount = get_box( $box, $user );
    if ( defined $cur_amount ) {
        print "Current balance of '$box' for '$user': $cur_amount\n";
    } else {
        print "Problem getting balance of box '$box' for '$user'. Does it exist?\n";
    }
} else {
    print "unknown option: $command\n";
}

Multigate::Users::cleanup_users_module();
