#!/usr/bin/perl -w

# GoogleSearch.pl
# 11apr2002 - matt@interconnected.org http://interconnected.org/home/
# Demonstrates use of the doGoogleSearch method on the Google API.
# See http://www.google.com/apis/ to get your key and download the WSDL
#(which this script expects to find in its directory).

use strict;
use HTML::Entities();
use lib '../../lib/';
use SOAP::Lite;

# Configuration
my $key   = "3xMMU35wtVSsVOWll+jsV6X/qAOgATde";    # <-- PUT YOUR KEY HERE
my $query = $ARGV[0] || "google api";              # either type on the command line,
                                                   # or it defaults to 'google api'

# Redefine how the default deserializer handles booleans.
# Workaround because the 1999 schema implementation incorrectly doesn't
# accept "true" and "false" for boolean values.
# See http://groups.yahoo.com/group/soaplite/message/895
*SOAP::XMLSchema1999::Deserializer::as_boolean = *SOAP::XMLSchemaSOAP1_1::Deserializer::as_boolean =
  \&SOAP::XMLSchema2001::Deserializer::as_boolean;

# Initialise with local SOAP::Lite file
my $service = SOAP::Lite->service('file:./GoogleSearch.wsdl');

my $result = $service->doGoogleSearch(
    $key,        # key
    $query,      # search query
    0,           # start results
    1,           # max results
    "false",     # filter: boolean
    "",          # restrict (string)
    "false",     # safeSearch: boolean
    "",          # lr
    "latin1",    # ie
    "latin1"     # oe
);

# $result is hash of the return structure. Each result is an element in the
# array keyed by 'resultElements'. See the WSDL for more details. 

if ( defined( $result->{resultElements} ) ) {

    #my $count = $result->{estimatedTotalResultsCount};
    #my $time =  $result->{searchTime}; 
    my $title = $result->{resultElements}->[0]->{title};
    my $url   = $result->{resultElements}->[0]->{URL};

    #print STDERR "$title\n";
    if ($title) {
        $title =~ s/&lt;.*?&gt;//g;
        $title =~ s/<.*?>//g;
        $title =~ s/&\w+;//g;
    }
    if ( defined $url ) {
        $title = HTML::Entities::decode($title);
        print "$url  [$title]\n";

        #(total: $count searchtime: $time)\n";
    } else {
        print "No results";
    }
}

# nb:
# - The two booleans in the search above must be "false" or "true" (not 1 or
#   0). Previously this script used 'SOAP::Data->type(boolean => "false")'
#   which came out as '0' in the SOAP message, but wasn't understood by the
#   Google interface.
# - I understand that the Schema definition workaround above isn't needed if
#   you're using SOAP::Lite 0.52 or above. I've been using 0.51.
