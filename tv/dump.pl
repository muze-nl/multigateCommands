#!/usr/bin/perl -w
# Script om tvgids voor vandaag naar file te schrijven
# Geschreven in het kader van DND Progathon 2000
# 16 Januari 2000
# Casper Joost Eyckelhof (Titanhead)
# casper@joost.student.utwente.nl

#2 december 2001, omgeschreven voor gebruik op rtl.nl

#26-28 Juni 2001, constante veranderingen omdat veronica dagelijks de
#beveiliging aanpast: gebruik van proxies, fake headers, etc

use LWP::UserAgent;
use HTTP::Cookies;

$ua         = new LWP::UserAgent;
$cookie_jar = HTTP::Cookies->new;

# fisher_yates_shuffle( \@array ) : generate a random permutation
# of @array in place
sub fisher_yates_shuffle {
    my $array = shift;
    my $i;
    for ( $i = @$array ; --$i ; ) {
        my $j = int rand( $i + 1 );
        next if $i == $j;
        @$array[ $i, $j ] = @$array[ $j, $i ];
    }
}


sub bytvtime {
  my $au = 0;
  my $am = 0;
  my $bu = 0;
  my $bm = 0;
  
  if ( $a =~/^(\d+)\.(\d+).*$/ ) {
     ($au, $am) = ($1, $2);
  }
  if ( $b =~/^(\d+)\.(\d+).*$/ ) {
     ($bu, $bm) = ($1, $2);
  }
  
  $au += 24 if ($au < 6);
  $bu += 24 if ($bu < 6);         

  # The actual compare:

  $au <=> $bu or
  $am <=> $bm;

}

#### allerlei fijne definities en initialisaties ########
$datadir = "/home/multilink/multigate/commands/tv/data/";

@agents = (
    "Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)",
    "Mozilla/4.0 (compatible; MSIE 5.5; Windows NT 5.0)",
    "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0)",
    "Mozilla/4.0 (compatible; MSIE 5.0; Windows 95) Opera 6.01  [en]",
    "Mozilla/5.0 (X11; U; IRIX IP32; en-US; rv:1.0.0) Gecko/20020606"
);

$agent = @agents[ int( rand(@agents) ) ];
$ua->agent($agent);

#random delay voor start: 0-10 minuten 

#sleep( int( rand(600) ) );

%zenders = (
    1  => "Nederland1",
    2  => "Nederland2",
    3  => "Nederland3",
    4  => "RTL4",
    31 => "RTL5",
    46 => "RTL7",
    34 => "Veronica",
    36 => "SBS6",
    37 => "Net5",
    5  => "VRT_TV1",
    6  => "Ketnet_Canvas",
    7  => "BBC1",
    8  => "BBC2",

    #	18 => "NGC",
    #	19 => "Eurosport",
    #	9 => "ARD",
    #	10 => "ZDF",
    #	11 => "RTLTelevision",
    #	12 => "WDR",
    #	13 => "N3",
    #	14 => "Sudwest3",
    #	15 => "La_Une",
    #	16 => "La_Deux",
    #	17 => "TV_5",
    #	20 => "TCM",
    #	21 => "CartoonNetwork",
    #	22 => "Kindernet",
    	25 => "MTV",
    #	26 => "CNN",
    #	27 => "RAIUNO",
    #	28 => "Sat1",
    29 => "Discovery",

    #	32 => "TRTInt",
    #	35 => "TMF"
    #	40 => "AT5",
    #	49 => "VTM",
    #	50 => "3sat",
    #	58 => "Pro7",
    #	59 => "Kanaal2",
    #   60 => "VT4",
    #	65 => "Animal",
    #	86 => "BBCworld",
    #	87 => "TVE",
    #	90 => "BVN-TV",
    #	24 => "Canal+1",
    #	39 => "Canal+2",
    #   89 => "Nickelodeon"
);

$base_url = "http://www.rtl.nl/active/tvview/index.xml?station=1&zender=";

#Get my first cookie!
$request = new HTTP::Request( 'GET', "http://www.rtl.nl/active/tvview/index.xml" );
$request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
$request->header( "Accept-Encoding" => "gzip" );
$request->header( "Accept-Language" => "en" );
$request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );
$response = $ua->request($request);
$cookie_jar->extract_cookies($response);

#print STDERR "Cookie: ". $cookie_jar->as_string();

@zenderrij = keys %zenders;

fisher_yates_shuffle( \@zenderrij );

### alle zenders voor vandaag ophalen en wegschrijven ###
foreach $zender (@zenderrij) {
    my $zenderfile = $datadir . $zenders{$zender};

    #Alleen als de zenderfile nog niet bestaat of 0 groot is: 
    if ( ( !-e $zenderfile ) || ( -z $zenderfile ) ) {

        #Een korte random slaap, om het op echt klikgedrag te laten lijken
        sleep( int( rand(60) ) + 30 );

        #Haal pagina voor zender op
        $request = new HTTP::Request( 'GET', $base_url . $zender . "&dag=1" );
        $request->referer("http://www.rtl.nl/active/tvview/index.xml");
        $request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
        $request->header( "Accept-Encoding" => "gzip" );
        $request->header( "Accept-Language" => "en" );
        $request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );
        $cookie_jar->add_cookie_header($request);

        #print STDERR "Getting: ". $base_url.$zender."&dag=1" ."\n";
        $response = $ua->request($request);
        $content  = $response->content;
        $cookie_jar->extract_cookies($response);

        #print STDERR "Cookie: ". $cookie_jar->as_string() . "\n";
        #print STDERR $content;
        my $teopenen = $datadir . $zenders{$zender};
        open( DATA, "> $teopenen" );

        #print STDERR "$zenders{$zender}\n";
        #Een beetje cleaning
        $content =~ s/&nbsp;//gi;
        $content =~ s/&amp;/&/gi;
        $content =~ s/&(.).*?;/$1/g;
        $content =~ s/<br>\n//sgi;
        $content =~ s/\xA0//g;

#       @items = split /<starttime>(\d{2}:\d{2}).*?<\/starttime>/, $content;
#       @items = split m|<td width="48" bgcolor="#666666" valign="bottom">.*?(\d{1,2}:\d{2}).*?</td>|, $content;
        my $prop1 = 'bgcolor="#666666"';
        my $prop2 = 'valign="bottom"';
        my $prop3 = 'width="48"';
        
        @items = split m@<td (?:$prop1\s?|$prop2\s?|$prop3\s?){3}>.*?(\d{1,2}:\d{2}).*?</td>@, $content;
        
        shift @items;    #eerste item is "header"

        my @outlines;
        while (@items) {
            $beschrijving = "";
            $ltijd        = shift @items;    # eerst een tijd
            $ltijd =~ s/:/./;
            $rest = shift @items;            # alles tot de volgende tijd
            $rest =~ s/\n+/\n/g;             # geen dubbele newlines
            @inhoud = split /\n/, $rest;     # bovenstaande per regel
                                             # er zijn nu 13 regels in @inhoud, waarvan slechts een aantal spannend
            shift @inhoud;                   # eerst een </td>

            $titel = shift @inhoud;          # de regel met de titel erin
                                             #print STDERR "Titel: $titel\n";
            $titel =~ /<b>(.*?)<\/b>/;
            $titel = $1;
            $titel =~ s/<.*?>//g;            #geen URL's in de titel

            $extras = shift @inhoud;         #de symbolen, zoals film, herhaling en teletekst
            if ( $extras =~ /alt="speelfilm"/i ) { $film = "F" }
            else { $film = " " }

            while (@inhoud) {
                $frop = shift @inhoud;
                if ( $frop =~ /colspan="2"/ ) {    #alle regels met colspan=2 bevatten nuttige info
                    $frop =~ s/<.*?>//g;    #html eruit gooien
                    $beschrijving .= "$frop ";
                }

            }

            #print STDERR "$ltijd - $film - $titel - $beschrijving\n";              
            #print DATA join "\xb6", ( $ltijd, $film, $titel, $beschrijving ), "\n";    #wegschrijven naar file
            my $line = join("\xb6", ( $ltijd, $film, $titel, $beschrijving ));
            push @outlines, $line;
        }
        foreach my $line (sort bytvtime @outlines ) {
           print DATA $line , "\n";        
        }
        close DATA;
    }
}
