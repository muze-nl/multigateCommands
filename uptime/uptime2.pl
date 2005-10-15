#!/usr/bin/perl 

do "/home/multilink/multigate/commands/jarig/nickresolve.pl";

$bdays_db = "/home/multilink/multigate/commands/jarig/bdays.db";

sub printsyntax {
    print "$_[0]    Typ: /msg multilink jarig -h\n";
}

sub datetoday {

    ## day (1-31)
    ## month (1-12)
    my ($yday) = ( 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 )[ $_[1] - 1 ] + $_[0] - 1;

    return $yday;
}

sub isleapyear {

    ## year (1900...)
    my ($leap) = 0;

    if ( ( ( $_[0] % 4 ) eq 0 ) && ( ( ( $_[0] % 100 ) ne 0 ) || ( ( $_[0] % 400 ) eq 0 ) ) ) {
        $leap = 1;
    }
    return ($leap);
}

sub datetopit {

    ## day (1-31)
    ## month (1-12)
    ## year
    ## baseyear ( <= year)
    my ($day)      = $_[0];
    my ($month)    = $_[1];
    my ($year)     = $_[2];
    my ($baseyear) = $_[3];
    my ($pit)      = datetoday( $day, $month );

    $pit = $pit + ( $year - $baseyear ) * 366;
    while ( $baseyear lt $year ) {
        if ( isleapyear($baseyear) eq 0 ) {
            $pit = $pit - 1;
        }
        $baseyear = $baseyear + 1;
    }
    if ( ( int($month) ge 3 ) && ( isleapyear($year) eq 0 ) ) {
        $pit = $pit - 1;
    }

    return ($pit);
}

sub bdayrange {

    ## From date
    @fdate = ( $_[0], $_[1], $_[2] );
    $fday = datetoday( $fdate[0], $fdate[1] );

    ## To date
    @tdate = @fdate;
    $tdate[1] = $tdate[1] + 1;
    if ( $tdate[1] eq 13 ) {
        $tdate[1] = 1;
        $tdate[2] = $tdate[2] + 1;
    }
    $tday = datetoday( $tdate[0], $tdate[1] );

    @bmessages = ();

    open( BDB, "< $bdays_db" ) or die "Unable to open bdays.db\n";
    while ( ( $line = <BDB> ) ) {
        if ( $line !~ /^#/ ) {
            @bdays  = split ' ', $line;
            @bdates = split '-', $bdays[1];
            $bday = datetoday( $bdates[0], $bdates[1] );
            $hit = 0;
            if ( $fdate[2] ne $tdate[2] ) {

                ## Range covers a year change
                if ( ( $bday >= $fday ) || ( $bday < $tday ) ) {
                    $hit = 1;
                    if ( $bday >= $fday ) {
                        $year = $fdate[2];
                    } else {
                        $year = $tdate[2];
                    }
                }
            } else {

                ## Entire range within the same year
                if ( ( $fday <= $bday ) && ( $bday < $tday ) ) {
                    $hit  = 1;
                    $year = $fdate[2];
                }
            }
            if ( $hit ne 0 ) {
                $age = $year - $bdates[2];
                $messages[@messages] = "$year$bdates[1]$bdates[0] $bdays[ 0]" . " $bdates[0]-$bdates[1]-$year ($age)\n";
            }
        }
    }
    close(BDB);
    @messages = sort @messages;
    if ( @messages ne 0 ) {
        print "Verjaardagen in de periode van $fdate[0]-$fdate[1]-$fdate[2] tot $tdate[0]-$tdate[1]-$tdate[2]:\n";
        foreach $message (@messages) {
            print substr( $message, 9, length($message) - 9 );
        }
    } else {
        print "Geen verjaardagen gevonden in de periode van $fdate[0]-$fdate[1]-$fdate[2] tot $tdate[0]-$tdate[1]-$tdate[2]:\n";
    }
}

sub bdayuptime {
    $alias = $_[0];
    $nick  = $_[1];

    $found = 0;

    open( BDB, "< $bdays_db" ) or die "Unable to open bdays.db\n";
    while ( ( $found eq 0 ) && ( $line = <BDB> ) ) {
        if ( $line !~ /^#/ ) {
            @bdays = split ' ', $line;
            if ( $bdays[0] eq $nick ) {
                $bdate = $bdays[1];
                $btime = $bdays[2];
                if ( $btime eq '' ) {
                    $btime = '12:00';
                }
                print STDERR "date,time = $bdate,$btime\n";

                ##
                ## Now calculate the person's "uptime"
                ##
                @btimes = split ':', $btime;
                @bdates = split '-', $bdate;

                @ntimes = localtime(time);

                $bhour   = $btimes[0];
                $bminute = $btimes[1];
                $bday    = $bdates[0];
                $bmonth  = $bdates[1];
                $byear   = $bdates[2];

                @ctimes  = localtime(time);
                $chour   = $ctimes[2];
                $cminute = $ctimes[1];
                $cday    = $ctimes[3];
                $cmonth  = $ctimes[4] + 1;
                $cyear   = $ctimes[5] + 1900;

                $bpit = datetopit( $bday, $bmonth, $cyear, $cyear - 1 ) * 24 * 60 + $bhour * 60 + $bminute;
                $cpit = datetopit( $cday, $cmonth, $cyear, $cyear - 1 ) * 24 * 60 + $chour * 60 + $cminute;
                print STDERR "bpit,cpit = $bpit,$cpit\n";

                if ( $cpit lt $bpit ) {

                    # birthday still to come in this year
                    $years = $cyear - $byear - 1;
                    $bpit = datetopit( $bday, $bmonth, $cyear - 1, $cyear - 1 ) * 24 * 60 + $bhour * 60 + $bminute;
                } else {

                    # have already had the birthday this year
                    $years = $cyear - $byear;
                }

                $pits = $cpit - $bpit;

                $days    = int( $pits / 24 / 60 );
                $hours   = int( ( $pits / 60 ) % 24 );
                $minutes = $pits % 60;

                ## Thanks to sim for the brilliant uptime idea
                if ( $bdays[2] eq '' ) {
                    print "$alias  system boot $bdays[ 1], uptime $years years, $days days\n";
                } else {
                    print "$alias  system boot $bdays[ 1] $bdays[ 2], uptime $years years, $days days, $hours hrs, $minutes mins\n";
                }
                $found = 1;
            }
        }
    }
    if ( $found eq 0 ) {
        print "Geen verjaardag gevonden voor $alias\n";
    }
    close(BDB);
}

if ( @ARGV > 1 ) {
    printsyntax("Te veel argumenten");
    exit 1;
}

if ( ( $ARGV[0] eq '-h' ) || ( $ARGV[0] eq '--help' ) ) {
    print "Syntax: !jarig [<nick> | <maand> | +<offset>]\n";
    print "!jarig            Verjaardagen komende maand (zelfde als !jarig +0)\n";
    print "!jarig <nick>     Geboorte datum en uptime van de persoon <nick>\n";
    print "!jarig <maand>    De verjaardagen in maand <maand> 1 = januari, 12 = december\n";
    print "!jarig +<offset>  De verjaardagen (gedurende een maand tijd) <offset> maanden vanaf vandaag\n";
    exit 0;
}

## Process arguments ##
$nick  = nickresolve( $ARGV[0] );
$fchar = substr( $ARGV[0], 0, 1 );

if ( ( ( $fchar ge '0' ) && ( $fchar le '9' ) ) || ( $fchar eq '+' ) || ( $fchar eq '' ) ) {

    ##
    ## Get current date
    ##
    ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    $year = $year + 1900;
    $mon  = $mon + 1;

    if ( ( $fchar eq '+' ) || ( $fchar eq '' ) ) {

        ##
        ## Offset [ 0...11]
        ##
        if ( $fchar eq '+' ) {
            if ( length( $ARGV[0] ) eq 1 ) {
                printsyntax("Je moet wel een getal d'rbij zetten");
                exit 1;
            }
            $offset = substr( $ARGV[0], 1, length( $ARGV[0] ) - 1 );
        } else {
            $offset = 0;
        }
        if ( ( $offset < 0 ) || ( $offset > 11 ) ) {
            printsyntax("Van 0 t/m 11 aub");
            exit 1;
        }
        $mon = $mon + $offset;
        if ( $mon > 12 ) {
            $mon  = $mon - 12;
            $year = $year + 1;
        }
    } else {

        ##
        ## Specific calendar month [ 1...12]
        ##
        $month = $ARGV[0];
        if ( ( $month < 1 ) || ( $month > 12 ) ) {
            printsyntax("Van 1 t/m 12 aub");
            exit 1;
        }
        if ( $month < $mon ) {
            $year = $year + 1;
        }
        $mon  = $month;
        $mday = 1;
    }
    bdayrange( $mday, $mon, $year );
} else {
    bdayuptime( $ARGV[0], $nick );
}
