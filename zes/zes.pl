#!/usr/bin/perl -w

my $tijd = `date +%y%m%d`;
chomp($tijd);
print "Er zitten 3 zesen in de klok!\n" if ( $tijd =~ /^060606$/ );
