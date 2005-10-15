#!/usr/bin/perl

foreach $line (@ARGV) {
    $line =~ s/\s+$//;
    $line =~ s/\s+/   /g;
    $line =~ tr/[A-Z]/[a-z]/;
    $line =~ s/\./\.\-\.\-\.\- /g;
    $line =~ s/\?/\.\.\-\-\.\. /g;
    $line =~ s/\!/\.\-\-\-\-\. /g;
    $line =~ s/a/\.\- /g;
    $line =~ s/b/\-\.\.\. /g;
    $line =~ s/c/\-\.\-\. /g;
    $line =~ s/d/\-\.\. /g;
    $line =~ s/e/\. /g;
    $line =~ s/f/\.\.\-\. /g;
    $line =~ s/g/\-\-\. /g;
    $line =~ s/h/\.\.\.\. /g;
    $line =~ s/i/\.\. /g;
    $line =~ s/j/\.\-\-\- /g;
    $line =~ s/k/\-\.\- /g;
    $line =~ s/l/\.\-\.\. /g;
    $line =~ s/m/\-\- /g;
    $line =~ s/n/\-\. /g;
    $line =~ s/o/\-\-\- /g;
    $line =~ s/p/\.\-\-\. /g;
    $line =~ s/q/\-\-\.\- /g;
    $line =~ s/r/\.\-\. /g;
    $line =~ s/s/\.\.\. /g;
    $line =~ s/t/\- /g;
    $line =~ s/u/\.\.\- /g;
    $line =~ s/v/\.\.\.\- /g;
    $line =~ s/w/\.\-\- /g;
    $line =~ s/x/\-\.\.\- /g;
    $line =~ s/y/\-\.\-\- /g;
    $line =~ s/z/\-\-\.\. /g;
    $line =~ s/0/\-\-\-\-\- /g;
    $line =~ s/1/\.\-\-\-\- /g;
    $line =~ s/2/\.\.\-\-\- /g;
    $line =~ s/3/\.\.\.\-\- /g;
    $line =~ s/4/\.\.\.\.\- /g;
    $line =~ s/5/\.\.\.\.\. /g;
    $line =~ s/6/\-\.\.\.\. /g;
    $line =~ s/7/\-\-\.\.\. /g;
    $line =~ s/8/\-\-\-\.\. /g;
    $line =~ s/9/\-\-\-\-\. /g;
    $line =~ s/\,/\-\-\.\.\-\- /g;
    $line =~ s/@/\.\-\-\.\-\. /g;
    print "$line ";
}

print "\n";

