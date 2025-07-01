use strict;
use warnings;

use Math::MPFR qw(:mpfr);

use Test::More;

if(MPFR_VERSION >= 262912) { # MPFR-4.3.0 or later
  if(Math::MPFR::_have_bfloat16()) {
    cmp_ok(Rmpfr_buildopt_bfloat16_p(),  '==', 1, "MPFR library supports __bf16");
    cmp_ok(Math::MPFR::_have_bfloat16(), '==', 1, "bfloat16 support is available && utilised");

    my $op = sqrt(Math::MPFR->new(2));
    my $nv = Rmpfr_get_bfloat16($op, MPFR_RNDN);
    cmp_ok($op, '!=', $nv, "values no longer match");

    my $op16 = Rmpfr_init2(8); # bfloat16 has 8 bits of precision.
    Rmpfr_set_ui($op16, 2, MPFR_RNDN);
    Rmpfr_sqrt($op16, $op16, MPFR_RNDN);

    cmp_ok($nv, '==', $op16, "values match");
  }
  else {
    cmp_ok(Math::MPFR::_have_bfloat16(), '==', 0, "MPFR library support for bfloat16 is not utilised");
  }
}
else {
  cmp_ok(Rmpfr_buildopt_bfloat16_p(), '==', 0, "Rmpfr_buildopt_bfloat16_p() returns 0");
  cmp_ok(Math::MPFR::_have_bfloat16(), '==', 0, "bfloat16 support is lacking");
}

done_testing();
