#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;

## Import available environment variables
my $is_multicast = $ENV{'MULTI_IS_MULTICAST'};    # message to multiple recipients (channels)

my $multicast_max_lines = 3;
my @output              = ();

## Get a certain URL
my $url = "http://www.dnd.utwente.nl/supermarkt.txt";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
#   ([BvS] alsof dat uitmaakt naar je eigen server toe ;-) )
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $request = new HTTP::Request( 'GET', $url );
my $content = $ua->request($request)->content;

my @lines = split /^/m, $content;

my @namen;
my %opentijd      = ();
my %sluittijd     = ();
my %koopavond     = ();
my %sluitzaterdag = ();

my %dagen = (
    'zo' => 0,
    'ma' => 1,
    'di' => 2,
    'wo' => 3,
    'do' => 4,
    'vr' => 5,
    'za' => 6
);
my %rdagen = ();

foreach my $dag ( keys %dagen ) {
    $rdagen{ $dagen{$dag} } = $dag;
}

sub printUsage {
    return "usage: !super {tijds-indicatie | substring | help}";
}

sub getArgTime {
    my ($arg) = @_;
    my $mijntijd = getHour() * 60 + getMin();

    if ( $arg =~ /^nu$/i ) { return $mijntijd; }

    if ( $arg =~ /^([-+])(\d+)([mhu])?$/i ) {
        my $min = $2;
        if ( $1 eq "-" ) { $min *= -1; }
        if ( $3 =~ /[hu]/i ) { $min *= 60; }
        $mijntijd += $min;
        if ( $mijntijd < 0 ) { $mijntijd = 0; }
        if ( $mijntijd >= 24 * 60 ) { $mijntijd = 23 * 60 + 59; }
        return $mijntijd;
    }

    if ( $arg =~ /^(0|[1-9]\d*)[:\.]?([0-5]\d)$/ ) {
        $mijntijd = $1 * 60 + $2;
        if ( $mijntijd < 0 ) { $mijntijd = 0; }
        if ( $mijntijd >= 24 * 60 ) { $mijntijd = 23 * 60 + 59; }
        return $mijntijd;
    }

    return undef;
}

sub getDay {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    return ($wday);
}

sub getHour {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    return ($hour);
}

sub getMin {
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    return ($min);
}

sub getOpen {
    my ( $naam, $day ) = @_;
    if ( $day == 0 ) { return undef; }    #no supermarkets are open on sundays
    my $opentime = $opentijd{$naam};
    if ( $opentime =~ /^([0-9:]+)/ ) { return $1; }
    else { return undef; }
}

sub getClose {
    my ( $naam, $day ) = @_;
    if ( $day == 0 ) { return undef; }    #no supermarkets are open on sundays
    my $closetime;
    if ( $day == 6 ) { $closetime = $sluitzaterdag{$naam}; }
    else {
        my $dayname = $rdagen{$day};
        if ( $koopavond{$naam} =~ /$dayname/i ) {
            $koopavond{$naam} =~ /^([0-9:]+)/;
            return $1;
        } else {
            $closetime = $sluittijd{$naam};
        }
    }
    if ( $closetime =~ /^([0-9:]+)/ ) { return $1; }
    else { return undef; }
}

my $line;
my $started = 0;
foreach $line (@lines) {
    if ( $line =~ /^\s*\$/ ) { next; }    #just an empty line, we like to skip those

    if ( $line =~ /^[=+]*$/ ) { $started = 1; }

    if ( ( $started == 1 )
        && ( $line =~
            /^([\w ]+\w)(\t|\s\s)\s*([0-9:?]+)(\t|\s\s)\s*([0-9:?]+)(\t|\s\s)\s*(\?|-|[0-9:]+ +\([\w\/]+\)( \?)?)(\t|\s\s)\s*([0-9:]+)/
        ) )
    {
        push @namen, $1;

        $opentijd{$1}      = $3;
        $sluittijd{$1}     = $5;
        $koopavond{$1}     = $7;
        $sluitzaterdag{$1} = $10;
    }
}

# Choose wanted functionality:
if ( !( defined $ARGV[0] ) ) {
    push @output, printUsage();

} elsif ( defined( my $mijntijd = getArgTime( $ARGV[0] ) ) ) {
    foreach my $naam (@namen) {
        my $day = getDay();
        if ( defined $mijntijd ) {
            my $mijnopentijd  = getOpen( $naam,  $day );
            my $mijnsluittijd = getClose( $naam, $day );
            if ( defined $mijnopentijd && defined $mijnsluittijd ) {
                $mijnopentijd =~ /^(\d+):(\d+)/;
                my $mijnopen = $1 * 60 + $2;
                $mijnsluittijd =~ /^(\d+):(\d+)/;
                my $mijnsluit = $1 * 60 + $2;
                if ( $mijntijd < 12 * 60 ) {
                    if ( ( $mijnopen <= $mijntijd ) && ( $mijntijd <= $mijnsluit ) ) {
                        push @output, "$naam is al open vanaf $mijnopentijd";
                    }
                } else {
                    if ( ( $mijnopen <= $mijntijd ) && ( $mijntijd <= $mijnsluit ) ) {
                        push @output, "$naam is nog open tot $mijnsluittijd";
                    }
                }
            }
        } else {
            push @output, printUsage();
        }
    }

    push @output, "Helaas, er zijn geen open supermarkten gevonden..."
      unless @output;

} elsif ( exists $dagen{ $ARGV[0] } ) {
    if ( my $day = $dagen{ $ARGV[0] } ) {
        foreach my $naam (@namen) {
            my $mijnopentijd  = getOpen( $naam,  $day );
            my $mijnsluittijd = getClose( $naam, $day );
            if ( defined $mijnopentijd && defined $mijnsluittijd ) {
                push @output, "$naam : $mijnopentijd -> $mijnsluittijd";
            }
        }

        push @output, "Helaas, er zijn geen supermarkten gevonden die " . "open zijn op $day..." unless @output;
    } else {
        push @output, "Er zijn geen supermarkten open op zondag!";
    }

} elsif ( defined $ARGV[0] && ( $ARGV[0] eq "help" ) ) {
    push @output, printUsage();

} elsif ( defined $ARGV[0] && ( $ARGV[0] =~ /^\w+$/ ) ) {
    my $naamdeel = $ARGV[0];
    foreach my $naam ( grep { /$naamdeel/i } @namen ) {
        push @output, "$naam : open om: $opentijd{$naam}, dicht om: $sluittijd{$naam}, "
          . "koopavond: $koopavond{$naam}, zaterdag: $sluitzaterdag{$naam}";
    }

    push @output, "Helaas, er zijn geen supermarkten gevonden die " . "matchen op $naamdeel..." unless @output;

} else {
    push @output, printUsage();
}

if (@output) {
    if ( $is_multicast && @output > $multicast_max_lines ) {
        print "Too much output, please try again on non-multicast protocol\n";
    } else {
        foreach my $outputline (@output) {
            print $outputline. "\n";
        }
    }
} else {
    print "Geen resultaat, !supermarkt stuk?\n";
}
