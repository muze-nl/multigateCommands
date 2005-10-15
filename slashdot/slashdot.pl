#!/usr/bin/perl -w
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl
use LWP::UserAgent;

$ua    = new LWP::UserAgent;
$proxy = "http://proxy.utwente.nl:3128/";
my $max_aantal = 1;    #number of articles to print
my $index      = 0;    #the index to start printing (starting at 0)  ##BUG FIXME##

#Set agent name, vooral niet laten weten dat we een script zijn
$agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

#Use the Proxy Luke!
$ua->proxy( "http", $proxy );
$url = "http://www.slashdot.org";

##Haal pagina  op
$request = new HTTP::Request( 'GET', $url );
$content = $ua->request($request)->content;
##Regel voor regel doorwerken
@lines = split /^/m, $content;

my $lasttopic;
my $lastdept;
my $lastmsg;
my $gogetit = 0;
my $aantal  = 0;

foreach $line (@lines) {
    if ( $gogetit == 1 ) {    #we moeten deze regel hebben (handelen met voorkennis!)
        $line =~ s/^>//;
        $line =~ s/<.*?>//g;
        $lastmsg = $line;
        $lastmsg =~ s/\($//;
        if ( $index <= $aantal ) {
            $resultaat = "$lasttopic - $lastdept\n$lastmsg\n";
            $resultaat =~ s/<.*?>//g;    #get rid of HTML in a stupid way
            print $resultaat;
        }
        $gogetit = 0;    #Totdat iemand anders er weer 1 van maakt
        $aantal++;
        if ( $aantal >= ( $max_aantal - $index ) ) { exit 0 }    #Vies he ;)
    }

    if ( $line =~ /^\s*FACE="arial,helvetica" SIZE="4" COLOR="#FFFFFF"><b>(.*?)<\/b><\/font><\/td>.*?$/i ) {
        $lasttopic = $1;
    }

    if ( $line =~ /^\s*<font SIZE="2"><b>(from the .*? dept\.)<\/b><\/font>.*?$/i ) {
        $lastdept = $1;
        $gogetit  = 1;    #next line is the actual message!
    }
}
