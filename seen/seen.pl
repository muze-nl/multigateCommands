#!/usr/bin/perl -w
#
# Zoekt in logfile van vandaag
# Zou eigenlijk ircseen moeten heten
# Past relatief slecht in het concept van multigate!
#

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';
unless ( $commandline =~ /\w+/ ) {
    print "Wie dan?\n";
    exit 0;
}
my ( $nick, undef ) = split " ", $commandline, 2;


my $chan   = "#dnd";
my $logdir = "../../logs/";


$chan = qr/$chan/;

my @logfiles = ();
if (opendir DIR, $logdir) {
	while ( my $file = readdir DIR ) {
		next unless -f $logdir.'/'.$file;
		if ($file =~ /^$chan\.([1-9]\d?)([A-Z][a-z]{2})(\d{4})$/) {
			my ($d,$m,$y) = ($1,$2,$3);
			$m = {
				Jan => 1,	Feb => 2,	Mar => 3,
				Apr => 4,	May => 5,	Jun => 6,
				Jul => 7,	Aug => 8,	Sep => 9,
				Oct => 10,	Nov => 11,	Dec => 12,
				}->{$m};

			push @logfiles, [ sprintf('%04u-%02u-%02u', $y, $m, $d), $file ];
		}
	}
	closedir DIR;
}

@logfiles = sort { $b->[0] cmp $a->[0] } @logfiles;

#print map { $_->[0] . ' ' . $_->[1] . "\n" } @logfiles;
#exit 1;

my $date = undef;

foreach my $lf (@logfiles) {
	$date = $lf->[0];
	if ( open( LOG, "<".$logdir.'/'.$lf->[1] ) ) {
		my $result = undef;

		while ( my $line = <LOG> ) {
			# [01:17] Action: schuhome bows down

			if ( ( $line =~ /^\[\d\d\:\d\d\] <\Q$nick\E>.*$/i ) or
					( $line =~ /^\[\d\d\:\d\d\] Action: \Q$nick\E .*$/i ) ) {
				chomp $line;
				$result = $line;
			}
		}

		close LOG;

		if (defined $result) {
			print "[$date] $result\n";
			exit 0;
		}
	} else {
		#No logfile?
		print "Problem opening logfile '".$lf->[1]."'\n";
	}
}

my $result = "$nick niet gezien\n";

$result = "$nick niet gezien sinds $date\n" if defined $date;
	
print $result;
