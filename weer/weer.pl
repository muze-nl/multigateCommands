#!/usr/bin/perl -w
# Yvo Brevoort (Ylebre);
# yvo@brevoort.nl

use LWP::UserAgent;
use HTTP::Cookies;
use Data::Dumper;

my $ua = new LWP::UserAgent;

#### allerlei fijne definities en initialisaties ########

@agents = (
    "Mozilla/4.0 (compatible; MSIE 4.01; Windows 98)", "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)"
);

$agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

$request = new HTTP::Request( 'GET', "ftp://ftp.knmi.nl/pub_weerberichten/basisverwachting.xml" );
$response = $ua->request($request);

if ( $response->is_success() ) {
        my $content = $response->content;
        @blocks = split(/<block>/, $content);
        shift(@blocks);

        my %info;
        while (@blocks) {
                $block = shift(@blocks);
                if ($block =~ /<field_id>(.*?)<\/field_id>/ms) {
                        $id = $1;
                }
                if ($block =~ /<field_content>(.*?)<\/field_content>/ms) {
                        $content = $1;
                        $content =~ s/\n/ /g;
                }
                if ($id && $content) {
                        $info{$id} = $content;
                }
        }
        print $info{'Verwachting'} . "\n";
} else {
        print "Error retrieving data\n";
}
