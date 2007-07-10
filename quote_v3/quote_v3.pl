#!/usr/bin/perl -w

use strict;
use QuoteDB;

my $args = join(' ', @ARGV);


# Multigate variables
my $realuser     = $ENV{'MULTI_REALUSER'};
	# multi user name
my $userlevel    = $ENV{'MULTI_USERLEVEL'};
	# multi user userlevel
my $is_multicast = $ENV{'MULTI_IS_MULTICAST'};
	# message to multiple recipients (channels)


# Config options
my $max_lines = $is_multicast ? 3 : 25;

my $allow_admin = ( defined $userlevel && $userlevel >= 500) ? 1 : 0;

my $quote_ls_direct = 1;
my $min_votes =  2;


# precompiled regexps
my $RE_id    = qr/[1-9]\d*/;
my $RE_score = qr/[1-9]|10/;
my $RE_num   = $RE_id;


# subs
sub trim { # ALSO changes input!
	foreach (@_) {
		s/^\s+//; s/\s+\z//;
	}
	return @_;
}

sub print_quotes {
	my @quote_ids = @_;
	foreach my $quote_id (@quote_ids) {
		my $score = undef;
		if (ref $quote_id) { # ugly hack
			($quote_id, $score) = @$quote_id;
		}
	
		unless ($max_lines--) {
			print "Max. output reached.\n";
			last;
		}

		my $qq = quote_get($quote_id);
		if (defined $qq) {
			my $quote = $qq->{quote};
			chomp $quote;
			if (defined $score) {
				printf "\cB\%5.2f\cB [#\%u] \%s\n", $score, $quote_id, $quote;
			} else {
				print "[#$quote_id] $quote\n";
			}
		} else {
			print "Unknown quote id $quote_id.\n";
		}
	}
}


if ($args =~ /^\s*(?:$RE_id\s*;\s*)*$RE_id\s*\z/) {
	# search for quote id
	my @quote_ids = trim split /;/, $args;
	print_quotes @quote_ids;


} elsif ($args =~ s/^\s*(\S+)//) {
	my $Cmd = $1;
	my $cmd = lc($Cmd);

	if ($cmd eq 'add') {
		# chomp
		my $quote = $args;
		trim $quote;

		# check duplicate
		my $quote_id = quote_find($quote);

		if (defined $quote_id) {
			print "Quote is duplicate of id $quote_id.\n";

		} else {
			$quote_id = quote_add($quote, $realuser);

			print "Quote saved as id $quote_id.\n";
		}


	} elsif (  $cmd eq 'del'
			|| $cmd eq 'delete'
			|| $cmd eq 'rm'
			|| $cmd eq 'remove') {

		if ($allow_admin) {
			# expect quote id
			if ($args =~ /^\s*($RE_id)\s*\z/) {
				# search for quote id
				my $quote_id = $1;
				if (quote_del($quote_id)) {
					print "Quote id $quote_id removed.\n";

				} else {
					print "Unknown quote id $quote_id.\n";
				}
			} else {
				print "Try !help quote\n";
			}
		} else {
			print "Not enough privileges\n";
		}


	} elsif ($cmd eq 'count') {

		# extra parameters? search string.
		trim $args;
		if ($args eq '') {
			my $count = quote_count;
			print "Total number of quotes: $count\n";

		} else {
			my @quote_ids = quote_search($args);
			print "Number of matching quotes: ".scalar(@quote_ids)."\n";
		}


	} elsif ($cmd eq 'ls' || $cmd eq 'list' || $cmd eq 'search') {

		# extra parameters? search string.
		trim $args;
		if ($args eq '') {
			print "No search string given.\n";

		} else {
			my @quote_ids = quote_search($args);

			@quote_ids = sort { $a <=> $b } @quote_ids;
			if (@quote_ids) {
				if ($quote_ls_direct) {
					print_quotes @quote_ids;
				} else {
					print join('; ', @quote_ids)."\n";
				}
			} else {
				print "No matching quotes.\n";
			}
		}


	} elsif ($cmd eq 'vote') {
		# expect quote id and score
		if ($args =~ /^\s*($RE_id)\s+($RE_score)\s*\z/) {
			# search for quote id
			my ($quote_id, $score) = ($1, $2);
			if (!defined $realuser || $realuser eq '') {
				print "Login first.\n";

			} else {
				my $res = quote_vote($quote_id, $realuser, $score);

				if ($res == -1) {
					print "Unknown quote id $quote_id.\n";
				} elsif ($res == -2) {
					print "Can't vote on own quotes.\n";
				} elsif ($res == 1) {
					print "Voted.\n";
				} else {
					print "Vote updated.\n";
				}
			}
		} else {
			print "Try !help quote\n";
		}


	} elsif ($cmd eq 'top') {

		my $top = undef;
		# expect quote id and score
		trim $args;
		if ($args =~ /^\s*($RE_num)\s*\z/) {
			$top = $1;
		} elsif ($args eq '') {
			$top = 3;
		}
			
		if (defined $top) {
			my @quote_ids = quote_top $top, $min_votes;

			if ($quote_ls_direct) {
				print_quotes @quote_ids;
			} else {
				if (@quote_ids) {
					print join('; ', map { $_->[0] } @quote_ids)."\n";
				} else {
					print "No matching quotes.\n";
				}
			}
			if (@quote_ids < $top) {
				print "Not enough votes.\n";
			}
		} else {
			print "Try !help quote\n";
		}

	} else {
		# do some magic matching..
		$args = $Cmd.$args;
		trim $args;

		my @quote_ids = quote_search($args);

		if (@quote_ids) {
			print_quotes $quote_ids[rand(@quote_ids)];
		} else {
			print "No matching quotes.\n";
		}
	}

} else {
	my @quote_ids = quote_random($realuser);

	# show result
	if (@quote_ids) {
		print_quotes $quote_ids[rand(@quote_ids)];
	} else {
		print "No quotes in database.\n";
	}
}
