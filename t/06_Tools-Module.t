### Tools::Module test suite ###

use strict;
use lib qw[../lib t/to_load];
use File::Spec ();

use Test::More tests => 11;

### case 1 ###
use_ok( 'Tools::Module' ) or diag "Module.pm not found.  Dying", die;

### make sure it's verbose, good for debugging ###
$Tools::Module::VERBOSE = 0;

*can_load       = *Tools::Module::can_load;
*check_install  = *Tools::Module::check_install;
*requires       = *Tools::Module::requires;

{
    my $rv = check_install(
                        module  => 'Tools::Module',
                        version => $Tools::Module::VERSION,
                );

    ok( $rv->{uptodate},                            q[Verify self] );
    ok( $rv->{version} == $Tools::Module::VERSION,  q[Found proper version] );

    ok( $INC{'Tools/Module.pm'} eq
        File::Spec::Unix->catfile(File::Spec->splitdir($rv->{file}) ),
        q[Found proper file]
    );

}

{
    my $rv = check_install(
                        module  => 'Tools::Module',
                        version => $Tools::Module::VERSION + 1,
                );

    ok( !$rv->{uptodate} && $rv->{version} && $rv->{file},
        q[Verify out of date module]
    );
}

{
    my $rv = check_install( module  => 'Tools::Module' );

    ok( $rv->{uptodate} && $rv->{version} && $rv->{file},
        q[Verify any module]
    );
}

{
    my $rv = check_install( module  => 'Tools::Does::Not::Exist' );

    ok( !$rv->{uptodate} && !$rv->{version} && !$rv->{file},
        q[Verify non-existant module]
    );

}


### test 'can_load' ###

{
    my $use_list = { 'LoadIt' => 1 };
    my $bool = can_load( modules => $use_list );

    ok( $bool, q[Load simple module] );
}

{
    my $use_list = { 'Must::Be::Loaded' => 1 };
    my $bool = can_load( modules => $use_list );

    ok( !$bool, q[Detect out of date module] );
}

{
    delete $INC{'LoadIt.pm'};
    delete $INC{'Must/Be/Loaded.pm'};

    my $use_list = { 'LoadIt' => 1, 'Must::Be::Loaded' => 1 };
    my $bool = can_load( modules => $use_list );

    ok( !$INC{'LoadIt.pm'} && !$INC{'Must/Be/Loaded.pm'},
        q[Do not load if one prerequisite fails]
    );
}


### test 'requires' ###

{   my %list = map { $_ => 1 } requires('Config');

    my $flag;
    $flag++ unless delete $list{'Exporter'};

    ok( !(keys %list) && !$flag, q[Detecting requirements] );
}