#!/usr/bin/perl -w

use strict;

if ( !defined $ARGV[0] ) {
    print "Syntax: unroman <roman number>\n";
    exit(1);
}

my $rnum = $ARGV[0];
my %vals = (
    I => 1,
    V => 5,
    X => 10,
    L => 50,
    C => 100,
    D => 500,
    M => 1000,
);
my $result = 0;
my $pval   = 0;

my @letters = split ( / */, $rnum );

foreach my $l (@letters) {
    my $val = $vals{$l};
    if ( !defined $val ) {
        print "Wrong character in roman string: $l\n";
        exit(1);
    }
    $result += $val;
    if ( $val > $pval ) {
        $result -= 2 * $pval;
    }
    $pval = $val;
}

print "$result\n";
exit 0;

#Het kan ook korter: zonder errorchecking:
#!/usr/bin/perl -paF// 
#%v=(I1V5X10L50C100D500M1000)=~/(.)(\d+)/g;map{$a=$v{$_};$a>$p?$r-=2*$p:$r+=$a;$p=$a}@F;$_=$r.$/
