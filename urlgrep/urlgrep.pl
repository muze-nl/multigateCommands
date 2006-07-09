#!/usr/bin/perl -w
#
# Searches url catcher
#

BEGIN { $multiroot = $ENV{MULTI_ROOT}; }

use lib "$multiroot/lib";
use Multigate::Config qw( getconf readconfig );

readconfig("../../multi.conf");

my $maxresults = 3;

my $urlfile = "$multiroot/web/allautolink.shtml";

unless (-e $urlfile) {
  print "url log not found\n";
  exit 1;
}

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

if ($commandline eq '') {
  print "grep for what?\n";
  exit 1;
}

my @results;

open(LOG, "<$urlfile");
while (my $line = <LOG> ) {
   $line =~ s/&lt;/</g;
   $line =~ s/&gt;/>/g;

   if ($line =~ m|^(\[.*?\]) (<.*?>.*?) (<a href=".*?">)(.*?)</a>(.*?)<br>$| ){
      #wellformed :)
      my $time = $1;
      my $nick = $2;
      my $content = $4.$5;
      if ( $nick =~ /\Q$commandline\E/oi  or $content =~ /\Q$commandline\E/oi ) {
        #hit :)
        push @results, "$time $nick $content\n";   
      }  
   }  
}
close LOG;

if (@results) {
  my $i = 0;
  if ($maxresults > scalar(@results)) {
     $maxresults = scalar(@results);
  }
  while ($i < $maxresults) {
     print pop(@results);
     $i++;  
  }
} else {
  print "Sorry, no urls found containing \"$commandline\"\n";
}
