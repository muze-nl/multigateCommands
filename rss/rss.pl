#!/usr/bin/perl
# No warnings... XML::RSS has some issues ;)
#
# Generic RSS command
# Casper Joost Eyckelhof

use strict;
use XML::RSS;
use LWP::UserAgent;
use HTML::Entities();

my $maxitems    = 5;
my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my %urls = (
    "slashdot"  => "http://slashdot.org/slashdot.rss",
    "fm"        => "http://freshmeat.net/backend/fm.rdf",
    "nu"        => "http://nu.nl/deeplink_rss",
    "fok"       => "http://rss.fok.nl/feeds/nieuws",
    "bbc"       => "http://www.bbc.co.uk/syndication/feeds/news/ukfs_news/world/rss091.xml",
    "security"  => "http://www.security.nl/headlines.rdf",
    "omroep"    => "http://portal.omroep.nl/rss.xml",
    "grouphug"  => "http://grouphug.us/rss",
    "geenstijl" => "http://www.geenstijl.nl/rss/index.php",
    "oxo"       => "http://kippendief.biz/rss.xml",
    "kip"       => "http://kippendief.biz/rss.xml",
    "themirror" => "http://themirror.nl/rss",
    "perl"      => "http://www.oreillynet.com/meerkat/?_fl=rss10&t=ALL&c=303",
    "debaday"   => "http://www.livejournal.com/users/debaday/data/rss",
    "thereg"    => "http://www.theregister.co.uk/headlines.rss",
);

# read known codes..
if ( opendir D, "./codes/" ) {
    while ( my $file = readdir D ) {
        next if $file eq '.' || $file eq '..';
        if ( open F, "< ./codes/$file" ) {
            my $url = <F>;
            chomp $url;
            close F;
            $urls{$file} = $url;
        }
    }
    closedir D;
}

if ( $commandline eq '' ) {
    print "Usage: rss <url or code> [number of items]\n";

} elsif ( $commandline =~ /^code\b/i ) {
    print "Available codes: ", join ( ", ", sort keys %urls ), "\n";

} elsif ( $commandline =~ /^add\b\s*(.*)$/i ) {
    my $c = $1;
    if ( $c =~ /^(\S+)\s+(\S+)$/ ) {
        my ( $code, $url ) = ( $1, $2 );
        if ( $code !~ /^\w+$/ ) {
            print "Invalid characters in code\n";
            exit;
        }
        if ( -e "./codes/$code" ) {
            print "Code '$code' already exists!\n";
            exit;
        }

        if ( open F, "> ./codes/$code" ) {
            print F "$url";
            close F;
            print "Code '$code' saved.\n";
        } else {
            print "Failed saving code '$code'.\n";
        }

    } else {
        print "Syntax error, try '!rss add <code> <url>'.\n";
    }

} else {
    my ( $url, $number ) = split " ", $commandline, 2;
    $url = $urls{$url} if ( defined $urls{$url} );

    if ( defined $number and ( $number =~ /^(\d+).*?$/ ) ) {
        $number = $1;
        $number = ( $number > $maxitems ) ? $maxitems : $number;
    } else {
        $number = 1;
    }

    my $rss = new XML::RSS;
    my $ua  = new LWP::UserAgent;

    #Set agent name, we are not a script! :)
    my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
    $ua->agent($agent);

    my $request = new HTTP::Request( 'GET', $url );
    my $response = $ua->request($request);
    if ( $response->is_success() ) {
        my $content = $response->content;

        eval { $rss->parse($content); };
        if ($@) {
            print "Cannot parse $url\n";
            exit 1;
        }
        my $chname = $rss->{'channel'}->{'title'};
        my $chlink = $rss->{'channel'}->{'link'};
        my $chdesc = $rss->{'channel'}->{'description'};

        my $result;
        my $count = 0;
        foreach my $item ( @{ $rss->{'items'} } ) {
            my $itemname = $item->{'title'};
            my $itemlink = $item->{'link'};
            my $itemdesc = $item->{'description'};
            unless ( defined $itemdesc ) { $itemdesc = 'no desciption' }
            unless ( defined $itemlink ) { $itemlink = 'no link' }
            if     ( defined $itemname ) {
                $itemdesc =~ s/\s*\n+\s*/ /g;
                $result .= "$itemname: $itemdesc ($itemlink)\n";
                $count++;
            }
            last unless ( $count < $number );
        }
        unless ( defined $result ) {
            $result = "$url bevat geen geldig RSS document";
            exit 1;
        }
        $result = HTML::Entities::decode($result);
        #No HTML-tags in the rss item content please
        $result =~ s/<.*?>//g;
        print $result;
    } else {
        print "Error retrieving url: $url\n";
    }
}
