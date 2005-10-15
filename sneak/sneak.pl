#!/usr/bin/perl

#Het !sneak commando voor #dnd
#(c) Eelco Jepkema, 2000
#socrates@dnd.utwente.nl
#met dank aan Yvo Brevoort voor het swipen van een groot gedeelte van
#de code van het !pizza commando (read: Ik heb zelf bijna nix gecode)

#variabelen aangeven
$nick          = "";
$command       = "";
$nothing       = 0;
$sneak_lijst   = "/home/multilink/multigate/commands/sneak/sneaklijst";
$sneak_vandaag = "/home/multilink/multigate/commands/sneak/sneakvandaag";
$passfile      = "/home/multilink/multigate/commands/sneak/passwd";
$sneakpredict  = "/home/multilink/multigate/commands/sneak/sneakpredict";
$password      = "";
$passgoed      = 0;

#Is er een sneak_lijst?
sub TestOpen {
    if ( -f $sneak_lijst ) {
        return 1;
    }
    return 0;
}

sub TestVandaag {
    if ( -f $sneak_vandaag ) {
        return 1;
    }
    return 0;
}

#nick van persoon filteren

$nick = $ENV{'MULTI_REALUSER'};
if ( $nick eq "pietjepuk" ) {
    $nick = $ENV{'MULTI_USER'};
}

( $command, $args ) = split /\s/, shift @ARGV, 3;

#Commando parsing

SWITCH: {

    if ( $command eq "open" ) {

        #open maakt nieuwe sneaklijst aan..., hiervoor is een password
        #nodig.

        $password = $args;

        if (&TestOpen) {
            print "De sneaklijst is al open.\n";
        } elsif ($password) {
            open( PASS, "> $passfile" );
            print PASS $password;
            close PASS;
            open( SNEAK, "> $sneak_lijst" );
            print SNEAK "Sneaklijst geopend om ", ( scalar localtime ), " door $nick\n";
            print "Sneaklijst geopend\n";
            close SNEAK;
        } else {
            print "sneak open <passwd>";
        }
        last SWITCH;
    }

    if ( $command eq "sluit" ) {

        #sluit de sneaklijst. De sneaklijst wordt hernoemt naar sneakvandaag.
        #ook sluit heeft een password nodig.

        $password = $args;

        open( PASS, $passfile );
        $passgoed = ( <PASS> eq $password );
        close PASS;

        if ( &TestOpen && $passgoed ) {
            close PASS;
            open( SNEAK, ">> $sneak_lijst" );
            print SNEAK "Sneaklijst is gesloten om ", ( scalar localtime ), " door $nick\n";
            close SNEAK;
            unlink $passfile;
            rename $sneak_lijst, $sneak_vandaag;
            print "Sneaklijst nu gesloten.\n";
        } elsif (&TestOpen) {
            print "Incorrect password.\n";
        } else {
            print "Sneaklijst is niet geopend.\n";
        }
        last SWITCH;
    }

    if ( $command eq "add" ) {

        #voeg een nick toe aan de lijst.

        if (&TestOpen) {

            #als er geen verdere argumenten worden meegegeven wordt de
            #nick toegevoegd.

            open( SNEAK, ">> $sneak_lijst" );
            print SNEAK "$nick gaat mee.\n";
            close SNEAK;
            print "Your nick has been added\n";
        } else {
            print "Sneaklijst is niet open.\n";
        }
        last SWITCH;
    }

    if ( $command eq "status" ) {

        #het status commando, print de lijst.

        if (&TestOpen) {
            open( SNEAK, "< $sneak_lijst" );
            print <SNEAK>;
            close SNEAK;
        } elsif (&TestVandaag) {
            print "Sneaklijst is niet open, maar het volgende staat in de database:\n";
            open( VANDAAG, "< $sneak_vandaag" );
            print <VANDAAG>;
            close VANDAAG;
        } else {
            print "You should not see this...maareuh, der is geen database meer.\n";
        }
        last SWITCH;
    }

    if ( $command eq "note" ) {

        #het note commando, post een note..

        if (&TestOpen) {
            open( SNEAK, ">> $sneak_lijst" );
            print SNEAK "$nick noted: $args\n";
            close SNEAK;
            print "your note has been added.\n";
        } else {
            print "Sneaklijst is niet open.\n";
        }
        last SWITCH;
    }

    if ( $command eq "help" ) {

        #help is blijkbaar nodig

        print "Syntax: sneak <command> <args>\n";
        print "Commands: open, sluit, add, note, status,predict, help\n";
        print "open: sneak open <passwd>\n";
        print "sluit: sneak sluit <passwd>\n";
        print "add: sneak add = add je nick op lijst van mensen die meegaan\n";
        print "note: sneak note <args> = als je een note wilt achterlaten (e.g. sneak note fropsel gaat ook mee)\n";
        print "status: sneak status = als je een lijstje wilt krijgen\n";
        print "predict: sneak predict = krijg de laatste predictions\n";
        print "help: sneak help = laat deze helpfile zien\n";
        last SWITCH;
    }

    if ( $command eq "predict" ) {

        #blaat

        open SNEAK, "< $sneakpredict";
        print <SNEAK>;
        close SNEAK;
        last SWITCH;
    }

    # Ik wil nog een command eta, waarbij door de opener aangegeven
    #wordt wanneer er kaartjes gehaald worden, wat dus door eta
    #uitgelezen kan worden.	Gewoon een apart filetje is genoeg lijkt me.

    #zijn er geen argumenten meegegeven, dan volgt een uitleg van het
    #commando

    $nothing = 1;
}

if ( $nothing == 1 ) {
    print "Syntax: sneak <command> <args>\n";
}
