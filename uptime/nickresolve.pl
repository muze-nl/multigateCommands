#!/usr/bin/perl 

## Function nickresolve
## in : alias to be resolved
## out: nick that it is resolved to
##      which will just be alias if the alias wasn't found

sub nickresolve {

    my ($aliases_db);
    my ($alias);
    my ($nick);
    my ($ADB);
    my ($line);
    my (@aliases);
    my ($index);

    $aliases_db = "/home/multilink/multigate/commands/jarig/aliases.db";

    ## Function arguments ##
    $alias = lc( $_[0] );

    ## Find real nick of this alias. If no nicks are found then nick=alias ##

    $nick = "";
    open( ADB, "< $aliases_db" ) or die "Unable to open aliases.db\n";
    while ( ( $line = <ADB> ) && ( $nick eq "" ) ) {
        if ( $line !~ /^#/ ) {
            @aliases = split ' ', $line;
            $index = 1;
            while ( ( $aliases[$index] ne $alias ) && ( $index < @aliases ) ) {
                $index++;
            }
            if ( $index < @aliases ) {
                $nick = $aliases[0];
            }
        }
    }
    close(ADB);
    if ( $nick eq "" ) { $nick = $alias }

    return $nick;
}
