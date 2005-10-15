#!/usr/bin/perl -w

my @jim = (
    "It's life, Jim, but not as we know it",        "It's worse than that, he's dead Jim",
    "Analysis Mr. Spock!",                          "You can not change the laws of physics",
    "Only going forward, still can't find reverse", "We come in peace.. shoot to kill!",
    "You can not change the laws of physics",       "There's Klingons on the starboard bow"
);

#
# <oxo> mag ik een !jim die "It's amazing zegt", maar alleen op mijn triggerd?
# <oxo> ter compensatie?
#
if ( $ENV{'MULTI_REALUSER'} eq "oxo" ) {    # oxo is raar
    print "It's amazing!";
} else {
    print $jim[ rand(@jim) ];
}
