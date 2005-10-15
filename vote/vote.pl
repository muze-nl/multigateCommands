#!/usr/bin/perl -w
## Import available environment variables

my $realuser    = $ENV{'MULTI_REALUSER'};             # multigate username of invoking user
my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my %votes = ();    # user -> partij
                   # read votes
open( VOTE, "<vote.dat" );
while (<VOTE>) {
    chomp;
    my ( $user, $party ) = split ':';
    $votes{$user} = $party;
}
close VOTE;

if ( $commandline eq '' ) {

    #results:
    my %partycount = ();
    foreach my $user ( keys %votes ) {
        $partycount{ $votes{$user} }++;
    }
    my $total = keys %votes;
    foreach my $party ( sort { $partycount{$b} <=> $partycount{$a} } keys %partycount ) {
        my $percentage = int( 100 * ( $partycount{$party} / $total ) );
        print "$party: $partycount{$party}($percentage\%); ";
    }

} else {
    $commandline =~ s/\s//g;
    my $party = lc($commandline);
    $votes{$realuser} = $party;

    #write votes
    open( VOTE, ">vote.dat" );
    foreach my $user ( keys %votes ) {
        print VOTE "$user:$votes{$user}\n";
    }
    close VOTE;
    print "Voted\n";
}
