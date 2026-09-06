# Basic testing of Rmpfr_rootn_ui and Rmpfr_rootn_si.
use strict;
use warnings;
use Math::MPFR qw(:mpfr);

use Test::More;

if(4 > MPFR_VERSION_MAJOR) {
  my $rop = Math::MPFR->new();

  eval {Rmpfr_rootn_ui($rop, Math::MPFR->new(3), 7, MPFR_RNDN);};
  like($@, qr/Rmpfr_rootn_ui not implemented/, 'Rmpfr_rootn_ui not implemented');

  eval {Rmpfr_rootn_si($rop, Math::MPFR->new(3), 7, MPFR_RNDN);};
  like($@, qr/Rmpfr_rootn_si not implemented/, 'Rmpfr_rootn_si not implemented');

  done_testing();
  exit 0;
}

my $rop1 = Math::MPFR->new();
my $rop2 = Math::MPFR->new();
my $op = Math::MPFR->new(10);

Rmpfr_rootn_ui($rop1, $op, 0, MPFR_RNDN);

cmp_ok(Rmpfr_nan_p($rop1), '!=', 0, '0th root of 10 is NaN');

my $inex1 = Rmpfr_rootn_ui($rop1, $op, 3, MPFR_RNDN);
my $inex2 = Rmpfr_cbrt($rop2, $op, MPFR_RNDN);

cmp_ok($inex1 * $inex2, '>', 0, '$inex1 * $inex2 > 0');
cmp_ok($rop1, '==', $rop2, '$rop1 == $rop2');

unless(RMPFR_VERSION_NUM(4,3,0) > MPFR_VERSION)  {
  my $inex3 = Rmpfr_rootn_si($rop2, $op, 3, MPFR_RNDN);
  cmp_ok($inex3 * $inex2, '>', 0, '$inex3 * $inex2 > 0');
  cmp_ok($rop2, '==', $rop1, '$rop2 == $rop1');
}
else {
  eval {Rmpfr_rootn_si($rop1, Math::MPFR->new(3), 7, MPFR_RNDN);};
  like($@, qr/Rmpfr_rootn_si not implemented/, 'Rmpfr_rootn_si not implemented');
}

done_testing();

