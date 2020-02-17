
use strict;
use warnings;
use Config;

use Math::MPFR qw(:mpfr);

use Test::More tests => 4;

if($Config{ivsize} == 8) {
  cmp_ok( numtoa(~0), 'eq', '18446744073709551615', 'handles UVs correctly' );
}
else {
  cmp_ok( numtoa(~0), 'eq', '4294967295', 'handles UVs correctly' );
}

cmp_ok( numtoa(-17), 'eq', '-17', 'handles IVs correctly' );

cmp_ok( numtoa(0.1 / 10), 'eq', '0.01', 'handles NVs correctly' );

eval { numtoa('hello world'); };

like ( $@, qr/Not a numeric argument given to numtoa function/, 'dies correctly' );
