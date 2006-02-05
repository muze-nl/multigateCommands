#!/usr/bin/perl -w
#
# Ugly hack to get all (most?) text from despair posters from website
# Check the link-numbers and the results manually after running this "tool"
#

use warnings;
use strict;

my $data = `lynx -dump http://www.despair.com/viewall.html`;

my @lines = split "\n" , $data;

my %results;
my $state = "findheader";  #findheader, findcontent
my ($currentheader, $currentcontent);

foreach my $line (@lines) {
    next if ($line =~ /pad/);
    next if ($line =~ /\.gif/);
    next if ($line =~ /^\s*$/);
    
    if ($line =~ /^\s*\[(\d+)\](.*?)\s*$/) { #new header
       next if ($1 <= 146);
       if ($state eq "findcontent" and defined $currentcontent and $currentcontent ne '' ) {
           $results{$currentheader} = $currentcontent;
           $currentcontent = '';
       }
       $currentheader = $2;
       $state = "findcontent";
       next;
    }
    
    if ($state eq "findcontent" and $line =~ /^\s*(.*?)\s*$/ ) {
       $currentcontent .= " " . $1;
    } 

}

foreach my $header (keys %results) {
    print "$header: $results{$header}\n"; 

}
