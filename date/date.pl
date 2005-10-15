#!/usr/bin/perl -w
$ENV{TZ} = $ARGV[0] if $ARGV[0];
print scalar localtime() . "\n"
