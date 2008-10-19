#!/usr/bin/perl -w

use strict;
use config qw/ %channels /;
use HTML::Entities;

sub conv_time {
	my ($d,$h,$m) = @_;

	# today
	use Time::Local qw/ timelocal /;
	my @lt = localtime();

	# next day(s)
	while ($d-- > 0) {
		my $t_noon = timelocal(0,0,12, @lt[3..5]);
		@lt = localtime($t_noon + 86400);
	}

	return timelocal(0,$m,$h, @lt[3..5]);
}

foreach my $channel (sort { $a <=> $b } keys %channels) {
	my $channel_name = $channels{$channel};

	open my $f, '<', 'data/'.$channel;
	my $data = do { local $/; <$f> };
	close $f;

	my @programs = ();
	$data =~ s{<div class="program">(.*?)</div>}{push @programs, $1}ges;

	print "[$channel_name]\n";
	use Data::Dumper;
#	print Dumper(@programs);

	my $day_shift = 0;
	my $t_last = conv_time 0, 6, 0;

	foreach my $program (@programs) {
		$program =~ m{<a href="([^"]*?)">\s*?<span class="time">([^<]*?)</span>\s*?<span class="title">([^<]*?)</span>\s*?<span class="channel">([^<]*?)</span>\s*?</a>}
			or die "tvgids.nl format has changed..\n";
		my ($url, $time, $title, $chan) = ($1,$2,$3,$4);

		decode_entities($url);
		decode_entities($time);
		decode_entities($title);
		decode_entities($chan);

#		print Dumper({
#				url => $url,
#				time => $time,
#				title => $title,
#				channel => $chan,
#			});

		warn "Channel mismatch: '$channel_name' <=> '$chan'.\n"
			unless $channel_name eq $chan;

		die "Unknown time format: '$time'\n"
			unless $time =~ /\A(\d\d):(\d\d) - (\d\d):(\d\d)\z/;

		my ($bh,$bm, $eh,$em) = ($1,$2,$3,$4);
		foreach ($bh,$bm, $eh,$em) { s/^0+(\d)/$1/ }

		my $t_begin = 0;
		my $bd = 0;
		while ($t_begin < $t_last) {
			$t_begin = conv_time $bd++, $bh, $bm;
		}

		my $t_end = 0;
		my $ed = 0;
		while ($t_end < $t_begin) {
			$t_end = conv_time $ed++, $eh, $em;
		}

		$t_last = $t_end;

		print "$t_begin-$t_end: $title\n";
#		$time = scalar(localtime $t_begin) . ' - '. scalar(localtime $t_end)

#		print "$time $title\n";
	}
}
