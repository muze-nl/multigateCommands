#!/usr/bin/perl -w
#
# 2003-12-20 Robbert Muller & Wieger Opmeer
#

use strict;

use lib '../../lib/';
use Multigate::Config qw( getconf readconfig );
use DBI;


#
# globals
#

readconfig("../../multi.conf");
my $db_passwd = getconf('db_passwd');
my $db_user   = getconf('db_user');
my $db_name   = getconf('db_name');


my $dbh = DBI->connect( "DBI:mysql:$db_name", $db_user, $db_passwd );

die "Cannot access database" unless defined $dbh;

#
# check params
#

my @myargs = split ( ' ', join ( ' ', @ARGV ) );

my $searchuser;

if ( @myargs < 1 ) {
    # HACK! This only works because of level > 0
    unless ( $searchuser = $ENV{'MULTI_REALUSER'} ) {
        print "No username found\n";
        exit 0;
    }
} elsif ( @myargs > 1 ) {
    print "Usage: listprotocols [username]\n";
    exit 0;
} else {
    $searchuser = pop (@myargs);
}

#
# fucntions
#

sub aliastouser {
    my $alias = shift;
    return '' unless $alias;
    my $res = $dbh->selectrow_array( <<'EOT', {}, $alias );
SELECT
	username
FROM
	alias
WHERE
	alias = ?
EOT
    return $alias unless defined $res;
    return $res;
}

sub user_exists {
    my $user = shift;
    return 0 unless $user;
    $user = aliastouser($user);
    my $res = $dbh->selectrow_array( <<'EOT', {}, $user );
SELECT  
  count(*)
FROM
  user
WHERE
  username like ?
EOT
    return $res;
}

sub protocols {
    my $user = shift;
    my $ret  = "";
    my $addr;
    $user = aliastouser($user);

    $addr = $dbh->selectall_arrayref( <<'EOT', {}, $user );
SELECT
  protocol
FROM
  address
WHERE
  username LIKE ? 
  and main_address = 'true'
EOT
    foreach (@$addr) {
        my ($prot) = @$_;
        if ( $ret eq "" ) {
            $ret .= $prot;
        } else {
            $ret .= ", $prot";
        }
    }
    return $ret;


}


#
# Get protocols
#

if ( user_exists($searchuser) ) {
    my $ret;
    $ret = protocols $searchuser;
    if ( $ret eq "" ) {
        print "$searchuser has no protocols\n";
    } else {
        print "$searchuser has protocols $ret\n";
    }
} else {
    print "User $searchuser does not seem to exist\n";
}
