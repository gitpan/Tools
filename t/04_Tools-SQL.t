### Tools::SQL test suite ###

use strict;
use lib qw[../lib t/to_load];
use Test::More tests => 1;

SKIP: {
    eval "use DBI";
    skip "Can not test Tools::SQL since you do not have DBI installed", 1 unless $@;

    use_ok( "Tools::SQL" ) or diag q[Could not load 'Tools::SQL'.  Dying], die;
}        