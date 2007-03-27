#!/usr/bin/perl -w

use strict;
use warnings;


#evil backticks, but no user-input
my $pass =`./pwgen -c -n 7`;
chomp $pass;

my %table = ( 
    A => ["autobus", "aapje", "AOL", "afgeschreven", "amstel" ], 
    B => ["brandweerauto", "bewoner" ], 
    C => ["chaos", ], 
    D => ["dombo", "debiel"], 
    E => ["eikel", ], 
    F => ["flupke", ], 
    G => ["groentje", ], 
    H => ["halve-zool", "heineken" ], 
    I => ["incompetent", ], 
    J => ["josti", ], 
    K => ["klootviool", "kastanje", "koe"], 
    L => ["looprek", "lagere school"], 
    M => ["muts", "mongool", "mavo"], 
    N => ["nono", ],
    O => ["opa", "oma" ],
    P => ["prutser", "paashaas"],
    Q => ["quasi-onverschillig", ],
    R => ["randdebiel", ],
    S => ["sul", "sulletje", "spruitjes", "sandalen"],
    T => ["traag", ],
    U => ["uberhaupt", ],
    V => ["vrouw", "vmbo"],
    W => ["wanbetaler", ],
    X => ["xantippevogel", ],
    Y => ["yahoo", ],
    Z => ["zeikerd", ],
    
);                                                                                                                                                

$pass =~ s/[1-9]/0/g; #just zeros as numbers...

my @chars = split // , $pass;

my %seen;
my $result;
foreach my $char (@chars) {
   next unless (defined $char);
   if ($char eq '0') {
     $result .= "het cijfer nul, " 
   } else {
     $result .= ( $seen{$char}++ ? 'nogmaals ' : '' ). ($char eq uc($char) ? 'de hoofdletter' : 'de letter') . " $char van " . $table{uc($char)}->[ int rand @{$table{uc($char)}}] . ", ";    
   }
}

$result =~ s/, $/./;

print "Uw password is $pass. U spelt dit met ";
print $result, "\n";

                                                                                                                                           