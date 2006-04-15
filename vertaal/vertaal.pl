#!/usr/bin/perl 
# Based on framework by Ado

use strict;
use LWP::UserAgent;

my ( $lang, $word, undef ) = split ( ' ', $ARGV[0], 3 );

$lang = lc($lang);
$word = lc($word);

my $multicast = $ENV{'MULTI_IS_MULTICAST'};
my $maxlines  = 4;                            #maxlines on multicast channel

my %langtable = (
    'e' => 2,
    'n' => 1,
    'f' => 4,
    'd' => 3,
#   's' => 6,  #(zweeds)
    's' => 5,  #(spaans)
);

my $fromlang = $langtable{ substr( $lang, 0, 1 ) };
my $tolang   = $langtable{ substr( $lang, 1, 1 ) };

if ( ( !defined $fromlang ) || ( !defined $tolang ) || ( !defined $word ) ) {
    print "Geef bestaande taalcode en 1 woord. (Bv. \"vertaal ne bier\")\n";
    exit(1);
}

# Create a new useragent instance
my $ua = new LWP::UserAgent;
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $url = "http://www.interglot.com/resultpage.php?word=$word&SrcLang=$fromlang&DstLang=$tolang";

# Fetch the requested page
my $request = new HTTP::Request( 'GET', $url );
my $result  = $ua->request($request);

if ( !$result->is_success ) {
    print "Error opening page\n";
    exit 1;
}

my @lines = split ( /^/m, $result->content );

my @results;
foreach my $line (@lines) {
   if ($line =~ m|SrcStar\[(\d+)\]\s*=\s*"(.*?)";.*?| ) {
      my $pos = $1;
      my $word = $2;
      $results[$pos] = [ $word ];   
   }
   if ($line =~ m|DestWords\[(\d+)\]\[(\d+)\]\s*=\s*"(.*?)";| ) {
      my ($pos1, $pos2) = ($1, $2);
      my $word = $3;
      push @{$results[$pos1]} ,  $word;
   }
}

my $cut = ( scalar(@results) > ($maxlines+1) ) and $multicast;  # do not show extra header when you can also show all results!
if ( $cut  ) {
   print scalar @results , " results. For complete list try a non-multicats channel.\n";
    splice @results, $maxlines; 
}

foreach my $entry (@results) {
   my $src = shift @$entry;
   print "$word ($src): " , join(', ', @$entry), "\n";
}

if ($cut) {
  exit 1; #to prevent caching
} else {
  exit 0;
}

