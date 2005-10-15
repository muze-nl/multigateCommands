#!/usr/bin/perl -w
use strict;


my $smiley = '';

my @middle = qw ( o O _ - = * W A );
my %bouwstenen = (
   '.' => '.',
   '_' => '_',
   "'" => "'",
   "`" => "'",
   ':' => ':',
   '-' => '-',
   '=' => '=',
   '+' => '+',
   '~' => '~',
   'd' => 'b',
   '<' => '>',
   '(' => ')',
   '[' => ']',
   'T' => 'T',
   '{' => '}',
   '#' => '#',
   '/' => '\\',
   '\\' => '/',
   '*' => '*',
   '8' => '8',
   'o' => 'o',
   '0' => '0',
   'O' => 'O',
   'x' => 'x',
   'X' => 'X',
   '^' => '^',
   'p' => 'q',
   'q' => 'p',
   'b' => 'd',
);



my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my $length = 6;
if ($commandline =~ /^(\d+)$/) {
  $length = $1;
}

unless ($length > 0 and $length < 20) {
  $length = 6;
}

unless (($length % 2) == 0) {
  #odd length
  $smiley = $middle[int rand(@middle)];
}


my $stenencount = scalar keys %bouwstenen;

for my $i (1..$length/2) {
  my $links = ( keys(%bouwstenen)) [int rand($stenencount)];
  $smiley = $links . $smiley . $bouwstenen{$links};
}

print $smiley, "\n";