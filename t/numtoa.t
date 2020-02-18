
use strict;
use warnings;
use Config;

use Math::MPFR qw(:mpfr);

use Test::More tests => 6;

if($Config{ivsize} == 8) {
  cmp_ok( numtoa(~0), 'eq', '18446744073709551615', 'handles UV_MAX correctly' );
}
else {
  cmp_ok( numtoa(~0), 'eq', '4294967295', 'handles UV_MAX correctly' );
}

my $uv = ~0 - 100000000;

if($Config{ivsize} == 8) {
  cmp_ok( numtoa($uv), 'eq', '18446744073609551615', 'handles UVs correctly' );
}
else {
  cmp_ok( numtoa($uv), 'eq', '4194967295', 'handles UVs correctly' );
}

my $iv_min = -(~0 >> 1);

if($Config{ivsize} == 8) {
  cmp_ok( numtoa($iv_min), 'eq', '-9223372036854775807', 'handles IV_MIN correctly' );
}
else {
  cmp_ok( numtoa($iv_min), 'eq', '-2147483647', 'handles IV_MIN correctly' );
}

cmp_ok( numtoa(-17), 'eq', '-17', 'handles IVs correctly' );

cmp_ok( numtoa(0.1 / 10), 'eq', '0.01', 'handles NVs correctly' );

eval { numtoa('hello world'); };

like ( $@, qr/Not a numeric argument given to numtoa function/, 'dies correctly' );
