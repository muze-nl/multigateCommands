#!/usr/bin/perl -w
# Script om tvgids voor vandaag naar file te schrijven
# Geschreven in het kader van DND Progathon 2000
# 16 Januari 2000

#7 april 2006, rtl is nu "web2.0" bah... tvgids.nl eens proberen

#2 december 2001, omgeschreven voor gebruik op rtl.nl

#26-28 Juni 2001, constante veranderingen omdat veronica dagelijks de
#beveiliging aanpast: gebruik van proxies, fake headers, etc

use LWP::UserAgent;
use HTTP::Cookies;

my $fast = 0;
if (lc($ARGV[0]) eq 'fast') {
  $fast = 1;
}

my $ua         = new LWP::UserAgent;
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
$datadir = "./data/";

unless (-e $datadir) {
   print STDERR "No datadir, creating!\n";
   mkdir $datadir;
}

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

sleep( int( rand(600) ) ) unless ($fast);

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
    #	25 => "MTV",
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
    #   89 => "Nickelodeon",
        92 => "Talpa",
);

$base_url = 'http://www.tvgids.nl/zoeken/?trefwoord=Titel+of+trefwoord&dagdeel=0.0&station=';

#Get my first cookie!
$request = new HTTP::Request( 'GET', "http://www.tvgids.nl/" );
$request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
$request->header( "Accept-Language" => "en" );
$request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );
$response = $ua->request($request);
$cookie_jar->extract_cookies($response);

@zenderrij = keys %zenders;

fisher_yates_shuffle( \@zenderrij );

### alle zenders voor vandaag ophalen en wegschrijven ###
foreach $zender (@zenderrij) {
    my $zenderfile = $datadir . $zenders{$zender};

    #Alleen als de zenderfile nog niet bestaat of 0 groot is: 
    if ( ( !-e $zenderfile ) || ( -z $zenderfile ) ) {

        #Een korte random slaap, om het op echt klikgedrag te laten lijken
        sleep( int( rand(60) ) + 30 ) unless ($fast);

        #Haal pagina voor zender op
        $request = new HTTP::Request( 'GET', $base_url . $zender );
        $request->referer("http://www.tvgids.nl/");
        $request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
        $request->header( "Accept-Language" => "en" );
        $request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );
        $cookie_jar->add_cookie_header($request);

        #print STDERR "Getting: ". $base_url.$zender ."\n";
        $response = $ua->request($request);
        $content  = $response->content;
        $cookie_jar->extract_cookies($response);

        my $teopenen = $datadir . $zenders{$zender};
        open( DATA, "> $teopenen" );

        #Een beetje cleaning
        $content =~ s/&nbsp;//gi;
        $content =~ s/&amp;/&/gi;
        $content =~ s/&(.).*?;/$1/g;
        $content =~ s/<br>\n//sgi;
        $content =~ s/\xA0//g;

        
        my @items = split m|(<th width="74">\d{2}:\d{2} - \d{2}:\d{2}</th>)|, $content;
        
        shift @items;    #eerste item is "header"
        pop   @items;    #laatste item is "footer"

        my @outlines;
        while (@items) {
            my ($ltijd, $film, $titel, $beschrijving, $info);

            my $time = shift @items;
            # <th width="74">19:30 - 20:00</th>
            if ($time =~ m|<th width="74">(\d{2}:\d{2}) - (\d{2}:\d{2})</th>|){
               $ltijd = $1;
               $info = shift @items;
               if (defined $info) {
                  my @infolines = split /\n/, $info;
                  chomp @infolines;
                  foreach my $line (@infolines) {
                     # <td width="227"><div><a href="/programmadetail/?ID=5235032">De Kinderpolikliniek</a></div></td>
                     if ($line =~ m|^.*?<td width="227"><div><a href="/programmadetail/\?ID=(\d+)">(.*?)</a></div></td>.*?$|i ){ 
                        my $prog_id = $1;
                        $titel = $2;
                        sleep 1 unless ($fast);
                        ($beschrijving, $film) = get_beschijving($ua, $prog_id);
                        unless (defined $beschrijving) {
                          $beschrijving = $prog_id;
                        }
                        unless (defined $film) {
                          $film = '';
                        }
                        my $line = join("\xb6", ( $ltijd, $film , $titel, $beschrijving ));
                        push @outlines, $line;
                        last;
                     }
                  } 
               }
            }
        }
         foreach my $line (sort bytvtime @outlines ) {
            print DATA $line , "\n";        
         }
        close DATA;
    }
}


sub get_beschijving {
  my ($ua, $id) = @_;

  return undef unless (defined $id and $id =~ /^\d+$/);

  my $url = 'http://www.tvgids.nl/programmadetail/?ID=';

  my $request = new HTTP::Request( 'GET', $url . $id );
  $request->header( "Accept"          => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png" );
  $request->header( "Accept-Language" => "en" );
  $request->header( "Accept-Charset"  => "iso-8859-1,*,utf-8" );
  my $response = $ua->request($request);
  my $content  = $response->content;

  my $result;
  # <table id="progDetail" border="0" cellspacing="0" cellpadding="0">
  if ($content =~ m|^.*?<table id="progDetail" border="0" cellspacing="0" cellpadding="0">(.*?)<p class="meerLinks">.*?$|is){
    my $stuff = $1;
    $stuff =~ s/\n+/ /g;
    $stuff =~ s/\s+/ /g;
    if ($stuff =~ m|^.*?<h3><span>(.*?)</span></h3>.*?<p class="inleiding">(.*?)</p>\s*<p>(.*?)</p>\s*<p>(.*?)</p>.*?$|i){
      my $title = $1;
      my $genre = $2;
      my $vervolg = $3;
      my $omschrijving = $4;

      $result = "$title: $genre $vervolg - $omschrijving";
      $result =~ s/\n//g;
      $result =~ s/\s+/ /g;
    } 
    #controleer of dit een film is...
    # <th>Genre:</th>\s*    <td><div>Film</div></td>
    if ($content =~ m|^.*?<th>Genre:</th>\s*<td><div>Film</div></td>.*?$|is) {
       #print STDERR "FILM: $result\n";
        return ($result , 'F');
    }
    return $result;
  }
  return "Geen beschijving gevonden";
}