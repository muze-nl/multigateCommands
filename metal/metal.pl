#!/usr/bin/perl -w
#metal zooi van jaqcues 

open METAL , "<metal.txt" or die ("unable to open file: $!");
my @einde = <METAL>;
close METAL;


print "Een beeldschone prinses zit gevangen in een kasteel dat door een afschuwelijke draak bewaakt wordt.\n";
print $einde[int rand(@einde)], "\n";


