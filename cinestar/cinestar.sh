#! /bin/sh

lynx -source 'http://www.cinestar.nl/programma1.htm' |
	sed -n 's/^ *<p><span class="Kop">\(.*\)<br>$/\1/w /dev/stdout' |
	sed 's/<[^>]*>//g'
