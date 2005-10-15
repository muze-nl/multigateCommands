#!/usr/bin/perl -w

# Een keer gemaakt door iemand.
#
# 31-10-2002 - Categorie mee te geven als argument (Jasper van der Neut)

use strict;

my $cat;
if ( @ARGV >= 1 ) {
    my $arg = $ARGV[0];

    if ( $arg =~ /^(editor|browser|lang|os|client)$/i ) {
        $arg =~ tr/a-z/A-Z/;
        $cat = "#" . $arg;
    }
}

my @editors  = qw(vi ultraedit joe emacs MSWord vim edlin);
my @browsers = qw(Mozilla IE5 IE IE6 Netscape Lynx Opera w3m Amaya);
my @langs    = qw(perl python java C C++ VBScript fortran php pascal);
my @OSs      = qw(Windows Windows2000 Linux DOS OS/2 WinXP Win98 Win95 WinNT Debian BeOS RedHat Slackware Suse);
my @clients  = qw (mIRC ircII BitchX irssi GatorChat Word);

my $editor  = $editors[ int( rand(@editors) ) ];
my $browser = $browsers[ int( rand(@browsers) ) ];
my $lang    = $langs[ int( rand(@langs) ) ];
my $os      = $OSs[ int( rand(@OSs) ) ];
my $client  = $clients[ int( rand(@clients) ) ];

open( MSG, "< war.txt" );
my @opties;
if ($cat) {
    @opties = grep( /$cat/, <MSG> );
} else {
    @opties = <MSG>;
}
close MSG;

my $antwoord = $opties[ int( rand(@opties) ) ];
$antwoord =~ s/#EDITOR/$editor/;
$antwoord =~ s/#BROWSER/$browser/;
$antwoord =~ s/#LANG/$lang/;
$antwoord =~ s/#OS/$os/;
$antwoord =~ s/#CLIENT/$client/;

print $antwoord , "\n";
