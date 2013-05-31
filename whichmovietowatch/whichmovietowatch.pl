#!/usr/bin/perl -w
# Frans van Dijk / 02-05-2013

use strict;
use LWP::UserAgent;
use HTTP::Cookies;
use HTML::Entities;

my $url = "http://www.whichmovietowatch.com/pick.php";

#Set agent name, we are not a script! :)
my @user_agents = (
    'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:7.0.1) Gecko/20100101 Firefox/7.0.1',
    'Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00',
    'Mozilla/5.0 (compatible; MSIE 10.6; Windows NT 6.1; Trident/5.0; InfoPath.2; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 2.0.50727) 3gpp-gba UNTRUSTED/1.0'
);

my $ua = LWP::UserAgent->new(
    agent           => $user_agents[rand @user_agents],
    cookie_jar      => HTTP::Cookies->new(),
    max_size        => 8388608,
    timeout         => 60,
);

my $request = new HTTP::Request( 'GET', $url );

$request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
#$request->header( "Accept-Encoding" => "gzip,deflate" );
$request->header( "Accept-Language" => "en-us, en;q=0.5" );
$request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

my $content = $ua->request($request)->content;

#get everything between <div id="page-wrap"> </div>
if ( $content =~ s/^.*?<div id="page-wrap">(.*?)<\/div>.*?$/$1/si ) {
    my $imdb = $content;
    my $youtube = $content;
    if ($imdb =~ /(http[^ '"]*imdb[^ '"]*)/) { $imdb = $1; } else { $imdb = ''; }
    if ($youtube =~/(http[^ '"]*youtube[^ '"]*)/) { $youtube = $1; } else { $youtube = '';}
    $content =~ s/\cM|\cJ/ /g;
    $content =~ s/<[^>]*>//g;
    $content =~ s/\s+/ /g;
    $content =~ s/^\s+//;
    $content =~ s/\s+$//;
    $content = HTML::Entities::decode($content);
    printf "%s ( %s %s )\n", $content, $imdb, $youtube;
} else {
    print "Page not found\n";
}

