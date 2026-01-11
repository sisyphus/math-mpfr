# Testing of Rmpfr_fpif_export_mem() and Rmpfr_fpif_import_mem
# which were added mpfr-4.3.0.
# Testing of Rmpfr_fpif_export() and Rmpfr_fpif_import(), which
# were added in mpfr-4.0.0, is performed in new_in_4.0.0.t

use strict;
use warnings;

use Math::MPFR qw(:mpfr);

use Test::More;

my $len = 16;
my $string = chr() x $len;

my $op = Rmpfr_init2(100);   # 100-bit precision;

my $rop = Math::MPFR->new(); # 53-bit precision

Rmpfr_const_pi($op, MPFR_RNDN);

if(262912 > MPFR_VERSION) {
  eval { my $ret = Rmpfr_fpif_export_mem($string, $len, $op);};
  like($@, qr/^Rmpfr_fpif_export_mem not implemented/, "Test 1 ok");

  eval{ my $ret = Rmpfr_fpif_import_mem($rop, $string, $len);};
  like($@, qr/^Rmpfr_fpif_import_mem not implemented/, "Test 2 ok");
}
else {
  my $ret = Rmpfr_fpif_export_mem($string, $len, $op);
  cmp_ok($ret, '==', 0, "Test 1 export ok");

  $ret = Rmpfr_fpif_import_mem($rop, $string, $len);
  cmp_ok($ret, '==', 0, "Test 2 import ok");

  cmp_ok(ref($rop), 'eq', 'Math::MPFR', "Test 3 import returned a Math::MPFR object");
  cmp_ok(Rmpfr_get_prec($rop), '==', 100, "Test 4 precision altered to 100");
  cmp_ok($rop, '==', $rop, "Test 5 value survived round trip");
}

done_testing();

