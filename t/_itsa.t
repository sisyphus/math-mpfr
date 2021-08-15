
# In assigning values we look at the flags of the
# given argument. Here we simply check that the flags
# of that argument will be as expected.

use strict;
use warnings;
use Math::MPFR;

use Test::More;

my $uv_max = ~0;

my $uv = $uv_max;
cmp_ok(Math::MPFR::_itsa($uv),      '==', 1, "\$uv is UV");
my $uv_copy = $uv;
my $uv_x = "$uv";
cmp_ok(Math::MPFR::_itsa($uv),      '==', 1, "\$uv is still UV");
$uv_x -= 2;
cmp_ok(Math::MPFR::_itsa($uv_x),    '==', 1, "\$uv_x is also UV");
cmp_ok(Math::MPFR::_itsa($uv_copy), '==', 1, "\$uv_copy is UV");

my $iv = -23;
cmp_ok(Math::MPFR::_itsa($iv),      '==', 2, "\$iv is IV");
my $iv_copy = $iv;
my $iv_x = "$iv";
cmp_ok(Math::MPFR::_itsa($iv),      '==', 2, "\$iv is still IV");
$iv_x -= 2;
cmp_ok(Math::MPFR::_itsa($iv_x),    '==', 2, "\$iv_x is also IV");
cmp_ok(Math::MPFR::_itsa($iv_copy), '==', 2, "\$iv_copy is IV");

my $pv1 = "$uv_max";
cmp_ok(Math::MPFR::_itsa($pv1),     '==', 4, "\$pv1 is PV");
$pv1 -= 1;
cmp_ok(Math::MPFR::_itsa($pv1),     '==', 1, "\$pv1 is now UV");
$pv1 >>= 1;
cmp_ok(Math::MPFR::_itsa($pv1),     '==', 2, "$pv1 is IV");

my $pv2 = "2.3";
cmp_ok(Math::MPFR::_itsa($pv2),     '==', 4, "\$pv2 is PV");
$pv2 -= 1;
cmp_ok(Math::MPFR::_itsa($pv2),     '==', 3, "\$pv2 is now NV");

my $nv = 1.2e-11;
cmp_ok(Math::MPFR::_itsa($nv),      '==', 3, "\$nv is NV");
my $nv_copy = $nv;
my $nv_x = "$nv";
cmp_ok(Math::MPFR::_itsa($nv),      '==', 3, "\$nv is still NV");
$nv -= 2;
cmp_ok(Math::MPFR::_itsa($nv),      '==', 3, "$nv is also NV");
cmp_ok(Math::MPFR::_itsa($nv_copy), '==', 3, "\$nv_copy is NV");

my $pv3 = '987654' x 100;
cmp_ok(Math::MPFR::_itsa($pv3),     '==', 4, "\$pv3 is PV");
cmp_ok($pv3, '>=', 0, "\$pv3 >= 0"); # NOK flag is now set, but we want
                                     # to use the value in the PV slot

cmp_ok(Math::MPFR::_itsa($pv3),     '==', 4, "\$pv3 is still PV");
cmp_ok($pv3, 'eq', '987654' x 100, "\$pv3 PV slot is unchanged");

done_testing();
