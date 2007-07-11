package QuoteDB;

use strict;
use DBI;

require Exporter;
our @ISA = qw/ Exporter /;
our @EXPORT = qw/
		quote_add
		quote_del
		quote_get
		quote_find
		quote_search
		quote_count
		quote_vote
		quote_top
		quote_random
	/;
our @EXPORT_OK = qw/
		quote_set_next_id
	/;

my $db_name = 'quotes_dnd';
my $db_user = $ENV{USER};
my $db_pass = '';

my $dbh = undef;

our $Debug = 0; # ( -t STDIN ) ? 1 : 0;

sub connect {
	return if defined $dbh;
	warn "[connect]\n" if $Debug;
	$dbh = DBI->connect('dbi:Pg:dbname='.$db_name, $db_user, $db_pass, {
			AutoCommit	=> 1,
			PrintError	=> 1,
			RaiseError	=> 1,
		});
	die "Failed to connect to database: ".$DBI::errstr."\n"
		unless defined $dbh;
}

sub quote_add { &connect;
	warn "[quote add]\n" if $Debug;
	my $quote    = shift;
	my $realuser = shift;

	if (@_ == 0) {
		my $sth = $dbh->prepare(
			'INSERT INTO quotes (quote, realuser) VALUES (?, ?)');
		$sth->execute($quote, $realuser);
	} else {
		my $date = shift; # used for importing
		if (@_ == 0) {
			my $sth = $dbh->prepare(
				'INSERT INTO quotes (quote, realuser, time_added) '.
				'VALUES (?, ?, ?)');
			$sth->execute($quote, $realuser, $date);
		} else {
			my $quote_id = shift; # used for importing
			my $sth = $dbh->prepare(
				'INSERT INTO quotes (id, quote, realuser, time_added) '.
				'VALUES (?, ?, ?, ?)');
			if ($sth->execute($quote_id, $quote, $realuser, $date)) {
				return $quote_id;
			}
			return;
		}
	}

	my $quote_id = $dbh->last_insert_id(undef, undef, undef, undef, {
			sequence => 'quotes_id_seq'
		});

	return $quote_id;
}

sub quote_del { &connect;
	warn "[quote del]\n" if $Debug;
	my $quote_id = shift;

	my $sth  = $dbh->prepare('DELETE FROM quotes WHERE id = ?');
	my $rows = $sth->execute($quote_id);

	return $rows;
}

sub quote_get { &connect;
	warn "[quote get]\n" if $Debug;
	my $quote_id = shift;

	my $sth  = $dbh->prepare('SELECT * FROM quotes WHERE id = ?');
	my $rows = $sth->execute($quote_id);

	return ($rows == 0) ? undef : $sth->fetchrow_hashref;
}

sub quote_find { &connect;
	warn "[quote find]\n" if $Debug;
	my $quote = shift;

	my $sth  = $dbh->prepare('SELECT id FROM quotes WHERE quote = ?');
	my $rows = $sth->execute($quote);

	return if $rows == 0;

	my ($quote_id) = $sth->fetchrow_array;

	return $quote_id;
}

sub quote_search { &connect;
	warn "[quote search]\n" if $Debug;
	my $quote = shift;
	warn "search_pre = '$quote'\n" if $Debug;
	$quote =~ s/\\/\\\\/g;
	$quote =~ s/\%/\\\%/g;
	$quote =~ s/\_/\\\_/g;
	$quote =~ s/\*/\%/g;
	$quote =~ s/\?/\_/g;
	$quote = ($quote eq '') ? '%' : '%'.$quote.'%';
	warn "search_post = '$quote'\n" if $Debug;

	my $sth  = $dbh->prepare('SELECT id FROM quotes WHERE quote LIKE ?');
	my $rows = $sth->execute($quote);

	my @quote_ids = ();
	while (my ($quote_id) = $sth->fetchrow_array) {
		push @quote_ids, $quote_id;
	}

	return @quote_ids;
}

sub quote_count { &connect;
	warn "[quote count]\n" if $Debug;

	my $sth  = $dbh->prepare('SELECT COUNT(*) FROM quotes');
	$sth->execute();

	my ($rows) = $sth->fetchrow_array;

	return $rows;
}

sub quote_vote { &connect;
	warn "[quote vote]\n" if $Debug;

	my $quote_id = shift;
	my $realuser = shift;
	my $vote     = shift;

	my $qq = quote_get($quote_id);
	return -1 unless defined $qq;

	return -2 if defined $qq->{realuser} && $qq->{realuser} eq $realuser;

	my $sth  = $dbh->prepare('UPDATE quote_votes SET vote = ? '
		.'WHERE quote_id = ? AND realuser = ?');
	my $rows = $sth->execute($vote, $quote_id, $realuser);
	return 2 if $rows > 0;

	$sth = $dbh->prepare('INSERT INTO quote_votes '.
		'(quote_id, realuser, vote) VALUES (?, ?, ?)');
	$sth->execute($quote_id, $realuser, $vote);
	return 1;
}

sub quote_top { &connect;
	warn "[quote top]\n" if $Debug;

	my $count     = shift || 3;
	my $min_votes = shift || 2;

	my $sql = 'SELECT '.
			'quotes.id, '.
			'1.0 * SUM(quote_votes.vote) / COUNT(quote_votes.vote) AS vote, '.
			'SUM(quote_votes.vote) AS sum, '.
			'COUNT(quote_votes.vote) AS count '.
		'FROM quotes '.
		'INNER JOIN quote_votes '.
			'ON quotes.id = quote_votes.quote_id '.
		'GROUP BY quotes.id '.
		'HAVING COUNT(quote_votes.vote) >= ? '.
		'ORDER BY vote DESC, count DESC, id DESC '.
		'LIMIT ?';

	my $sth = $dbh->prepare($sql);
	$sth->execute($min_votes, $count);

	my @quote_ids = ();
	while (my ($quote_id, $vote) = $sth->fetchrow_array) {
		push @quote_ids, [ $quote_id, $vote ];
	}

	return @quote_ids;
}

sub quote_random { &connect;
	warn "[quote random]\n" if $Debug;

	my $realuser = shift || '';

	my $sql =
		'SELECT '.
			'quotes.id, '.
			'(quotes.realuser IS NOT NULL AND quotes.realuser = ?) AS is_own, '.
			'(SUM(quote_votes_own.id) IS NOT NULL) AS has_voted, '.
			'COUNT(quote_votes.vote) AS count, '.
			'RANDOM() AS rnd '.
		'FROM '.
			'quotes '.
		'LEFT JOIN '.
			'quote_votes AS quote_votes_own '.
		  'ON quotes.id = quote_votes_own.quote_id '.
			'AND quote_votes_own.realuser = ? '.
		'LEFT JOIN '.
			'quote_votes '.
		  'ON quotes.id = quote_votes.quote_id '.
		'GROUP BY quotes.id, quotes.realuser '.
		'ORDER BY is_own, has_voted, count, rnd '.
		'LIMIT 1';

	my $sth  = $dbh->prepare($sql);
	my $rows = $sth->execute($realuser, $realuser);
	return unless $rows > 0;

	my ($quote_id) = $sth->fetchrow_array;
	return $quote_id;
}

sub quote_set_next_id { &connect;
	warn "[quote set next id]\n" if $Debug;
	my $quote_id = shift;

	my $sth = $dbh->prepare(
		'ALTER SEQUENCE quotes_id_seq RESTART WITH '.$quote_id);
	$sth->execute();
}

sub disconnect {
	return unless defined $dbh;
	warn "[disconnect]\n" if $Debug;
	$dbh->disconnect();
	$dbh = undef;
}

END{ disconnect() }

1;
