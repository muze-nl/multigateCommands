#!/usr/bin/perl -w
use strict;
use warnings;

use LWP::UserAgent;
use URI::Escape;

## Get a certain URL
my $url = "http://www.westegg.com/cliche/search.cgi?query=";
my $random_url = "http://www.westegg.com/cliche/random.cgi";

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';
$commandline = uri_escape( $commandline );


sub parse {
   my $content = shift; #webpage
   if (defined $content) {
     my @lines = split /<\/?pre>/m , $content;  #header, content, footer
     if (@lines == 3) { 
        my @result = split /\n/, $lines[1];
        @result = grep /\w+/, @result;
        if (@result) { 
          return $result[int rand @result]; 
        }
     }   
   }
   return undef;
}

sub random {
  my $request = new HTTP::Request( 'GET', $random_url );
  my $content = $ua->request($request)->content;
  return parse($content);
}

sub specific {
  my $query = shift;
  uri_escape( $query );
  my $request = new HTTP::Request( 'GET', $url . $query );
  my $content = $ua->request($request)->content;
  return parse($content);
}

if ( $commandline ne '' ) {
   my $result = specific($commandline);
   print defined $result ? $result : random();
} else {
   print random();
}
