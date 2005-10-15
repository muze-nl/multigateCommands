#!/usr/bin/perl -w
use strict;

my %table = (
    A => "ANNA",
    B => "BABETTE",
    C => "CARLA",
    D => "DONNA",
    E => "ELISA",
    F => "FROUKJE",
    G => "GERDA",
    H => "HARRIET",
    I => "IRENE",
    J => "JULIETT",
    K => "KARLIJN",
    L => "LEONTIEN",
    M => "MAMA",
    N => "NINA",
    O => "OMA",
    P => "PRINSES",
    Q => "QUANYA",
    R => "RONJA",
    S => "SARAH",
    T => "TINA",
    U => "URSULA",
    V => "VICTORIA",
    W => "WENDY",
    X => "XANDRA",
    Y => "YVONNE",
    Z => "ZELDA",
    0 => "ZERO",
    1 => "ONE",
    2 => "TWO",
    3 => "THREE",
    4 => "FOUR",
    5 => "FIVE",
    6 => "SIX",
    7 => "SEVEN",
    8 => "EIGHT",
    9 => "NINER"
);

my $input = $ARGV[0];

$input =~ s/\W//g;
$input =~ s/([A-Za-z0-9])/$table{uc($1)} /g;

print $input, "\n";

