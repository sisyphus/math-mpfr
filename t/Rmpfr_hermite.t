# Just some basic tests .... enough to verify that
# Rmpfr_hermite correctly wraps mpfr_hermite.

use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Test::More;

my ($inex, $degree) = (1, 0);
my $rop = Math::MPFR->new(0);
my $op  = Math::MPFR->new(0);

if(RMPFR_VERSION_NUM(4,3,0) > MPFR_VERSION) {
  eval { $inex = Rmpfr_hermite($rop, $degree, $op, MPFR_RNDN);};
  like($@, qr/^Rmpfr_hermite not implemented \- need at least mpfr\-4\.3\.0/, '$@ set as expected');
  done_testing();
  exit 0;
}

eval{ $inex = Rmpfr_hermite($rop, -1, $op, MPFR_RNDN);};
like($@, qr/^Second arg given to Rmpfr_hermite must be >= 0/, 'Negative degree is not permitted');

for my $nv(-1.001, -1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0, 1.001) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_hermite($rop, $degree, $op, MPFR_RNDN);
  cmp_ok($rop,  '==', 1, "Degree: $degree rop  == 1");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

$degree = 1;

for my $nv(-1.001, -1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0, 1.001) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_hermite($rop, $degree, $op, MPFR_RNDN);
  cmp_ok($rop,  '==', $op * 2, "Degree: $degree rop  == op * 2");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

$degree = 2;

for my $nv(-1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_hermite($rop, $degree, $op, MPFR_RNDN);
  my $check = (4 * ($op ** 2)) - 2;
  cmp_ok($rop,  '==', $check, "Degree: $degree rop  == check");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

$degree = 3;

for my $nv(-1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_hermite($rop, $degree, $op, MPFR_RNDN);
  my $check = (8 * ($op ** 3)) - (12 * $op);
  cmp_ok($rop,  '==', $check, "Degree: $degree rop  == check");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

$degree = 4;

for my $nv(-1.0, -0.75, -0.5, -0.25, 0.0, 0.25, 0.5, 0.75, 1.0) {
  Rmpfr_set_NV($op, $nv, MPFR_RNDN);
  $inex = Rmpfr_hermite($rop, $degree, $op, MPFR_RNDN);
  my $check = (16 * ($op ** 4)) - (48 * ($op ** 2)) + 12;
  cmp_ok($rop,  '==', $check, "Degree: $degree rop  == check");
  cmp_ok($inex, '==', 0, "Degree: $degree inex == 0");
}

done_testing();
