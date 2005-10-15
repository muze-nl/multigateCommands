#!/usr/bin/perl -w
#
# Gives help on commands that the calling user has rights for
# Some magic with paths to keep things working    *bah*
# Maybe we need some magic in the .pm's instead?
# 
# Casper Joost Eyckelhof , 2002 

use strict;
use Cwd;

use lib '../../lib/';
use Multigate::Config qw (read_commandconfig);
use Multigate::Users;

my $dirname = "..";
my ( $user, $helpfile, $dummy );

if (@ARGV) {
    ( $user, $helpfile, $dummy ) = split /\s/, shift @ARGV, 3;
}
my @topics = ();
my $file;

my $pwd = cwd();

chdir "../../";
Multigate::Users::init_users_module();
my $level = Multigate::Users::get_userlevel($user);
Multigate::Users::cleanup_users_module();

opendir( DIR, "$pwd/$dirname" ) or die "can't opendir $pwd/$dirname: $!";
while ( defined( $file = readdir(DIR) ) ) {
    if ( !( -T "$pwd/$dirname/$file/help.txt" ) ) {
        push @topics, $file;
    }
}
closedir(DIR);

print "Help missing on the following commands:\n";
my $topic;
foreach $topic ( sort @topics ) {
    print $topic. " ";
}
print "\n";
chdir $pwd;
