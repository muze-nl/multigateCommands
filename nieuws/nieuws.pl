#!/usr/bin/perl -w
use strict;

use LWP::UserAgent;
use HTTP::Cookies;
use HTML::Entities();
my $ua = new LWP::UserAgent;

my @agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);

my $agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

#$ua->proxy( "http", "http://www.area53.nl:4242/" ); #temporary proxy

my $request = new HTTP::Request( 'GET', "http://teletekst.nos.nl/tekst/101-01.html" );
$request->referer('http://portal.omroep.nl/');
$request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
$request->header( "Accept-Encoding" => "gzip,deflate" );
$request->header( "Accept-Language" => "en-us, en;q=0.5" );
$request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

my $response = $ua->request($request);
my @html     = split /\n/, $response->content;

my @result = ();
foreach my $line (@html) {
    if ( $line =~ m|^<font color=white> </font><font color=aqua>(.*?)<font color=yellow>(\d+)</a></font>$|i ) {
        my $regel = $1;
        my $page  = $2;

        $regel =~ s/<.*?>//g;      #html-tags
        $regel =~ s/\.+\s*$//g;    #puntjes
        $regel =~ s/\s+/ /g;       #dubbele spaties
        $regel =~ s/\s*$//g;       #trailing spaces

        $regel = HTML::Entities::decode($regel);
        push @result, $regel . " ($page)";

    } elsif ( $line =~ m|^<font color=white> </font><font color=aqua>(.*?)</font>(.*?)</a></font>$|i ) {
        my $regel = $1;
        my $rest  = $2;

        $regel =~ s/<.*?>//g;                  #html-tags
        $regel =~ s/\.+\s*$//g;                #puntjes
        $rest  =~ s/<.*?>//g;                  #html-tags
        $rest  =~ s/(\d{3}(?:\/\d)?)/($1)/g;

        $regel .= $rest;

        $regel =~ s/((?:\d{3},)+\d{3})$/ ($1)/;    # lijst met komma's
        $regel =~ s/(\d{3}-\d{3})$/ ($1)/;         # range met streepje

        $regel =~ s/\s+/ /g;                       #dubbele spaties

        $regel = HTML::Entities::decode($regel);
        push @result, $regel;
    }
}

print join ", ", @result;
print "\n";
exit 0;
