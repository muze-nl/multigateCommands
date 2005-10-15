#!/usr/bin/perl -w
#
# It is ugly!
# The first person that has time to clean up this mess: please do!
#

use DBI;
use lib '../../lib';
use Multigate::Config qw( getconf readconfig );
use Multigate::Users;

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
my ( $month, $day ) = ( $mon + 1, $mday );

readconfig("../../multi.conf");    #allowed this way?
my $password = getconf('db_passwd');
my $db_user  = getconf('db_user');
my $database = getconf('db_name');
$dbh = DBI->connect( 'DBI:mysql:' . $database, $db_user, $password, { RaiseError => 0, AutoCommit => 1 } );

if ( !defined $dbh ) {
    print STDERR DBI::errstr;
    exit 0;
}

if ( defined $ARGV[0] && ( $ARGV[0] !~ /^\s*$/ ) ) {
    my ( $command, $bagger ) = split ' ', $ARGV[0], 2;
    if ( ( defined $command ) and ( $command !~ /^\s*$/ ) and ( $command =~ /^(\d+)$/ ) and ( $command <= 12 ) ) {

        # Month !
        $month = $1;
        $day   = 1;
    } elsif ( $command =~ /\w/ ) {
        #zouden ze een user bedoelen?
        my $user = "pietjepuk";
        chdir("../..");
        init_users_module();
        if ( user_exists($command) ) {
            $user = Multigate::Users::aliastouser($command);
        } else {
            print "Geef maandnummer, naam of helemaal niks\n";
            exit 0;
        }
        cleanup_users_module();
        my ( $dag, $maand, $jaar ) = $dbh->selectrow_array( <<'EOT', {}, $user );
SELECT DAYOFMONTH(birthday), MONTH(birthday), YEAR(birthday)  
FROM user 
WHERE username = ? 
EOT
        if ( defined $dag ) {
            my @naam =
              qw( index_op_1_zetten januari februari maart april mei juni juli augustus september oktober november december);
            print "Verjaardag van $user: $dag $naam[$maand]\n";
        } else {
            print "Geen verjaardag gevonden van $user\n";
        }
        exit 0;
    }
}


$alljarig = $dbh->selectall_arrayref( <<'EOT', {}, $month, $day, $month, $day );
SELECT username , DAYOFMONTH(user.birthday), MONTH(CURDATE()) , MONTH(user.birthday) , YEAR(CURDATE()) , YEAR(user.birthday)  
FROM user 
WHERE MONTH(user.birthday) = ? and DAYOFMONTH(user.birthday) >= ? OR
      MONTH(user.birthday) = ? +1 and DAYOFMONTH(user.birthday) < ? 
ORDER BY DATE_FORMAT(user.birthday,"%m%d")
EOT

foreach (@$alljarig) {
    ( $un, $dag, $curmaand, $maand, $curjaar, $jaar ) = @$_;
    if ( $curmaand > $maand ) {
        $curjaar += 1;
    }
    my $age = $curjaar - $jaar;
    print "$un: $dag-$maand-$jaar ($age)\n";
}

if ( defined $dbh ) {
    $dbh->disconnect;
}
