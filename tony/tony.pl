#!/usr/bin/perl -w
use strict;

my @insults = (
    "Ju prick",
    "Fuckin' wasp whore",
    "You die, motherfucker",
    "You think you can fuckin' take me? ju fuckin maricon",
    "Don't fuck wit 'me",
    "Ju're all a bunch of fuckin' assholes!",
    "Look at ju now, you piece of shit!",
    "Ju got a bag for a belly!",
    "Anything beats lying around all day waiting for me to fuck you, I'll tell you that!",
    "Fuck'em all!",
    "I bury you cockaroaches!",
    "Your womb is so polluted, I can't even have a fuckin' little baby with ju!",
    "Ju got tits that need a bra, they got hair on 'em!",
    "Ju got a look in your eye like ju haven't been fucked in a year!",
    "Dat piece of shit up right there",
    "I never liked you; I never trusted you.",
    "Ju a piece o' shit",
    "Ju know what I talking about you cockaroach!",
    "Don't toot your horn honey, you're not that good!",
    "Ju fuckface",
    "Ju just fuck jurself!",
    "You know what a hassa is? That's a pig that don't fly straight, and neither do you!",
    "Why don't ju try stickin' ju head up jur ass? See if it fits.",
    "Ju got a fucking junkie for a wife!",
    "This town is like a great big pussy just waiting to get fucked.",
    "Who, why, when, and how I fuck is none of your business.",
    "I'm gonna stick your heads up your asses faster than a rabbit gets fucked!",
    "Do I have to kill your brother first, before I kill you?",
    "Don't fuck me. Don't you ever try to fuck me. Ju Cockroach.",
    "I told you a long fucking time ago not to fuck me, you fucking little monkey",
    "Ja? I take you all to fucking hell!"
);

print $insults[ rand(@insults) ] . "\n";
