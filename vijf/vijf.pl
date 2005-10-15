#!/usr/bin/perl -w

my $tijd = scalar localtime;
my $realuser = $ENV{'MULTI_REALUSER'};

$tijd =~ s/\ 17:/05/g;

$tijd =~ s/[^5]//g;

if ( length($tijd) == 0 ) {
    if( $realuser eq "ctlaltdel" ) {
        print "Voor jou altijd!\n";
    } else {   
        print "Jammer joh, geen vijf in de klok.\n";
    }
} else {
    if ( length($tijd) > 1 ) {
        print "Er zitten " . length($tijd) . " vijven in de klok!\n";
    } else {
        print "Er zit een vijf in de klok!\n";
    }
}

