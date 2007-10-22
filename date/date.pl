#!/usr/bin/perl -w

my $tz = @ARGV ? $ARGV[0] : '';

my @tz_groups = qw/
		Africa America Antarctica Arctic
		Asia Atlantic Australia Brazil
		Canada Chile Europe Indian
		Mexico Mideast Pacific Etc
	/;

if ($tz ne '') {
	$tz =~ s/ /_/g;
	if ( $tz !~ /\A(?:\w+\/)*\w+\z/) {
		print "Invalid timezone syntax.\n";
		exit 1;
	} elsif ( -f '/usr/share/zoneinfo/'.$tz ) {
		$ENV{TZ} = $tz;
	} else {
		foreach my $tzg (@tz_groups) {
			if ( -f '/usr/share/zoneinfo/'.$tzg.'/'.$tz ) {
				$ENV{TZ} = $tzg . '/' . $tz;
				print scalar localtime() . "\n";
				exit 0;
			}
		}
		print "Unknown timezone.\n";
		exit 1;
	}
}

print scalar localtime() . "\n";
