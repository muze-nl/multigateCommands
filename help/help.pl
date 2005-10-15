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

my $dirname = "..";
my ( $helpfile, $dummy );

if (@ARGV) {
    ( $helpfile, $dummy ) = split /\s/, shift @ARGV, 2;
}
my @topics = ();
my $file;

my $pwd = cwd();

chdir "../../";
my $level = $ENV{'MULTI_USERLEVEL'};

opendir( DIR, "$pwd/$dirname" ) or die "can't opendir $pwd/$dirname: $!";
while ( defined( $file = readdir(DIR) ) ) {
    if ( ( -T "$pwd/$dirname/$file/help.txt" ) && ( $file !~ /^\.{1,2}$/ ) ) {
        my %config = read_commandconfig($file);
        if ( $level >= $config{level} ) {
            push @topics, $file;
        }
    }
}
closedir(DIR);

if ( ( defined $helpfile ) && ( $helpfile =~ /\w+/ ) ) {
    $helpfile = lc($helpfile);
    if ( -T "$pwd/$dirname/$helpfile/help.txt" ) {
        my %config = read_commandconfig($helpfile);
        if ( $level >= $config{level} ) {
            open( HELP, "<$pwd/$dirname/$helpfile/help.txt" );
            my @help = <HELP>;
            close(HELP);
            my $helptext = join '', @help;
            chomp $helptext;

            # Add command author to end of helptext, if we know it
            if ( defined $config{'author'} ) {
                $helptext .= " (Author: $config{'author'})";
            }

            print $helptext, "\n";
        } else {
            print "Sorry, user level not sufficient\n";
        }
    } else {
        print "Sorry, no help available on $helpfile\n";
    }
} else {
    print "Help available on the following commands, use !help <command> for more info:\n";
    my $topic;
    foreach $topic ( sort @topics ) {
        print $topic. " ";
    }
    print "\n";
}

chdir $pwd;
