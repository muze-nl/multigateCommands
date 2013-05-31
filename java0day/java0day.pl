#!/usr/bin/perl -w
# Frans van Dijk / 03-05-2013

use strict;
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::Entities;

my $url1 = "http://istherejava0day.com/";

#Set agent name, we are not a script! :)
my @user_agents = (
    'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:7.0.1) Gecko/20100101 Firefox/7.0.1',
    'Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00',
    'Mozilla/5.0 (compatible; MSIE 10.6; Windows NT 6.1; Trident/5.0; InfoPath.2; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 2.0.50727) 3gpp-gba UNTRUSTED/1.0'
);

my $ua = LWP::UserAgent->new(
    agent           => $user_agents[rand @user_agents],
    cookie_jar      => HTTP::Cookies->new(),
    max_size        => 1048576,
    timeout         => 60,
);

my $request = new HTTP::Request( 'GET', $url1 );

$request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
#$request->header( "Accept-Encoding" => "gzip,deflate" );
$request->header( "Accept-Language" => "en-us, en;q=0.5" );
$request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

my $response1 = $ua->get($url1);

if ($response1->is_success) {
    my $content1 = $response1->content;
    #get everything between <body> </body>
    $content1 =~ s/^.*?<body>(.*?)<\/body>.*?$/$1/si;
    $content1 =~ s/<[^>]*>//g;
    $content1 =~ s/\s+/ /g;
    $content1 =~ s/^\s+//;
    $content1 =~ s/\s+$//;
    $content1 = HTML::Entities::decode($content1);
    if ($content1 =~ /yes/i) {
        my $url2 = "http://java-0day.com/";
        my $response2 = $ua->get($url2);
        if ($response2->is_success) {
            my $content2 = $response2->content;
            $content2 =~ s/^.*?var lastzeroday = new Date\(.(.*?).\);.*?$/$1/si;
            $content2 =~ s/^(.*) .*$/$1/;
            $content2 =~ s/^\s+//;
            $content2 =~ s/\s+$//;
            $content2 = HTML::Entities::decode($content2);
            print "Is there Java 0day? $content1, since $content2 ( $url2 )\n";
        } else {
            print "Is there Java 0day? $content1 ( $url1 )\n";
        }
    } else {
        print "Is there Java 0day? $content1 ( $url1 )\n";
    }
} else {
    print "Page not found\n";
}

