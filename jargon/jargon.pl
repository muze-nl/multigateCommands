#!/usr/bin/perl
#
# Depends on Debian packages dict-jargon, dict and dictd
#

use strict;
use warnings;

my @out = `dict -d jargon -P - -C $ARGV[0]`;

foreach (@out) {
    print if /^\s+\S+/ or /^No definitions found for/;
}
