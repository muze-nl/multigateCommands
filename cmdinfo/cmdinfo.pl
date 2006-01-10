#!/usr/bin/perl -w

use strict;
my $multiroot;
BEGIN { $multiroot = $ENV{MULTI_ROOT}; }

use lib "$multiroot/lib";
use Multigate::Config qw (read_commandconfig);

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';
my ( $commandname,  $flag) = split " ", $commandline, 2;
$commandname = defined $commandname  ?  $commandname : '';
$flag = defined $flag  ?  $flag : '';
$commandname = lc($commandname);


unless ( -d "$multiroot/commands/$commandname" and ( $commandname =~ /^\w+$/ ) ) {
    print "Sorry, \"$commandname\" is not a valid command name\n";
}
else {

    chdir $multiroot;    #read_commandconfig expects this...

    my %config = read_commandconfig($commandname);
    my $level  = $config{level};
    print "Info on command \"$commandname\":\n";
    print "level needed: $level\n";
    if ( defined $config{author} ) {
        print "author: $config{author}\n";
    }
    # Add more here
	 if( $flag eq 'svn') {
		 if( -e "$multiroot/commands/$commandname/.svn" ) {
			 my $svninfo = `svn info $multiroot/commands/$commandname`; 
			 print "SVN info:\n";
			 print $svninfo;
		 } else {
			 print "SVN info: not a svn mannaged command\n";
		 }
	}
}
