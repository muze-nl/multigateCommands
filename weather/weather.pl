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

    my @lines = split "\n", $response;
 
    #<td bgcolor="#EFEFEF" class="cnnBodyText"><b>Wednesday</b><BR><span class="cnnTempHi"><b>20&deg;F</b> (-7&deg;C)</span> | <span class="cnnTempLo"><b>18&deg;F</b> (-8&deg;C)</span></td> 
    foreach my $line (@lines) {
      if ($line =~
        m|.*?<td bgcolor="#EFEFEF" class="cnnBodyText"><b>(.*?)</b><BR><span class="cnnTempHi"><b>-?\d+&deg;F</b>\s\((-?\d+)&deg;C\).*?|i
      ) {
        #print STDERR "Match: $line\n";
        #@type = split ( /\./, $3 );
        $day = $1;
        $daytemp  = $2;
        $response = $4;
        #$type[0] =~ s/^(.)/\u$1/;
        $forecast = $forecast . $day . ": " . $daytemp . "C ";
        } else {
        #print STDERR "No match: $line \n";
        }
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

