### Tools::Term test suite ###

use strict;
use lib qw[../lib t/to_load];
use Test::More tests => 7;
use Term::ReadLine;

use_ok( 'Tools::Term' ) or diag "Check.pm not found.  Dying", die;

### make sure we can do this automatically ###
$Tools::Term::AUTOREPLY = 1;
$Tools::Term::VERBOSE = 0;

my $term = Term::ReadLine->new('test')
                or diag "Could not create a new term. Dying", die;

my $tmpl = {
        prompt  => "What is your favourite colour?",
        choices => [qw|blue red green|],
        default => 'blue',
    };

{
    my $args = \%{ $tmpl };

    is( $term->get_reply( %$args ), 'blue', q[Checking reply with defaults and choices] );
}

{
    my $args = \%{ $tmpl };
    delete $args->{choices};

    is( $term->get_reply( %$args ), 'blue', q[Checking reply with defaults] );
}

{
    my $args = {
        prompt  => 'Do you like cookies?',
        default => 'y',
    };

    is( $term->ask_yn( %$args ), 1, q[Asking yes/no with 'yes' as default] );
}

{
    my $args = {
        prompt  => 'Do you like Python?',
        default => 'n',
    };

    is( $term->ask_yn( %$args ), 0, q[Asking yes/no with 'no' as default] );
}

{
    my $str =   q[command --no-foo --baz --bar=0 --quux=bleh ] .
                q[--option="some'thing" -one-dash -single=blah' foo];

    my $munged = 'command foo';
    my $expected = {
            foo         => 0,
            baz         => 1,
            bar         => 0,
            quux        => 'bleh',
            option      => q[some'thing],
            'one-dash'  => 1,
            single      => q[blah'],
    };

    my ($href,$rest) = $term->parse_options( $str );

    is_deeply( $href, $expected, q[Parsing options] );
    is($rest,$munged, q[Remaining unparsed string] );
}