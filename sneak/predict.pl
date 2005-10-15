#!/usr/bin/perl

use strict;
use LWP::UserAgent;
use HTML::Entities ();

my $ua = new LWP::UserAgent;

#Set agent name, vooral niet laten weten dat we een script zijn
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

# Oude sneaks ophalen

my $request = new HTTP::Request( 'GET', "http://www.sneakpoint.nl/bioscopen.php?id=40" );
my $content = $ua->request($request)->content;
my @html    = split /^/m, $content;
my %oud     = ();
foreach my $regel (@html) {
    if (my @old = ($regel =~ m#<a class="dataTableContent".*?>(.*?)</a>#g) ) {
        foreach my $movie (@old) {
           $oud{ lc($movie) } = 1;
           #print STDERR "Oud: \"". lc($movie)."\"\n"; 
        }   
    }
}

# Predict ophalen

$request = new HTTP::Request( 'GET', "http://www.sneakpoint.nl/" );
$content = $ua->request($request)->content;

##Regel voor regel doorwerken 
@html = split /^/m, $content;

my $result = "";
my $start = 0;
my $found;
foreach my $regel (@html) {
    if ( $regel =~ /<img alt="binnenkortindebios"/i ) {
      $start = 1;
    }
    if ( $start and ( my @new = ($regel =~ m#<a title=".*?" class="filmtitel" href=".*?>(.*?)</a>#g ) )) {
       foreach my $movie (@new) {
          my $predict = lc($movie);
          if ( not exists( $oud{$predict} ) ) {
            $result .= "$predict; ";
            $found++;
          }  
       }
       $start = 0; #all movies on one line...
    }
}
$result =~ s/;.?$//g;

open( OUT, ">/home/multilink/multigate/commands/sneak/sneakpredict" );

if ( $found == 0 ) {
    print OUT "Geen voorspelling helaas";
} else {
    print OUT HTML::Entities::decode(lc($result));
}
close OUT;
exit 0;
