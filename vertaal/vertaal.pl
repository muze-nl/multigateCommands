#!/usr/bin/perl 
# Arjan Opmeer (Ado)
# ado@dnd.utwente.nl

use strict;
use LWP::UserAgent;

my ( $lang, $word, undef ) = split ( ' ', $ARGV[0], 3 );

$lang = lc($lang);
$word = lc($word);

my $multicast = $ENV{'MULTI_IS_MULTICAST'};
my $maxlines  = 4;                            #maxlines on multicast channel

my %langtable = (
    'e' => "Engels",
    'n' => "Nederlands",
    'f' => "Frans",
    'd' => "Duits",
    'i' => "Italiaans",
    's' => "Spaans"
);

my $fromlang = $langtable{ substr( $lang, 0, 1 ) };
my $tolang   = $langtable{ substr( $lang, 1, 1 ) };

#print "from: $fromlang\nto: $tolang\n";

if ( ( !defined $fromlang ) || ( !defined $tolang ) || ( !defined $word ) ) {
    print "Geef bestaande taalcode en 1 woord. (Bv. \"vertaal ne bier\")\n";
    exit(1);
}

# Construct URL
my $url =
  "http://www.euroglotonline.nl/scripts/Eginternet/Euroglot.exe?&ScreenLanguage=Dutch&srcLang="
  . $fromlang
  . "&dstLang=" . $tolang
  . "&srcInput=" . $word
  . "&MorphReg=false&";

# Create a new useragent instance
my $ua = new LWP::UserAgent;

# Set agent name. Don't let the other side know that we are a script
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

# Fetch the requested page
my $request = new HTTP::Request( 'GET', $url );
my $result  = $ua->request($request);

if ( !$result->is_success ) {
    print "Error opening page\n";
    exit(1);
}

my $content = $result->content;

# Bleh! Output uses CRLF. Remove CR.
$content =~ s/\r//sg;

# Strip down output to inner table of nested tables structure
$content =~ s/^.*?<table.*?>(.*)<\/table>.*?$/$1/si;
$content =~ s/^.*?<table.*?>(.*)<\/table>.*?$/$1/si;
$content =~ s/^.*?<table.*?>(.*)<\/table>.*?$/$1/si;

# Remove remaining HTML markup
$content =~ s/<.*?>//sg;

# Remove leading and trailing whitespace
$content =~ s/^\s*//mg;
$content =~ s/\s*$//mg;

my @lines = split ( /^/m, $content );
chomp(@lines);

# Find matches
my $result  = "";
my @results = ();
my $count   = 0;
for ( my $i = 0 ; $i < $#lines ; $i = $i + 2 ) {
    if ( $lines[$i] =~ /^$word/i ) {
        $count++;
        $result .= "$count. $lines[$i]: $lines[$i + 1]\n";
        push @results, "$count. $lines[$i]: $lines[$i + 1]";
    }
}

if ($count) {
    if ($multicast) {    #print $maxlines lines
        print join "\n", splice( @results, 0, $maxlines );
    } else {    #print everything
        print join "\n", @results;
    }
} else {
    print "Niets gevonden\n";
}
