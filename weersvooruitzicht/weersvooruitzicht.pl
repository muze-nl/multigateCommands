#!/usr/bin/perl -w
# Bas van Sisseren / 17-05-2004
#	Based on: Casper Eyckelhof's !tt

use strict;
use LWP::UserAgent;
use HTML::Entities;

my $content;

if (1) {
    my $baseurl = "http://teletekst.nos.nl/tekst/";

    my $cmdline = @ARGV ? shift: 'test';
    my $url = $baseurl . '704-01.html';

    ## Get a certain URL
    my $ua = new LWP::UserAgent;

    #Set agent name, we are not a script! :)
    $ua->agent("Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)");

    my $request = new HTTP::Request( 'GET', $url );
    $request->referer('http://portal.omroep.nl/');

    $request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
    $request->header( "Accept-Encoding" => "gzip,deflate" );
    $request->header( "Accept-Language" => "en-us, en;q=0.5" );
    $request->header( "Accept-Charset"  => "ISO-8859-1,utf-8;q=0.7,*" );

    $content = $ua->request($request)->content;

    #	open F, "> content";
    #	print F $content;
    #	close F;
} else {
    open F, "< content";
    $content = join '', <F>;
    close F;
}

#get everything between <pre> </pre>
if ( $content =~ s/^.*?<pre>(.*?)<\/pre>.*?$/$1/si ) {
    $content =~ s/<[^>]*>//g;
    $content = HTML::Entities::decode($content);
    my @content = split /\n+/, $content;
    my @days    = ();
    my %data    = ();
    foreach my $line (@content) {
        chomp $line;
        $line =~ s/^\s+//g;
        $line =~ s/\s+/ /g;
        $line =~ s/\s*$/ /g;
        if ( $line =~ /^((ma|di|wo|do|vr|za|zo) ){5}$/ ) {
            @days = split / /, $line;
        }
        if ( @days && $line =~ /^zon \% ((\d+ ){5})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 5 ; $i++ ) { $data{ $days[$i] }{zon} = $val[$i] }
        }
        if ( @days && $line =~ /^neersl\. \% ((\d+ ){5})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 5 ; $i++ ) { $data{ $days[$i] }{neerslag} = $val[$i] }
        }
        if ( @days && $line =~ /^min\.temp\. ((-?\d+ ){5})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 5 ; $i++ ) { $data{ $days[$i] }{min_temp} = $val[$i] }
        }
        if ( @days && $line =~ /^max\.temp\. ((-?\d+ ){5})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 5 ; $i++ ) { $data{ $days[$i] }{max_temp} = $val[$i] }
        }
        if ( @days && $line =~ /^-richting (([NWZSEO]+ |VAR ){5})$/ ) {
            my @val = map { $_ eq 'VAR' ? '-' : $_ } split / /, $1;
            for ( my $i = 0 ; $i < 5 ; $i++ ) { $data{ $days[$i] }{wind_ri} = $val[$i] }
        }
        if ( @days && $line =~ /^-kracht ((\d+ ){5})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 5 ; $i++ ) { $data{ $days[$i] }{wind_kr} = $val[$i] }
        }
    }
    foreach my $day (@days) {
        printf "%s: %02u%% zon; %02u%% neerslag; %2s tot %2s graden; wind: %-2s %s\n", $day,
          @{ $data{$day} }{ 'zon', 'neerslag', 'min_temp', 'max_temp', 'wind_ri', 'wind_kr' };
    }
} else {
    print "Pagina niet gevonden\n";
}
