### Tools::Log::Config test suite ###

use strict;
use lib qw[../lib t/to_load];
use Test::More tests => 6;
use File::Spec;

use_ok( 'Tools::Log::Config'    ) or diag "Config.pm not found.  Dying", die;
use_ok( 'Tools::Log'            ) or diag "Module.pm not found.  Dying", die;

{
    my $default = {
        private => undef,
        verbose => 1,
        tag     => 'NONE',
        level   => 'log',
        remove  => 0,
        chrono  => 1,
    };

    my $log = Tools::Log->new();

    is_deeply( $default, $log->{CONFIG}, q[Config creation from default] );
}

{
    my $config = {
        private => 1,
        verbose => 1,
        tag     => 'TAG',
        level   => 'carp',
        remove  => 0,
        chrono  => 1,
    };

    my $log = Tools::Log->new( %$config );

    is_deeply( $config, $log->{CONFIG}, q[Config creation from options] );
}

{
    my $file = {
        private => 1,
        verbose => 0,
        tag     => 'SOME TAG',
        level   => 'carp',
        remove  => 1,
        chrono  => 0,
    };

    my $log = Tools::Log->new(
                    config  => File::Spec->catfile(qw|t to_load config_file|)
                );

    is_deeply( $file, $log->{CONFIG}, q[Config creation from file] );
}

{

    my $mixed = {
        private => 1,
        verbose => 0,
        remove  => 1,
        chrono  => 0,
        tag     => 'MIXED',
        level   => 'die',
    };
    my $log = Tools::Log->new(
                    config  => File::Spec->catfile(qw|t to_load config_file|),
                    tag     => 'MIXED',
                    level   => 'die',
                );
    is_deeply( $mixed, $log->{CONFIG}, q[Config creation from file & options] );
}
           