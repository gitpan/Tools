### Tools::SQL test suite ###

use strict;
use lib qw[../lib t/to_load];
use Test::More tests => 1;

SKIP: {
    skip "Can not test Tools::SQL since you do not have DBI installed", 1
        unless eval "use DBI";

    use_ok( "Tools::SQL" ) or diag q[Could not load 'Tools::SQL'.  Dying], die;
}        