#!/usr/bin/perl -w
# Frans van Dijk / 02-05-2013
#   Based on version from: Bas van Sisseren / 17-05-2004
#     That was based on: Casper Eyckelhof's !tt

use strict;
use LWP::UserAgent;
use HTML::Entities;

my $content;

if (1) {
    my $url = "http://www.knmi.nl/waarschuwingen_en_verwachtingen/";

    ## Get a certain URL
    my $ua = new LWP::UserAgent;

    #Set agent name, we are not a script! :)
    my @user_agents = (
        'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:7.0.1) Gecko/20100101 Firefox/7.0.1',
        'Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00',
        'Mozilla/5.0 (compatible; MSIE 10.6; Windows NT 6.1; Trident/5.0; InfoPath.2; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 2.0.50727) 3gpp-gba UNTRUSTED/1.0'
    );
    $ua->agent($user_agents[rand @user_agents]);

    my $request = new HTTP::Request( 'GET', $url );
    $request->referer('http://portal.omroep.nl/');

    $request->header( "Accept" => 'application/x-shockwave-flash,text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1' );
    #$request->header( "Accept-Encoding" => "gzip,deflate" );
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

#get everything between <div class=alineakop>vooruitzichten</div> </table>
if ( $content =~ s/^.*?<div class=alineakop>vooruitzichten<\/div>.*?<table.*?>(.*?)<\/table>.*?$/$1/si ) {
    $content =~ s/\cM|\cJ/ /g;
    $content =~ s/<tr>/\cJ/ig;
    $content =~ s/<[^>]*>//g;
    $content = HTML::Entities::decode($content);
    my @content = split /\n+/, $content;
    my @days    = ();
    my %data    = ();
    foreach my $line (@content) {
        chomp $line;
        $line =~ s/^\s+//;
        $line =~ s/\s+/ /g;
        $line =~ s/\s*$/ /;
        if ( $line =~ /^((Ma|Di|Wo|Do|Vr|Za|Zo) ){6}/ ) {
            @days = split / /, $line;
        }
        if ( @days && $line =~ /^Zonneschijn \(\%\) ((\d+ ){6})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 6 ; $i++ ) { $data{ $days[$i] }{zon} = $val[$i] }
        }
        if ( @days && $line =~ /^Neerslagkans \(\%\) ((\d+ ){6})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 6 ; $i++ ) { $data{ $days[$i] }{neerslagk} = $val[$i] }
        }
        if ( @days && $line =~ /^Neerslaghoeveelheid \(mm\) ((\d+(\/\d+)? ){6})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 6 ; $i++ ) { $data{ $days[$i] }{neerslagh} = $val[$i] }
        }
        if ( @days && $line =~ /^Minimumtemperatuur \(.C\) ((-?\d+(\/-?\d+)? ){6})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 6 ; $i++ ) { $data{ $days[$i] }{min_temp} = $val[$i] }
        }
        if ( @days && $line =~ /^Middagtemperatuur \(.C\) ((-?\d+(\/-?\d+)? ){6})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 6 ; $i++ ) { $data{ $days[$i] }{max_temp} = $val[$i] }
        }
        if ( @days && $line =~ /^Windrichting (([NWZSEO]+ |VAR ){6})$/ ) {
            my @val = map { $_ eq 'VAR' ? '-' : $_ } split / /, $1;
            for ( my $i = 0 ; $i < 6 ; $i++ ) { $data{ $days[$i] }{wind_ri} = $val[$i] }
        }
        if ( @days && $line =~ /^Windkracht \(bft\) ((\d+ ){6})$/ ) {
            my @val = split / /, $1;
            for ( my $i = 0 ; $i < 6 ; $i++ ) { $data{ $days[$i] }{wind_kr} = $val[$i] }
        }
    }
    foreach my $day (@days) {
        printf "%s: %02u%% zon; %02u%% %5smm neerslag; %5sC - %5sC; wind: %-2s %s\n", $day,
          @{ $data{$day} }{ 'zon', 'neerslagk', 'neerslagh', 'min_temp', 'max_temp', 'wind_ri', 'wind_kr' };
    }
} else {
    print "Pagina niet gevonden\n";
}
