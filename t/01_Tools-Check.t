### Tools::Check test suite ###

use strict;
use lib '../lib';
use Test::More tests => 15;

### case 1 ###
use_ok( 'Tools::Check' ) or diag "Check.pm not found.  Dying", die;

### make sure it's verbose, good for debugging ###
#$Tools::Check::VERBOSE = 1;

my $tmpl = {
    firstname   => { required   => 1, },
    lastname    => { required   => 1, },
    gender      => { required   => 1,
                     allow      => [qr/M/i, qr/F/i],
                },
    married     => { allow      => [0,1] },
    age         => { default    => 21,
                     allow      => qr/^\d+$/,
                },
    id_list     => { default    => [],
                    strict_type => 1
                },
    phone       => { allow      => sub {
                                    my %args = @_;
                                    return 1 if &valid_phone( $args{phone} );
                                }
                },
    bureau      => { default    => 'NSA',
                    no_override => 1
                },
};

my $standard = {
    firstname   => 'joe',
    lastname    => 'jackson',
    gender      => 'M',
};

my $default = {
    lastname    => 'jackson',
    firstname   => 'joe',
    married     => undef,
    gender      => 'M',
    id_list     => [],
    phone       => undef,
    age         => 21,
    bureau      => 'NSA',
};

sub valid_phone {
    my $num = shift;

    ### dutch phone numbers are 10 digits ###
    $num =~ s/[\s-]//g;

    return $num =~ /^\d{10}$/ ? 1 : 0;
}

### aliasing Tools::Check::check to check() ###
*check = *Tools::Check::check;


{
    my $hash = {%$standard};

    my $args = check( $tmpl, $hash );

    is_deeply($args, $default, "Just the defaults");
}

{
    my $hash = {%$standard};
    delete $hash->{gender};

    my $args = check( $tmpl, $hash );

    is($args, undef, "Missing required field");
}

{
    my $hash = {%$standard};
    $hash->{nonexistant} = 1;

    my $args = check( $tmpl, $hash );

    is_deeply($args, $default, q[Non-mentioned key keys are ignored]);
}

{
    my $hash = {%$standard};
    $hash->{ID_LIST} = [qw|a b c|];

    my $args = check( $tmpl, $hash );

    is_deeply($args->{id_list}, $hash->{ID_LIST}, q[Setting non-required field]);
}

{
    my $hash = {%$standard};
    $hash->{ID_LIST} = {};

    my $args = check( $tmpl, $hash );

    is($args, undef, q[Enforcing strict type]);
}

{
    my $hash = {%$standard};
    $hash->{bureau} = 'FBI';

    my $args = check( $tmpl, $hash );

    is( $args->{bureau}, $default->{bureau},
        q[Can not change keys marked with 'no_override']
    );
}

{
    my $hash = {%$standard};
    $hash->{phone} = '010 - 1234567';

    my $args = check( $tmpl, $hash );

    is_deeply($args->{phone}, $hash->{phone}, q[Allowing based on subroutine]);
}

{
    my $hash = {%$standard};
    $hash->{phone} = '010 - 123456789';

    my $args = check( $tmpl, $hash );

    is($args, undef, q[Disallowing based on subroutine]);
}

{
    my $hash = {%$standard};
    $hash->{age} = '23';

    my $args = check( $tmpl, $hash );

    is($args->{age}, $hash->{age}, q[Allowing based on regex]);
}

{
    my $hash = {%$standard};
    $hash->{age} = 'fifty';

    my $args = check( $tmpl, $hash );

    is($args, undef, q[Disallowing based on regex]);
}

{
    my $hash = {%$standard};
    $hash->{married} = 1;

    my $args = check( $tmpl, $hash );

    is($args->{married}, $hash->{married}, q[Allowing based on a list]);
}

{
    my $hash = {%$standard};
    $hash->{married} = 2;

    my $args = check( $tmpl, $hash );

    is($args, undef, q[Disallowing based on a list]);
}

{
    my $hash = {%$standard};
    $hash->{gender} = 'm';

    my $args = check( $tmpl, $hash );

    is($args->{gender}, $hash->{gender}, q[Allowing based on list of regexes]);
}

{
    my $hash = {%$standard};
    $hash->{gender} = 'K';

    my $args = check( $tmpl, $hash );

    is($args, undef, q[Disallowing based on list of regexes]);
}