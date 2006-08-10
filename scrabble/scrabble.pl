#!/usr/bin/perl -w

use strict;

my @field = qw/
	C..b...C...b..C
	.B...c...c...B.
	..B...b.b...B..
	b..B...b...B..b
	....B.....B....
	.c...c...c...c.
	..b...b.b...b..
	C..b...*...b..C
	..b...b.b...b..
	.c...c...c...c.
	....B.....B....
	b..B...b...B..b
	..B...b.b...B..
	.B...c...c...B.
	C..b...C...b..C
/; # b = 2x LS, c = 3x LS, B = 2x WS, C = 3x WS

my %tiles = ( # tile => [ amount , score ]
	_ => [  2,  0 ],

	E => [ 18,  1 ],
	N => [ 10,  1 ],
	A => [  6,  1 ],
	O => [  6,  1 ],
	I => [  4,  1 ],

	D => [  5,  2 ],
	R => [  5,  2 ],
	T => [  5,  2 ],
	S => [  4,  2 ],

	G => [  3,  3 ],
	K => [  3,  3 ],
	L => [  3,  3 ],
	M => [  3,  3 ],
	B => [  2,  3 ],
	P => [  2,  3 ],

	U => [  3,  4 ],
	H => [  2,  4 ],
	J => [  2,  4 ],
	V => [  2,  4 ],
	Z => [  2,  4 ],
	IJ=> [  2,  4 ],
	F => [  1,  4 ],

	C => [  2,  5 ],
	W => [  2,  5 ],

	X => [  1,  8 ],
	Y => [  1,  8 ],

	Q => [  1, 10 ],
);

my $woord = @ARGV ? shift : 'frop';

my $w = lc($woord);

$woord = uc($woord);
$woord =~ s/IJ/y/g;

die "[$w]  Woord te lang.\n"
	if length($woord) > 15;

my $min = undef;
my $max = undef;

foreach my $line (@field) {
	for (my $x = 0; $x < 16-length($woord); $x++) {
		my $score = 0;
		my %used = ();

		my $str = substr($line, $x, length($woord));
		for (my $i = 0; $i < length($woord); $i++) {
			my $l = substr($woord, $i, 1);
			$l = 'IJ' if $l eq 'y';

			my $s = substr($str  , $i, 1);
			die "[$w]  Letter '$l' niet gevonden.\n"
				unless $tiles{$l};
			$used{$l}++;
			die "[$w]  Te weinig letters '$l' in het spel.\n"
				if $used{$l} > $tiles{$l}[0];
			$s = $s eq 'b' ? 2 : $s eq 'c' ? 3 : 1;
			$score += $s * $tiles{$l}[1];
		}
		$score *= 2 ** ($str =~ s/B//g);
		$score *= 3 ** ($str =~ s/C//g);

		$min = $score unless defined $min && $min < $score;
		$max = $score unless defined $max && $max > $score;
	}
}

die "[$w]  Kan woord niet plaatsen op bord.\n"
	unless defined $min && defined $max;

print "[$w]  Minimale score: $min, maximale score: $max.\n";
