#!/usr/bin/perl -w
# Finds a country given an ip-address using country.nerd.dk

use strict;
use Socket;


my $suffix = ".zz.countries.nerd.dk"; 
my $hostcommand = "/usr/bin/host";
my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

($commandline) = split ' ', $commandline, 2; #only first word!

if ($commandline =~ /^([-\w]+\.)+\w+$/) {
   #possible hostname...
   my $ip = inet_aton($commandline);
   $ip = inet_ntoa($ip) if $ip;
   if ($ip) {
     $commandline = $ip;
   } else {
     print "Unable to resolve \"$commandline\"\n";
     exit 1;
   }
} 

my $prefix = '';
if ($commandline =~ /^(\d+)\.(\d+)\.(\d+).(\d+)$/) {
   my ($first, $second, $third, $fourth) = ($1, $2, $3, $4);
   if ($first < 255 and  $second < 255 and $third < 255 and $fourth < 255) {
     #looks like an ip-address
     $prefix = "$fourth.$third.$second.$first";
   } else {
     print "Invalid ip-address, use a.b.c.d ( 0 < a..d < 255)\n";
     exit 1;
   }
} else {
   #can this happen?
   print "Give a valid ip-address\n";
   exit 0;
}



#host -t txt 105.165.89.130.zz.countries.nerd.dk
my $command = "$hostcommand -t txt ${prefix}${suffix}";

my $pid = open( README, "$command |") or die "Couldn't fork $hostcommand: $!\n";
my $lines = 0;
while (my $line = <README>) {
   #we expect 
   chomp $line;
   $lines++;
   if ($line =~ /^[\w\.]+\.countries\.nerd\.dk\s+TXT\s+"(\w+)"\s*$/) {
     #looks OK...
     print "$commandline is located in $1\n";
   } elsif ($line =~ /^.*?\.countries\.nerd\.dk\s+CNAME\s+.*?\.countries\.nerd\.dk\s*$/) {
     #some cname indirection, ignore :)
   } elsif ($line =~ /^.*?does not exist, try again\s*$/) {
     print "Unknown ip-address\n";
   } else {
     #problem?
     print STDERR "host output: $line\n";
   }
}
close README;
