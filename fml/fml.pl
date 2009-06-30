#!/usr/bin/perl
#
# fmylife script
# oorspronkelijk gebaseerd op de webtemplate, daarna overgezet naar XML
# Dus er zitten delen van de webtemplate en RSS script enzo in
# misschien moet ie nog een keer iets netter :)
# (c) Rogier van Eeten 2009

use strict;
use XML::Simple;
use LWP::UserAgent;
use HTML::Entities;
use Data::Dumper;

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';
my $url;
if ( $commandline eq "last" ) {
	$url = "http://api.betacie.com/view/last?key=readonly&language=en";
} else {
	unless ( $commandline =~ /^\d+$/ || $commandline eq "random") {
	    print "Give quote ID\n";
	    exit 0;
	}
	$url = "http://api.betacie.com/view//$commandline?key=readonly&language=en";
}


    my $xml = new XML::Simple;
    my $ua  = new LWP::UserAgent;

    #Set agent name, we are not a script! :)
    my $agent = "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)";
    $ua->agent($agent);

    my $request = new HTTP::Request( 'GET', $url );
    my $response = $ua->request($request);
    if ( $response->is_success() ) {
        my $content = $response->content;
	my $data = $xml->XMLin($content);
#	print Dumper($data);
	my $blaat = $data->{'items'}->{'item'};
	my ( $id, $text );
	if ( $commandline eq "last" ) {
		foreach my $frop (
				sort {$b <=> $a} 
				keys %$blaat) {
			$id = $frop;
			$text = $blaat->{$id}->{'text'};
			last;
		}
	} else {
		$id = $blaat->{'id'};
		$text = $blaat->{'text'};
	}
	decode_entities($text);
	print "$text (FML ID: $id)\n";


}
