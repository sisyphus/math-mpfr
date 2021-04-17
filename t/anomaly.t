
# Here we check that a somewhat anomalous behaviour that can arise
# when integer strings are involved in overloaded comparisons with
# Math::MPFR objects ('==', '!=', '<', '>', '<=', '>=' and '<=>')
# is as expected.

use strict;
use warnings;
use Math::MPFR;
use Math::GMPz;

use Test::More;

my $f = Math::MPFR->new(2 ** 70); # 1180591620717411303424
my $s = '1180591620717411303423'; # 1 less than 2 ** 70;
my $z = Math::GMPz->new($s);

cmp_ok($f, '==', $s, '2 ** 70 == (2 ** 70) - 1'); # Value of $s is rounded to that of $f
cmp_ok($f, '>',  $z, '2 ** 70 >  (2 ** 70) - 1'); # $s is evaluated to its full (70-bit) precision

done_testing();



