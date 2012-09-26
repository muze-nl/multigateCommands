#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# joost@dnd.utwente.nl
# Haalt het meest recente file-nieuws van tt op en scrijft deze naar STDOUT
# Niet kort of heel efficient, maar werkt prima :)

# Frans van Dijk (`36`)
# fransd@scintilla.utwente.nl
# Volgende aanpassingen:
#  - Als er geen argument gegeven wordt alleen een opsomming geven.
#  - Betere controle of er een volgende pagina is door te kijken of de huidige pagina een link 'volgende subpagina' bevat.
#  - Mogelijk gemaakt dat 730-10 en verder worden opgevraagd ipv 730-010


use HTML::Entities();
use LWP::UserAgent;
$ua = new LWP::UserAgent;

#Set agent name, vooral niet laten weten dat we een script zijn
$agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $args = shift @ARGV;
my %wegen;

sub get_url {
    my $url = shift;
    $request = new HTTP::Request( 'GET', $url );
    $request->referer('http://portal.omroep.nl/');
    $request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
    $request->header( "Accept-Encoding" => "gzip,deflate" );
    $request->header( "Accept-Language" => "en-us, en;q=0.5" );
    $request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

    $content = $ua->request($request)->content;
    return $content;
}

sub parse_page {
    #get everything between <pre> </pre>
    if ( $content =~ /<pre>/ ) {
        my $lastpage = 1;
        if ( $content =~ /volgende subpagina/ ) {
            $lastpage = 0;
        }
        $content =~ s/^.*?<pre>.*?\n(.*?)<\/pre>.*?$/$1/si;
        $content =~ s/.*?Files.*?\n(.*)/$1/si;
        #      $content =~ s/\*+//g;
        $content =~ s/<font .*?>//sgi;
        $content =~ s/<\/font>//sgi;
        #      $content =~ s/<A HREF=".*?html">(\d{3})<\/A>/($1),/gi;
        #      $content =~ s/\n+//g;
        #      $content =~ s/\.{2,}//g;
        #      $content =~ s/([,.])/$1 /g;
        #      $content =~ s/\s{2,}/ /g;
        #      $content =~ s/^\s//g;
        #      $content =~ s/<A HREF=".*?html">(\d{3})<\/A>/($1),/gi;
        #      $content =~ s/volgende nieuws index.*$//i;
        #      $content =~ s|binnenland.*?VERKEERSINFORMATIE actueel .*? uur||gi;

        $content = HTML::Entities::decode($content);

        my $last_weg;
        my @lines = split /\n/, $content;
        foreach my $line (@lines) {
            if ( $line =~ /^\s+?-\s+?(.*?) (.*)/ ) {
                $last_weg = $1;
                $wegen{$last_weg} .= $2;
            } else {
                if ( $line =~ /\*+/ ) {
                    $last_weg = "rest";
                }
                $wegen{$last_weg} .= $line;
            }
        }
        return $lastpage;
    } else {
        return undef;
    }
}



my $base_url   = "http://teletekst.nos.nl/tekst/730-";
my $page_index = 1;

my $next = 1;
while ($next) {
    $url = $base_url . sprintf("%02d", $page_index) . ".html";
    #print $url ."\n";
    my $lastpage = parse_page( get_url($url) );
    if ( defined $lastpage ) {
        if ($lastpage == 1) {
            $next = 0;
        }
    } else {
        $next = 0;
    }
    $page_index++;
}

delete $wegen{"rest"};

my $output;

unless ( $args eq "" ) {
    my @argjes = split " ", $args;
    foreach my $arg (@argjes) {
        $arg = uc($arg);
        if ( defined $wegen{$arg} ) {
            $wegen{$arg} =~ s/\s{2,}/ /g;
            $output .= $arg . " " . $wegen{$arg} . "\n";
        }
    }
    if ( $output eq "" ) {
        $output = "Geen files gevonden voor aangegeven traject\n";
    }
}
else {
    foreach my $key ( keys %wegen ) {
        $wegen{$key} =~ s/\s{2,}/ /g;
        $output .= "$key, ";# . $wegen{$key} . "\n";
    }
    if ( $output eq "" ) {
        $output = "Er zijn op dit moment geen files\n";
    } else {
        $output =~ s/(.*), /$1/;
        $output =~ s/(.*),/$1 en/;
        $output = "Er zijn momenteel files op: $output\n";
    }
}

print $output;
