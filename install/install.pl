#!/usr/bin/perl -w
# Tries to install a command

use strict;

my $multidir = $ENV{MULTI_ROOT};
my $dstdir = "${multidir}/commands";
#Fixme, get from configfile
my $repos = 'https://svn.muze.nl/svn/multigate_commands/';
my $svn_user = '';
my $svn = '/usr/bin/svn';
my $branch;

unless (defined $multidir and -d $dstdir) {
  print "Installation directory \"$dstdir\" undefined or invalid\n";
  exit 0;
}

unless (-x $svn) {
  print "svn not available on path \"$svn\"";
  exit 0;
}

my $command = defined $ARGV[0] ? $ARGV[0] : '';

if( $command =~ /(.+?)\/(.+)/ ) {
	$command = $1;
	$branch = 'branches/'.$2."/";
} else {
	$branch = 'trunk/';
}

unless ($command =~ /^\w+$/) {
   print "Invalid characters in command: \"$command\"\n";
   exit 0;
}

if (-d "$dstdir/$command") {
	my $commandline = "$svn info $dstdir/$command | grep ^URL";
	my $pid = open( README, "$commandline |") or die "Couldn't fork svn: $!\n";
	my $line = <README>;
	my $svn_url = $repos . $branch .$command;
	close(README);
	if($line =~ /$repos/ ){
		if($line !~ /$svn_url/){
			switch();
		} else {
			print "Command already installed try update\n";
		}
	} else {
		print "Directory already exists\n";
	}
} else {
	install();
}

sub run{
	my ($commandline) = @_;

	print STDERR "commandline = $commandline\n";
	my $pid = open( README, "$commandline |") or die "Couldn't fork svn: $!\n";
	my $files = 0 ;
	my $lines = 0;
	while (my $line = <README>) {
		#we expect a few "A filename", followed by "Checked out revision n."
		chomp $line;
		$lines++;
		if ($line =~ /^[UDA]\s+.*?$/) {
			#looks OK...
			$files++;
		} elsif ($line =~ /^Checked out revision (\d+)\.$/) {
			#Tada!
			print "Done ($files files, rev $1)\n";
		} elsif ( ($line =~ /^At revision (\d+)\.$/) or ($line =~ /^Updated to revision (\d+)\.$/) ) {
			#Tada!
			print "Done ($files files updated, rev $1)\n";
		} else {
			#problem?
			print STDERR "svn output: $line\n";
			print "Problem with checkout, see console for more info\n";
		}
	}
	close README;

	if ($lines == 0 ) {
		print "Nothing done. See console for possible errors\n";
	}
}

sub switch {
	my $credentials = ( (defined $svn_user and $svn_user =~ /^\w+$/ ) ? "--username $svn_user" : "");
	my $svn_url = $repos . $branch .$command;
	my $commandline = "$svn switch $credentials $svn_url $dstdir/$command";
	run($commandline);
}

sub install {
	my $svn_url = $repos . $branch .$command;
	#my @cmd = ('svn', 'co' , '--username', $svn_user , $svn_url, "$dstdir/$command");
	#my $result = (system(@cmd) == 0);

	#Do the svn stuff!
	my $credentials = ( (defined $svn_user and $svn_user =~ /^\w+$/ ) ? "--username $svn_user" : "");
	my $commandline = "$svn checkout $credentials $svn_url $dstdir/$command";
	run($commandline);
}
