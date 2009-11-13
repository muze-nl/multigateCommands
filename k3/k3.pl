#!/usr/bin/env perl

use warnings;
use strict;

my $text = shift;
if (defined $text) {
  $text =~ s/k/k3/g;
   print $text, "\n";
}
    