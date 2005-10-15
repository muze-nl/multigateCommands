#!/usr/bin/perl -w
use strict;

## Import available environment variables

my $user      = $ENV{'MULTI_REALUSER'};     # multigate username of invoking user
my $userlevel = $ENV{'MULTI_USERLEVEL'};    # userlevel of invoking user

my $commandline = defined $ARGV[0] ? $ARGV[0] : '';

my $id;    #last used id

#First time user? Init files

unless ( -d "data/$user" ) {
    mkdir "data/$user", 0755 or die "cannot mkdir data/$user";    #new entry
    open IDFILE, "> data/$user/id";
    print IDFILE "0";
    close IDFILE;
}

#Get id

open IDFILE, "< data/$user/id";
$id = <IDFILE>;
close IDFILE;
chomp $id;

if ( $commandline =~ /^add (.*?)$/i ) {
    $id++;
    open ITEM, ">data/$user/$id";
    print ITEM $1;
    close ITEM;

    open IDFILE, "> data/$user/id";
    print IDFILE $id;
    close IDFILE;
    print "todo item toegevoegd als nummer $id\n";

} elsif ( $commandline =~ /^del (.*?)$/i ) {
    my $toremove = $1;
    if ( $toremove =~ /^\d+$/ ) {
        if ( -e "data/$user/$toremove" ) {
            open ITEM, "< data/$user/$toremove";
            my $item = <ITEM>;
            close ITEM;
            unlink "data/$user/$toremove";
            chomp $item;
            print "todo item $toremove verwijderd: $item\n";
        } else {
            print "Dat nummer staat niet in je todolist\n";
        }
    } else {
        print "Welk nummer?\n";
    }
} else {
    my %todo = ();    #id => item
    opendir( DIR, "data/$user" ) or die "can't opendir data/$user: $!";
    while ( defined( my $file = readdir(DIR) ) ) {
        if ( $file =~ /\d+/ ) {
            open ITEM, "< data/$user/$file";
            my $item = <ITEM>;
            close ITEM;
            $todo{$file} = $item;
        }
    }
    closedir(DIR);
    my %odot = reverse %todo;
    if ( keys %todo ) {
        print "todo items voor $user:\n";
        foreach my $item ( sort keys %odot ) {
            print $odot{$item}, " $item\n";
        }
    } else {
        print "Geen todo items voor $user\n";
    }
}
