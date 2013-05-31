#!/usr/bin/perl -w
use strict;

my $number = 0;
my $categoryrequest = '';

if ( defined( $ARGV[0] ) ) {
    if ( ( $ARGV[0] =~ /(\d+)/ ) && ( !defined( $ARGV[1] ) ) ) {
        #nummertje gevraagd
        $number = $1;
    } else {
        $categoryrequest = join(" ", @ARGV);
        $categoryrequest =~ tr/A-Z/a-z/;
    }
}

#Inlezen file

open( JOKES, "< rekrowten.txt" );

my @jokes;
my $count = 0;
my @categories;
my %categoriesbegin;
my %categoriesend;
my $category = '';

while ( my $line = <JOKES> ) {
    chomp $line;
    
    if ( $line=~ /^>>>(.*)<<<$/) {
        push @categories, $1;
        
        $category  =~ tr/A-Z/a-z/;
        $categoriesend{$category} = $count;
        
        $category = $1;
        my $cat = $1;
        $cat  =~ tr/A-Z/a-z/;
        $categoriesbegin{$cat} = $count + 1;
    } else {
        $count++;
        push @jokes, $line .' ('.$category .', ID:';
    }
}
$category  =~ tr/A-Z/a-z/;
$categoriesend{$category} = $count;

close JOKES;

sub printjoke {
    print join("\n", split('>>n<<', $jokes[$_[0] - 1] ."$_[0])"));
}

if ( $number > 0 && $number > $count ) {
    print "$number bestaat niet, een nummer tussen 1 en $count (incl).";    
} elsif ( $number > 0 ) {
    if ( defined $jokes[$number - 1] ) {
        #arg is gegeven en rule nummer $arg bestaat
        printjoke $number;
    } else {
        print "Helaas bestaat $number niet, probeer een ander nummer tussen 1 en $count (incl).";
    }
} elsif ( $categoryrequest ne '' ) {
    if ( defined($categoriesbegin{$categoryrequest}) ) {
        if ( $categoriesbegin{$categoryrequest} <= $categoriesend{$categoryrequest} ) {
            my $begin = $categoriesbegin{$categoryrequest}; my $end = $categoriesend{$categoryrequest};
            printjoke int(rand($end - $begin + 1)) + $begin;
        } else {
            print "Helaas bevat de categorie '$categoryrequest' geen grappen.";
        }
    } else {
        print "Helaas bestaat de categorie '$categoryrequest' niet. De volgende categorieën bestaan wel: ". join(', ', @categories);
    }
} else {
    #pak random joke
    printjoke int(rand(@jokes)) +1;
}
