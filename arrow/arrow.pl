#!/usr/bin/perl -w
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl

use LWP::UserAgent;
use HTTP::Cookies;

$ua = new LWP::UserAgent;

#### allerlei fijne definities en initialisaties ########

@agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);

$agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

$request = new HTTP::Request( 'GET', "http://www.arrow.nl/jazz/now_playing.php" );
$request->referer("http://www.arrow.nl/jazz/indexjazz.php");
$response = $ua->request($request);
$html     = $response->content;
@lines    = split /^/m, $html;

my $resultline;
my $go = 0;
foreach $line (@lines) {
    if ($go) {
       $resultline = $line;
       $go = 0;    
    }
    if ( $line =~ m|.*?images/nowplaying2kl_05.jpg.*?| ) {
        $go = 1;
    }
}                
#print STDERR $resultline , "\n";
if ( $resultline =~ m/\s*(.*?)-(.*?)\s*$/) {
   print lc("Now playing on arrow jazz: $2 (by $1)\n");
} else {
   print "Unable to find current song for arrow jazz\n";
}