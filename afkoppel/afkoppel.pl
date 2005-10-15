#!/usr/bin/perl -w
## Import available environment variables

use File::stat;
my $realuser = $ENV{'MULTI_REALUSER'};    # multigate username of invoking user
my $locked   = 0;

# Loek is raar
# Maar Titan kan ook rare regels in een script plakken!
exit 0 if ( lc($realuser) eq "loek" );

my $lockfile = "data/$realuser";

#check time-lock on this user
if ( -e $lockfile ) {
    my $stat = stat $lockfile or die "Error opening lockcheckfile: $!\n";
    $locked = ( $stat->mtime > time() );
}

if ($locked) {

    #do we want to refresh our lock??
    #if so: move this statement after lockfilewriting
    exit 0;
}

#create new lockfile
open CACHE, "> $lockfile" or die "cannot write to file!";
close CACHE;

#modify time on lockfile
my $cachetime = time + 300;    # 5 minutes into the future
utime $cachetime, $cachetime, $lockfile;

#the thing this command is about: 
if ( int( rand(100) ) < 30 ) {
    open( MSG, "< afkoppel.txt" );
    my @opties = <MSG>;
    close MSG;

    my $antwoord = $opties[ int( rand(@opties) ) ];
    $antwoord =~ s/XX/$realuser/;
    print "$antwoord";
} else {
    exit 0;
}
