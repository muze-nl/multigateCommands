#!/usr/bin/perl -w 
use strict;

sub get {
    my @array = @_;
    return $array[ rand(@array) ];
}

my @openers = (
    'It is our business to',         'It is our job to',
    'It is our mission to',          'It\'s our responsibility to',
    'Our challenge is to',           'Our first priority is to',
    'Our goal is to',                'Our mission is to',
    'Our mission is to continue to', 'The customer can count on us to',
    'We',                            'We build trust and teamwork to',
    'We envision to',                'We exist to',
    'We have committed to',          'We strive to',
    'We will'
);
my @adverbs = (
    'appropriately', 'assertively',      'authoritatively', 'collaboratively', 'competently',   'completely',
    'continually',   'conveniently',     'credibly',        'distinctively',   'dramatically',  'dynamically',
    'efficiently',   'enthusiastically', 'globally',        'holisticly',      'interactively', 'intrinsicly',
    'objectively',   'proactively',      'professionally',  'progressively',   'quickly',       'seamlessly',
    'synergistically'
);
my @verbs = (
    'actualize',     'administrate',      'build',             'communicate', 'conceptualize', 'coordinate',
    'create',        'customize',         'develop',           'disseminate', 'empower',       'engineer',
    'enhance',       'facilitate',        'fashion',           'foster',      'impact',        'initiate',
    'integrate',     'leverage existing', 'leverage other\'s', 'maintain',    'negotiate',     'network',
    'parallel task', 'promote',           'provide access to', 'pursue',      're-engineer',   're-invent',
    'restore',       'revolutionize',     'simplify',          'streamline',  'supply',        'utilize'
);
my @adjectives = (
    'accurate',              'adaptive',            'alternative',        'an expanded array of',
    'backward-compatible',   'best of breed',       'business',           'client-based',
    'client-centered',       'client-centric',      'client-focused',     'collaborative',
    'competitive',           'cooperative',         'corporate',          'cost effective',
    'cross functional',      'cross-unit',          'customer directed',  'cutting edge',
    'distinctive',           'diverse',             'economically sound', 'effective',
    'emerging',              'empowered',           'enabled',            'enterprise-wide',
    'equity invested',       'error-free',          'ethical',            'excellent',
    'exceptional',           'flexible',            'fully researched',   'fully tested',
    'functional',            'functionalized',      'future-proof',       'global',
    'go forward',            'goal-oriented',       'high standards in',  'high-payoff',
    'high-quality',          'highly efficient',    'inexpensive',        'innovative',
    'installed base',        'integrated',          'interactive',        'interdependent',
    'interoperable',         'just in time',        'leading-edge',       'leveraged',
    'long-term high-impact', 'low-risk high-yield', 'maintainable',       'market positioning',
    'market-driven',         'market-focused',      'mission-critical',   'multidisciplinary',
    'multifunctional',       'multimedia based',    'optimal',            'orthogonal',
    'parallel',              'performance based',   'premier',            'premium',
    'principle-centered',    'proactive',           'process-centric',    'professional',
    'progressive',           'prospective',         'quality',            'reliable',
    'resource maximizing',   'resource-leveling',   'scalable',           'stand-alone',
    'standards compliant',   'state of the art',    'strategic',          'superior',
    'sustainable',           'tactical',            'team building',      'team driven',
    'technically sound',     'timely',              'top-line',           'turn-key',
    'unique',                'user friendly',       'value-added',        'virtual',
    'world-class',           'worldwide',           'prespecified',       'user-oriented'
);
my @nouns = (
    '"outside the box" thinking',     'action items',
    'alignments',                     'benefits',
    'best practices',                 'catalysts for change',
    'collaboration and idea-sharing', 'content',
    'core competencies',              'customer service',
    'data',                           'deliverables',
    'e-business',                     'expertise',
    'growth strategies',              'human capital',
    'ideas',                          'imperatives',
    'information',                    'infrastructures',
    'initiatives',                    'innovation',
    'intellectual capital',           'internal or "organic" sources',
    'leadership',                     'leadership skills',
    'manufactured products',          'materials',
    'meta-services',                  'methods of empowerment',
    'metrics',                        'niche markets',
    'opportunities',                  'paradigms',
    'potentialities',                 'process improvements',
    'processes',                      'products',
    'quality vectors',                'resources',
    'results',                        'scenarios',
    'services',                       'solutions',
    'sources',                        'strategic theme areas',
    'supply chains',                  'synergy',
    'technology',                     'testing procedures',
    'total linkage',                  'value',
    'Quality of Service targets'
);
my @conjunctions =
  ( 'and', 'and also', 'and continue to', 'as well as to', 'in order that we may', 'in order to', 'so that we may',
    'so that we may endeavor to', 'such that we may continue to', 'to allow us to', 'while continuing to' );
my @closers = (
    'and approach our jobs with passion an commitment',
    'because that is what the customer expects',
    'for 100% customer satisfaction',
    'in order to solve business problems',
    'so that we can deliver the kind of results on the bottom line that our investors expect and deserve',
    'through continuous improvement',
    'thus enhancing the long-term value of the business',
    'to be the best in the world',
    'to delight the customer',
    'to exceed customer expectations',
    'to meet our customer\'s needs',
    'to satisfy our internal and external customers',
    'to set us apart from the competition',
    'to stay competitive in tomorrow\'s world',
    'while adhering to the highest standards of quality',
    'while maintaining the highest standards',
    'while promoting personal employee growth',
    'while striving for technical leadership',
    'with 100% on-time delivery',
    'with zero defects'
);

my $statement = get(@openers) . " " . get(@adverbs) . " " . get(@verbs) . " " . get(@adjectives) . " " . get(@nouns);

for ( my $x = 0 ; $x < 2 ; $x++ ) {
    if ( rand(1) > .5 ) {
        $statement .=
          " " . get(@conjunctions) . " " . get(@adverbs) . " " . get(@verbs) . " " . get(@adjectives) . " " . get(@nouns);
    }
}

$statement .= " " . get(@closers);

print "$statement.\n";

