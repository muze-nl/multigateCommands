#!/usr/bin/perl -w

use strict;

if ( int( rand(100) ) == 42 ) {    #in 1% van de gevallen
    print "nee\n";
} else {
    print "ja\n";
}
