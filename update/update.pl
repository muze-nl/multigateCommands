#!/usr/bin/perl -w
# Tries to update a command

use strict;

my $multidir = $ENV{MULTI_ROOT};
my $dstdir = "${multidir}/commands";
#Fixme, get from configfile
my $svn_user = '';
my $svn = '/usr/bin/svn';

my $command = defined $ARGV[0] ? $ARGV[0] : '';

unless (-d "$dstdir/$command") {
  print "Command \"$command\" not installed, unable to update\n";
  exit 0;
}

unless (-x $svn) {
  print "svn not available on path \"$svn\"";
  exit 0;
}

unless ($command =~ /^\w+$/) {
   print "Invalid characters in command: \"$command\"\n";
   exit 0;
}


#Do the svn stuff!
my $commandline = "$svn update $dstdir/$command";
print STDERR "commandline = $commandline\n";
my $pid = open( README, "$commandline |") or die "Couldn't fork svn: $!\n";
print STDERR "PID is $pid\n";
my $files = 0 ;
my $lines = 0;
while ( my $line = <README> ) {
   chomp $line;
   $lines++;
   if ($line =~ /^[AUD]\s+.*?$/) {
     #looks OK...
     $files++;
   } elsif ($line =~ /^At revision (\d+)\.$/) {
     #Tada!
     print "Done ($files files updated, rev $1)\n";
   } else {
     #problem?
     print STDERR "svn output: $line\n";
     print "Possible problem with update, see console for more info\n";
   }
}
close README;

if ($lines == 0 ){
  print "Nothing done. See console for possible errors\n";
}
