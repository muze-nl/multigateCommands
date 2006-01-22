#!/usr/bin/perl 
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Cookies;

my $commandline = $ARGV[0];
$commandline = (defined $commandline) ? $commandline : '';

my $type = 'jazz';
if ($commandline =~ /rock/ ) {  #somewhere
  $type = 'rock';
}


my $ua = new LWP::UserAgent;
my $cookie_jar = HTTP::Cookies->new;

#### allerlei fijne definities en initialisaties ########

my @agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);

my $agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);


#Get my first cookie!
my $request = new HTTP::Request( 'GET', "http://www.arrow.nl/javascript/default.js/" );
$request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
$request->header( "Accept-Encoding" => "gzip" );
$request->header( "Accept-Language" => "en" );
$request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );
my $response = $ua->request($request);
$cookie_jar->extract_cookies($response);

my $cookie_string = $cookie_jar->as_string();

my $session;
if ($cookie_string =~ /PHPSESSID=(\w+);/ ) {
  $session = $1;
  #print STDERR "Session: $session\n";
} else {
  print "Problem getting session from server\n";
  exit 0;
}

# $replay contains a variable $type that should be set to 'rock' or 'jazz' by now :)
my $replay = "O%3A8%3A%22stdClass%22%3A1%3A%7Bs%3A5%3A%22_data%22%3Ba%3A6%3A%7Bs%3A1%3A%220%22%3Bi%3A1%3Bs%3A1%3A%221%22%3Bs%3A14%3A%22Handler_Remote%22%3Bs%3A1%3A%222%22%3Ba%3A1%3A%7Bs%3A1%3A%220%22%3Bs%3A11%3A%22getPlaylist%22%3B%7Ds%3A1%3A%223%22%3Ba%3A1%3A%7Bs%3A1%3A%220%22%3Ba%3A1%3A%7Bs%3A1%3A%220%22%3Bs%3A4%3A%22$type%22%3B%7D%7Ds%3A1%3A%224%22%3Bs%3A6%3A%22secret%22%3Bs%3A1%3A%229%22%3Bs%3A10%3A%22javascript%22%3B%7D%7D";

$request = new HTTP::Request( 'POST', "http://www.arrow.nl/services/Gateway.php" );
$request->referer("http://www.arrow.nl/$type/");
$request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
$request->header( "Accept-Encoding" => "gzip" );
$request->header( "Accept-Language" => "en" );
$request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );
$request->content( $replay );

$cookie_jar->add_cookie_header($request);

$response = $ua->request($request);
my $content  = $response->content;

# content is now a serialized PHP-like object
# Example: 
# 1O:14:"handler_remote":5:{s:4:"user";N;s:5:"error";N;s:7:"_mailer";N;s:6:"_crypt";N;s:7:"_loader";O:8:"stdClass":2:{s:12:"serverResult";O:8:"stdClass":1:{s:6:"huidig";O:8:"stdClass":1:{s:7:"artiest";s:49:"Erma Franklin - (take A Little) Piece Of My Heart";}}s:3:"SID";s:32:"f25780e412412834a0ae3f30a55f1398";}}
#
# Interesting part:
# "stdClass":1:{s:7:"artiest";s:49:"Erma Franklin - (take A Little) Piece Of My Heart";}
# Lets just regex it, not parse it :)

$content =~ s/\n/ - /g; #rock uses a newline, jazz uses a -

if ( $content =~ /"stdClass":1:{s:7:"artiest";s:\d+:"(.*?)";}/) {
   my $artist = $1;
   print "Now playing on arrow $type: $artist\n";
} else {
   print "Problem interpreting result from arrow...\n";
   print STDERR $content, "\n";
}
