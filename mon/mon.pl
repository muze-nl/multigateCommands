#!/usr/bin/perl -w

use strict;
use Mon::Client;

# vars
my $mon = new Mon::Client (
		host => "localhost",
		port => 2583,
		username => "monuser",
		password => "monpass",
		);


print "please configure mon.pl" ; exit 0;

#fuctions forwards
sub status;
sub mon_status;

##
#functions
#
sub mon_admin_endisable{
	my ($mode,@myargs) = @_;
	my $watch = shift(@myargs);
	my $service = shift(@myargs);
	if(defined $watch && $watch ne ""){
		if(defined $service && $service ne ""){
			if($mode eq 'enable'){
				$mon->enable_service($watch,$service);
				print "mon_admin_$mode: OK\n";
			} else {
				$mon->disable_service($watch,$service);
				print "mon_admin_$mode: OK\n";
			}
		} else {
			if($mode eq "enable"){
				$mon->enable_watch($watch);
				print "mon_admin_$mode: OK\n";
			} else {
				$mon->disable_watch($watch);
				print "mon_admin_$mode: OK\n";
			}
		}
	} else {
		print "mon_admin_$mode: What?\n";
	}
}

sub mon_admin_ack{
	my (@myargs) = @_;
	my $watch = shift(@myargs);
	my $service = shift(@myargs);
	my $message = join(' ',@myargs);
	my $ack_user = "unknown";

	my $reenable_time = 3600;

	if(defined $ENV{MULTI_REALUSER}){
		$ack_user = $ENV{MULTI_REALUSER};
	}

	if($message =~ /^([1-9][0-9]*[smhud]?|perm)((\s.*)?)$/s) {
		my $periode = $1;

		$message = "$2";
		$message =~ s/^\s*//;

		if ($periode =~ /^(\d+)s$/) {
			$periode = $1;
		} elsif ($periode =~ /^(\d+)m$/) {
			$periode = 60 * $1;
		} elsif ($periode =~ /^(\d+)[hu]$/) {
			$periode = 3600 * $1;
		} elsif ($periode =~ /^(\d+)d$/) {
			$periode = 86400 * $1;
		} elsif ($periode eq 'perm') {
			$periode = 0;
		}

		$reenable_time = $periode;
	}

	if(defined $watch && defined $service) {
		$mon->ack($watch, $service,
			$message . " (ACKed by ".$ack_user.";" .
					   " Reenabling in $reenable_time seconds)"
		);

		unless ($reenable_time) {
			print "mon_admin_ack: OK\n";
			return;
		}

		my $rtime = time + $reenable_time;
		sleep 5;
		while (($reenable_time = ($rtime - time)) > 0) {
			my $ack = $mon->get($watch,$service,'_ack');
			return unless $ack eq '1';

			$mon->ack($watch, $service,
				$message . " (ACKed by ".$ack_user.";" .
						   " Reenabling in $reenable_time seconds)"
			);
			sleep 5;
		}

		# fijn, die ongedocumenteerde dingen ;-)
		$mon->set($watch,$service,'_ack',0);			# Disable ACK
		$mon->set($watch,$service,'_ack_comment','');	# Disable comment
		print "mon_admin: Watch $watch reenabled.\n";
	} else {
		print "You need help\n";
	}
}

sub mon_admin_nack{
	my (@myargs) = @_;
	my $watch = shift(@myargs);
	my $service = shift(@myargs);

	if(defined $watch && defined $service) {
		# fijn, die ongedocumenteerde dingen ;-)
		$mon->set($watch,$service,'_ack',0);			# Disable ACK
		$mon->set($watch,$service,'_ack_comment','');	# Disable comment
		print "mon_admin_nack: OK\n";
	} else {
		print "You need help\n";
	}
}

sub mon_admin_test{
	my @args = @_;

	if (@args >= 5) {
		my $period = join ' ', @args[4 .. (@args - 1)];
		$args[4] = $period;
	}

	my $result = $mon->test(@args);
	print "Test result: '$result'\n";
}

sub mon_admin_cmd{
	my $cmd = shift;
	my @args = @_;

	my $result = $mon->$cmd(@args);
	print "Cmd result: '$result'\n";
}

sub mon_admin{
	my (@myargs) = @_;
	if($ENV{MULTI_USERLEVEL} >= 100){
		my $cmd = shift @myargs;
		if(not defined $cmd) {
			print "mon_admin: Use commands enable/disable/ack/nack/test/cmd\n";
		} elsif($cmd eq "enable"){
			mon_admin_endisable "enable",@myargs;
		} elsif($cmd eq "disable"){
			mon_admin_endisable "disable",@myargs;
		} elsif($cmd eq "ack"){
			mon_admin_ack @myargs;
		} elsif($cmd eq "nack"){
			mon_admin_nack @myargs;
		} elsif($cmd eq "test"){
			mon_admin_test @myargs;
		} elsif($cmd eq "cmd"){
			mon_admin_cmd @myargs;
		} else {
			print "mon_admin: Use commands enable/disable/ack/nack/test/cmd\n";
		}
		if(defined $mon->error){
			print "Mon[Error]: Admin command $cmd gave ".$mon->error."\n";
		}
	} else {
		print "Sorry admin commands are limited to ppl with a higher level\n";
	}
}

sub mon_status{
	my ($hosts,$host);
	my $filter;
	my (%s,$watch,$service,$var);
	my (%d,$group);
	my $out;

	$out ="";

	$filter = 0;

	if(@_){
		foreach $host (@_){
			$hosts->{$host} = 1;
		}
		$filter = 1;
	}

	##
	## request data
	## when filtering , request all data , otherwise only the failed list
	## always match the data with the disabled list and change data when match
	##
	if($filter == 1){
		%s = $mon->list_opstatus();
	} else {
		%s = $mon->list_failures();
	}
	%d = $mon->list_disabled;
	foreach $watch (keys %s) {
		if(defined $hosts->{$watch} || $filter == 0){
			$out .= "$watch: ";
			if(defined($d{"watches"}{$watch})) {
				$out .= "DISABLED";
			} else {
				foreach $service (keys %{$s{$watch}}) {
					$out .= "$service(";
					if(defined $d{"services"}{$watch}{$service} ){
						$out .= "DISABLED";
					} else {
						my $i = $s{$watch}{$service}{'opstatus'};
						if($i eq '0'){
							$out .= "FAILED";
						} elsif ($i eq '1') {
							$out .= "OK";
						} elsif ($i eq '7') {
							$out .= "?";
						} else {
							$out .= "UNKNOWN ($i)";
						}
						$i = $s{$watch}{$service}{'ack'};
						if($i eq '1'){
									
							$out .= "[". $s{$watch}{$service}{'ackcomment'} ."]";
						}
					}
					$out .= ") ";
				}
			}
			$out .= "\n";
		}
	}
	print $out;
	
}

sub fullstatus{
	my (%s,$watch,$service);
	my (%d);
	my $out;


	$out = "";
	if(defined $ENV{MULTI_IS_MULTICAST} ){
		if($ENV{MULTI_IS_MULTICAST} eq "1"){
			print "Try a non multicast channel\n";
			return;
		}
	}


	%s = $mon->list_opstatus();
	%d = $mon->list_disabled;

	foreach $watch (keys %s) {
		$out .= "$watch: ";
		if(defined($d{"watches"}{$watch})) {
			$out .= "DISABLED";
		} else {
			foreach $service (keys %{$s{$watch}}) {
				$out .= "$service(";
				if(defined $d{"services"}{$watch}{$service} ){
					$out .= "DISABLED";
				} else {
					my $i = $s{$watch}{$service}{'opstatus'};
					if($i eq '0'){
						$out .= "FAILED";
					} elsif ($i eq '1') {
						$out .= "OK";
					} elsif ($i eq '7') {
						$out .= "?";
					} else {
						$out .= "UNKNOWN ($i)";
					}
				}
				$out .= ") ";
			}
		}
		$out .= "\n";
	}
	print $out;
}

sub mon_disabled{
	my (%d);
	my ($service,$watch);
	my ($out);
	my $first = 0;
	my $nothing;
	$nothing = 0;

	%d = $mon->list_disabled;
	if(defined $mon->error){
		print "Mon[Error]: ".$mon->error."\n";
	}
	$out = "";
	$watch = "";
	foreach $watch (keys %{$d{"watches"}}) {
		if ($out ne ""){
				$out .= ", ";
		}
		$out .= $watch;
	}

	if ($out ne ""){
		print "Disabled host: ".$out."\n";
		$nothing++;
	}

	$out = "";
	$watch = "";
	$service = "";
	foreach $watch (keys %{$d{"services"}}){
		$out .= "$watch: ";
		$first = 0;
		foreach $service (keys %{$d{"services"}{$watch}}){
			if($first != 0){
				$out .= ", ";
			}
			$first++;
			$out .= "$service";
		}
		$out .= "; ";
	}
	if ($out ne ""){
		print "Disabled services: ".$out."\n";
		$nothing++;
	}

	if($nothing == 0){
		print "nothing disabled\n";
	}


}

sub mon_list{
	my ($w);
	my %marks;
	my $first = 0;
	foreach $w ($mon->list_watch) {
		if(not defined $marks{$w->[0]}) {
			$marks{$w->[0]} = 1;
			if($first == 0){
				$first = 1;
			} else {
				print " ";
			}
			print $w->[0];
		}
	}
	print "\n";
}



if(not defined($ARGV[0])){
	print "you need help\n";
	exit 0;
}

$mon->connect();
if(defined $mon->error){
	print "Mon[Error]: ".$mon->error."\n";
}
$mon->login();
if(defined $mon->error){
	print "Mon[Error]: ".$mon->error."\n";
}

my @myargs = split(' ',join(' ',@ARGV));
my $cmd = shift @myargs;

if($cmd eq "status"){
	mon_status @myargs;
} elsif($cmd eq "fullstatus"){
	fullstatus;
} elsif($cmd eq "list"){
	mon_list;
} elsif($cmd eq "admin"){
	mon_admin @myargs;
} elsif($cmd eq "disabled"){
	mon_disabled;
} else {
	print "you need help\n";
}
if(defined $mon->error){
	print "Mon[Error]: ".$mon->error."\n";
}

#$mon->quit();
$mon->disconnect();


