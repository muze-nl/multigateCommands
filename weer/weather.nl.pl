#!/usr/bin/perl -w

# Copyright (C) 1998 Thomas van Gulick
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# 1998 May 20
#       - Actually nothing has changed to this script when it was ported to
#         New Eru!
# 2000 June 20
#       - Major changes in program, doesn't look like the old
#         one.

use strict;

my $html      = `lynx -dump http://www.knmi.nl/voorl/weer/weermain.html`;
my $weerstart = index( $html, "Het weer:" );
my $weerend   = index( $html, "Waarschuwingen:" );
my $rest1     = substr( $html, $weerstart + 9, $weerend - 13 );
$rest1 =~ s/\s{2,5}/ /g;
$rest1 =~ /.*?uur\.(.*)/;
my $rest2 = $1;

#print $rest2;
$rest2 =~ s/\n+/ /g;
$rest2 =~ s/^\s+//;    #remove leading spaces
print $rest2;
