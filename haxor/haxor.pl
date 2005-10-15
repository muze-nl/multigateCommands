#!/usr/bin/perl -w

$commandline = join " ", @ARGV;
$commandline =~ tr/abceiklstABCEIKLST/48\(3\!x15748\(3\!X157/;
print "$commandline\n";

# For historical reasons:
#%map = (
#  'a' => '4',
#  'b' => '8',
#  'c' => '(',
#  'e' => '3',
#  'i' => '!',
#  'k' => 'x',
#  'l' => '1',
#  's' => '5',
#  't' => '7',
#);
