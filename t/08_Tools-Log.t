### Tools::Log test suite ###

use strict;
use lib qw[../lib t/to_load];
use Test::More tests => 28;

use_ok( 'Tools::Log'            ) or diag "Module.pm not found.  Dying",    die;
use_ok( 'Tools::Log::Config'    ) or diag "Config.pm not found.  Dying",    die;
use_ok( 'Tools::Log::Item'      ) or diag "Item.pm not found.  Dying",      die;
use_ok( 'Tools::Log::Handlers'  ) or diag "Handlers.pm not found.  Dying",  die;

{
    my $log = Tools::Log->new( private => 0 );
    is( $log->{STACK}, $Tools::Log::STACK, q[Using global stack] );
}

{
    my $log = Tools::Log->new( private => 1 );
    isnt( $log->{STACK}, $Tools::Log::STACK, q[Using private stack] );

    $log->store('foo'); $log->store('bar');

    {
        my @list = $log->retrieve();

        ok( @list == 2, q[Stored 2 messages] );
    }

    $log->store('zot'); $log->store('quux');

    {
        my @list = $log->retrieve( amount => 3 );

        ok( @list == 3, q[Retrieving 3 messages] );
    }

    {
        is( $log->first->message, 'foo',    q[Retrieving first message] );
        is( $log->final->message, 'quux',   q[Retrieving final message] );
    }

    {
        package Tools::Log::Handlers;

        sub test    { return shift }
        sub test2   { shift; return @_ }

        package main;
    }

    $log->store(
            message     => 'baz',
            tag         => 'MY TAG',
            level       => 'test',
    );

    {
        ok( $log->retrieve( message => qr/baz/ ),   q[Retrieving based on message] );
        ok( $log->retrieve( tag     => qr/TAG/ ),   q[Retrieving based on tag] );
        ok( $log->retrieve( level   => qr/test/ ),  q[Retrieving based on level] );
    }

    my $item = $log->retrieve( chrono => 0 );

    {
        ok( $item,                      q[Retrieving item] );
        is( $item->parent,  $log,       q[Item reference to parent] );
        is( $item->message, 'baz',      q[Item message stored] );
        is( $item->id,      4,          q[Item id stored] );
        is( $item->tag,     'MY TAG',   q[Item tag stored] );
        is( $item->level,   'test',     q[Item level stored] );
    }

    {
        like(   $item->shortmess, qr/08_Tools-Log.t\s*(?:at)?\s*line \d+/,
                q[Item shortmess stored]
        );
        like(   $item->longmess, qr/Tools::Log::store/s,
                q[Item longmess stored]
        );

        my $t = scalar localtime;
        $t =~ /\w+ \w+ \d+/;

        like(   $item->when, qr/$1/, q[Item when stored] );
    }

    {
        my $i = $item->test;
        my @a = $item->test2(1,2,3);

        is( $item, $i,              q[Item handler check] );
        is_deeply( $item, $i,       q[Item handler deep check] );
        is_deeply( \@a, [1,2,3],    q[Item extra argument check] );
    }

    {
        ok( $item->remove, q[Removing item from stack] );
        ok( (!grep{ $item eq $_ } $log->retrieve), q[Item removed from stack] );
    }

    {
        $log->flush;
        ok( @{$log->{STACK}} == 0,  q[Flushing stack] );
    }
}
    