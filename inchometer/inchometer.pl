#!/usr/bin/perl -w
#
# Jorik wil dit.... InchHunterPro
#

use strict;

## Import available environment variables

my $address       = $ENV{'MULTI_USER'};            # address of invoking user
my $user          = $ENV{'MULTI_REALUSER'};        # multigate username of invoking user
my $userlevel     = $ENV{'MULTI_USERLEVEL'};       # userlevel of invoking user
my $from_protocol = $ENV{'MULTI_FROM'};            # protocol this command was invoked from
my $to_protocol   = $ENV{'MULTI_TO'};              # protocol where output will be sent
my $command_level = $ENV{'MULTI_COMMANDLEVEL'};    # level needed for this command
my $is_multicast  = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my $inches = 0;

my %users = (
   'oxo' => -3,
   'wiggy' => 8, 
);


my %words = (
    'bsd' => 5,
    'netbsd' => -10,
    'wireless' => 4,
    'mac' => 4,
    'full\s*screen' => 4,
    'g(?:iga)?bit' => 6,
    'ipv6' => 6,
    'hex' => 3,
    'colo' => 2,
    'framerate' => 7,
    'fps' => 3,
    'athlon64' => 4,
    'dual' => 3,
    'quad' => 5,         
    'civ'  => -10,
    'itbe' => -12,
    'icts' => -8,
    'herfst' => -1,
    'mod' => 3,
    'osx' => -5,
    'XP' => 2,
    'pro' => 2,
    'z\b' => 1, #woord eindigend op z ;)
    'dvd' => 2,
    'kiddie' => 3,
    'shf' => 2,
    'k(?:-)?line' => 2,
    'uptime' => 4,
    'script' => 2,
    'irc' => 2,
    '\d+\+' => 3,
    'pdp11' => -4,
    'quantum' => 1,
    'asus' => 2,
    'power' => 2,
    '!!!' => 1,
    'msn' => -10,
    'water' => 3,
    'database' => 1,
    'impact' => 1,
    'scsi' => -6,
    'sata' => 3,
    'raptor' => 1,
    'level' => 3,     
    'raid' => 2,
    'bitlbee' => -3,
    'TB' => 4,
    'GB' => 2,
    'MB' => 1,
    'oper' => 2,
    'lumen' => 3,
    'ansi' => -1,
    'beamer' => 3,
    'vinyl' => 12,
    '3ware' => 3,
    '3com' => -8,
    'hp' => 5,
#En een paar voor de VB tussendoor    
    'sex' => 2,
    'nijlpaard' => 2,
    'tiet' => 2,
    'bier' => 3,
    'porno' => -3,
    'viagra' => -2,
#update 2007
    'buma' => -2,
    'vista' => 3,
    'duo' => 2,
    'core' => 2,
#update voor wat camera-dingen enzo
    'colourspace' => -3,
    'slr' => 1,
    'fisheye' => -2,
    'camera' => 3,
    'analoog' => 4,
    'digita' => 2,
    'opel' => -3,
    'ccd' => 2,
    'cmos' => -2,
    'canon' => 2,
#Het is 2018
    'blockchain' => 4,
);

$inches += $users{$user} if (exists $users{$user} );

foreach my $word (keys %words) {
    $inches += $words{$word} if ($commandline =~ /$word/i );
}

my @hoofdletters = ($commandline =~ /[A-Z]/g);
my $letters = length($commandline);

my $factor = ($letters > 0) ? scalar(@hoofdletters) / $letters : 1;
$factor = 1.5 * ( 1 - abs($factor - 0.5 )); 

$inches *= $factor;
 
printf "Dit scoort %.2f inches" , $inches;
