# Just some basic tests .... enough to verify that
# Rmpfr_legendre correctly wraps mpfr_legendre.

use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Test::More;

my ($inex, $degree);
my $rop = Math::MPFR->new(0);
my $op  = Math::MPFR->new(0);

if(RMPFR_VERSION_NUM(4,3,0) > MPFR_VERSION) {
  eval { $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);};
  like($@, qr/^Rmpfr_legendre not implemented \- need at least mpfr\-4\.3\.0/, '$@ set as expected');
  done_testing();
  exit 0;
}

$degree = 0;

eval{ $inex = Rmpfr_legendre($rop, -1, $op, MPFR_RNDN);};
like($@, qr/^Second arg given to Rmpfr_legendre must be >= 0/, 'Negative degree is not permitted');

for my $nv(-1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  cmp_ok($rop,  '==', 1, "Degree: $degree rop  == 1");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

for my $nv(-1.001, 1.001) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  Rmpfr_clear_nanflag();
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  cmp_ok(Rmpfr_nanflag_p(), '!=', 0, "Degree: $degree nanflag is set");
  cmp_ok(Rmpfr_nan_p($rop), '!=', 0, "Degree: $degree rop is NaN");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

$degree = 1;

for my $nv(-1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  cmp_ok($rop,  '==', $op, "Degree: $degree rop  == op");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

for my $nv(-1.001, 1.001) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  Rmpfr_clear_nanflag();
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  cmp_ok(Rmpfr_nanflag_p(), '!=', 0, "Degree: $degree nanflag is set");
  cmp_ok(Rmpfr_nan_p($rop), '!=', 0, "Degree: $degree rop is NaN");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

$degree = 2;

for my $nv(-1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  my $check = ((3 * ($op ** 2)) - 1) / 2;
  cmp_ok($rop,  '==', $check, "Degree: $degree rop  == check");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

for my $nv(-1.001, 1.001) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  Rmpfr_clear_nanflag();
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  cmp_ok(Rmpfr_nanflag_p(), '!=', 0, "Degree: $degree nanflag is set");
  cmp_ok(Rmpfr_nan_p($rop), '!=', 0, "Degree: $degree rop is NaN");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

$degree = 3;

for my $nv(-1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  my $check = ((5 * ($op ** 3)) - (3 * $op)) / 2;
  cmp_ok($rop,  '==', $check, "Degree: $degree rop  == check");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

for my $nv(-1.001, 1.001) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  Rmpfr_clear_nanflag();
  $inex = Rmpfr_legendre($rop, $degree, $op, MPFR_RNDN);
  cmp_ok(Rmpfr_nanflag_p(), '!=', 0, "Degree: $degree nanflag is set");
  cmp_ok(Rmpfr_nan_p($rop), '!=', 0, "Degree: $degree rop is NaN");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

done_testing();
