#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use URI::Escape;
use HTTP::Cookies;
use HTML::Entities();

## Import available environment variables

my $address       = $ENV{'MULTI_USER'};            # address of invoking user
my $user          = $ENV{'MULTI_REALUSER'};        # multigate username of invoking user
my $userlevel     = $ENV{'MULTI_USERLEVEL'};       # userlevel of invoking user
my $from_protocol = $ENV{'MULTI_FROM'};            # protocol this command was invoked from
my $to_protocol   = $ENV{'MULTI_TO'};              # protocol where output will be sent
my $command_level = $ENV{'MULTI_COMMANDLEVEL'};    # level needed for this command

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

## Get a certain URL

my $ua = new LWP::UserAgent;

#Set agent name, we are not a script! :)
my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
$ua->agent($agent);

#my $request = new HTTP::Request( 'GET', $url );
#my $content = $ua->request($request)->content;

my $cookie_jar = HTTP::Cookies->new;

my $request = new HTTP::Request( 'GET', "http://babelfish.altavista.com/" );
my $response = $ua->request($request);
$cookie_jar->extract_cookies($response);

my @languages = ( en_fr, en_de, en_it, en_pt, en_es, fr_en, de_en, it_en, pt_en, es_en, de_fr, fr_de, ru_en );

if ( @ARGV < 1 ) {
    print "Syntax: babelfish [from_to] [text to translate]\n";
} else {
    my $text = join " ", @ARGV;
    my $lang;
    ( $lang, $text ) = split /\s/, $text, 2;
    my $goed = 0;
    foreach my $taal (@languages) {
        if ( $taal eq $lang ) { $goed++ }
    }
    if ( $goed == 0 ) {
        print
          "This translation is not supported. Supported translations from_to are: en_fr en_de en_it en_pt en_es fr_en de_en it_en pt_en es_en de_fr fr_de ru_en \n";
    } else {

        ## Argumenten lijken OK, dus nu websitetje ophalen en invullen
        #$text =~ tr/([a-zA-Z0-9\,\:\?\']/ /cs;
        $text =~ tr/\|\`\<\>\;/ /s;

        my $request = new HTTP::Request( 'GET', "http://babelfish.altavista.com/" );
        my $response = $ua->request($request);
        $cookie_jar->extract_cookies($response);
        print $response;
    }

}
