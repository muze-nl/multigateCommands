#!/usr/bin/perl -w
use File::Copy;
use Mail::Mailer;

$error    = 0;
$datadir  = "/home/multilink/multigate/commands/tv/data";
$datadir2 = "/home/multilink/multigate/commands/tv3/data";
@fouten   = "";

opendir( BIN, $datadir ) or die "Can't open $datadir: $!";
while ( defined( $file = readdir BIN ) ) {
    if ( -z "$datadir/$file" ) {
        if ( ( !-e "$datadir2/$file" ) || ( -z "$datadir2/$file" ) ) {
            $error++;
            $fouten .= "$datadir/$file is leeg\n";
        } else {
            copy( "$datadir2/$file", "$datadir/$file" );
        }
    }
}

if ( $error > 0 ) {
    $mailer = Mail::Mailer->new("sendmail");
    $mailer->open(
        {
            From    => 'multilink@ringbreak.dnd.utwente.nl',
            To      => 'casper@joost.student.utwente.nl',
            Subject => 'tvgids'
        }
      )
      or die "Can't open: $!\n";
    print $mailer $fouten;
    $mailer->close();
}
