#!/usr/bin/perl

@dob    = "";
$total  = 0;
$amount = 0;
$string = "";
$count  = 0;
$min    = 0;
$max    = 0;

if ( ( @ARGV > 0 ) && ( $ARGV[0] =~ /^\w+/ ) ) {
    @dob = split /d/, $ARGV[0];
    if ( @dob < 2 ) {
        $dob[1] = $dob[0];
        $dob[0] = 1;
    }
} else {
    $dob[0] = 1;
    $dob[1] = 6;
}

if ( ( $dob[0] > -1 ) && ( $dob[0] < 26 ) && ( $dob[1] > 0 ) && ( $dob[1] < 1001 ) ) {
    for ( $count = 0 ; $count < $dob[0] ; $count++ ) {
        if ( length($string) > 0 ) {
            $string .= ", ";
        }
        $amount = int( rand( $dob[1] ) ) + 1;
        $total += $amount;
        $string .= $amount;
        $min += 1;
        $max += $dob[1];
    }
    print "Tussen " . $min . " en " . $max . " rol je: " . $total . " (" . $string . ")";
} else {
    print "Gebruik 'dobbel [ndx]', waarin n het aantal en x de grootte van de dobbelstenen zijn.";
}

