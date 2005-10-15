#!/usr/bin/perl
# Ooit via wiggy gekregen
# Aangepast toen CNN de html ging aanpassen
# Moet een keer overnieuw, is vies!

my $query = $ARGV[0];

my $response = `wget -o /dev/null -O /dev/stdout http://weather.cnn.com/weather/search?wsearch='$query'`;
my $reply    = "I can't find the temperature for '$query'";

if ( $response =~ /\((-?\d+)&deg;c\)/i ) {
    my $temperature = $1;
    my $weathertype = "Unknown";
    my $forecast    = "";
    my $day         = "";
    my $daytemp     = 0;
    my @type;

    if ( $response =~
        m|<td colspan="2"><div class="cnnBodyText" style="font-size:22px;padding-top:3px;padding-bottom:3px;" align="center"><b>(.*?)</b></div></td>|i
      )
    {
        $weathertype = $1;
    }

    while ( $response =~
        m|<td bgcolor="#EFEFEF" class="cnnBodyText"><b>(.*?)</b><BR><span class="cnnTempHi"><b>-?\d+&deg;F</b> \((-?\d+)&deg;C\).*?http://i.cnn.net/cnn/.element/img/1.0/weather/med/(.*?)\.gif(.*)$"|si
      )
    {
        #print STDERR "Match\n";
        @type = split ( /\./, $3 );
        $day = $1;
        $daytemp  = $2;
        $response = $4;
        $type[0] =~ s/^(.)/\u$1/;
        $forecast = $forecast . $day . ": " . $daytemp . " C (" . join ( " ", @type ) . ") ";
    }

    $query =~ s/^(.)/\u$1/;
    $reply = "It's $temperature C ($weathertype) in $query,\nforecast: $forecast";
} elsif ( $response =~ /\?locCode=[^"]+">([^<]+)/ ) {
    $reply = "Multiple cities match your query: ";

    while ( $response =~ /\?locCode=[^"]+">([^<]+)/ ) {
        $reply = $reply . "'" . $1 . "' ";

        $response = $';
    }
}

print("$reply\n");

