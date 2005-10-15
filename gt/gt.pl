#!/usr/bin/perl -w
use strict;
use LWP::UserAgent;
use URI::Escape;

my %languages = (
    eg => 'en|de',
    es => 'en|es',
    ef => 'en|fr',
    ei => 'en|it',
    ep => 'en|pt',
    ge => 'de|en',
    gf => 'de|fr',
    se => 'es|en',
    sf => 'es|fr',
    fe => 'fr|en',
    fg => 'fr|de',
    fs => 'fr|es',
    ie => 'it|en',
    pe => 'pt|en'
);

if ( @ARGV < 1 ) { print "Syntax: gt [fromto] [text to translate]\n" }
else {
    my $lang;
    my $text = join " ", @ARGV;
    ( $lang, $text ) = split /\s/, $text, 2;
    if ( !defined( $languages{$lang} ) ) {
        print
          "This translation is not supported. Supported translations from->to are: eg, es, ef, ei, ep, ge, gf, se, sf, fe, fg, fs, ie, pe\n";
    } else {

        $text = uri_escape($text);
        $text =~ s/\+/%2B/g;
        $text =~ s/%20/+/g;

        $lang = $languages{$lang};

        my $ua = new LWP::UserAgent;

        #Set agent name, we are not a script! :)
        my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
        $ua->agent($agent);

        my $request =
          new HTTP::Request( 'GET', "http://translate.google.com/translate_t?text=$text&langpair=$lang&hl=en&ie=UTF-8&safe=off" );
        my $content = $ua->request($request)->content;

        my @lines = split /^/m, $content;

        foreach my $line (@lines) {
            if ( $line =~ /textarea name=q rows=5 cols=45 wrap=PHYSICAL>(.*?)<\/textarea>/ ) {
                print $1 , "\n";
                exit 0;
            }
        }
        print "Sorry, translation did not succeed\n";

    }
}
