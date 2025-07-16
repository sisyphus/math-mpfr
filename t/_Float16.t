use strict;
use warnings;

use Math::MPFR qw(:mpfr);

use Test::More;

if(MPFR_VERSION >= 262912) { # MPFR-4.3.0 or later
  if(Math::MPFR::_have_float16()) {
    cmp_ok(Rmpfr_buildopt_float16_p(),  '==', 1, "MPFR library supports _Float16");
    cmp_ok(Math::MPFR::_have_float16(), '==', 1, "_Float16 support is available && utilised");

    my $op = sqrt(Math::MPFR->new(2));
    my $nv = Rmpfr_get_float16($op, MPFR_RNDN);
    cmp_ok($op, '!=', $nv, "values no longer match");

    my $op16 = Rmpfr_init2(11); # _Float16 has 11 bits of precision.
    Rmpfr_set_ui($op16, 2, MPFR_RNDN);
    Rmpfr_sqrt($op16, $op16, MPFR_RNDN);

    cmp_ok($nv, '==', $op16, "values match");
    cmp_ok(unpack_float16($nv, MPFR_RNDN), 'eq', '3DA8', 'hex unpacking of sqrt(2) is as expected');

    my $inex = Rmpfr_set_float16($op, $nv, MPFR_RNDN);
    cmp_ok($inex, '==', 0, 'value set exactly');
    cmp_ok($op, '==', $op16, 'values still match');

    # Smallest Positive Subnormal
    cmp_ok(unpack_float16(Math::MPFR->new(2 ** -24), MPFR_RNDN), 'eq', '0001', "smallest positive subnormal ok");

    # Largest Negative Subnormal
    cmp_ok(unpack_float16(Math::MPFR->new(-(2 ** -24)), MPFR_RNDN), 'eq', '8001', "largest negative subnormal ok");

    # Largest Positive Subnormal
    cmp_ok(uc(unpack_float16(Math::MPFR->new(2 ** -14) * 1023 / 1024, MPFR_RNDN)), 'eq', '03FF', "largest positive subnormal ok");

    # Smallest Positive Normal
    cmp_ok(unpack_float16(Math::MPFR->new(2 ** -14), MPFR_RNDN), 'eq', '0400', "smallest positive normal ok");

    # Largest Number Less Than 1
    cmp_ok(uc(unpack_float16(Math::MPFR->new(2 ** -1) + ((0.5 * 1023) / 1024), MPFR_RNDN)), 'eq', '3BFF', "largest number less than 1 ok");

    # 1
    cmp_ok(uc(unpack_float16(Math::MPFR->new(1), MPFR_RNDN)), 'eq', '3C00', "1 ok");

    # Largest Normal Number
    cmp_ok(uc(unpack_float16(Math::MPFR->new(65504), MPFR_RNDN)), 'eq', '7BFF', "largest normal number ok");

    # Smallest Normal Number
    cmp_ok(uc(unpack_float16(Math::MPFR->new(-65504), MPFR_RNDN)), 'eq', 'FBFF', "smallest normal number ok");

    Rmpfr_set_inf($op, 1);
    cmp_ok(uc(unpack_float16($op, MPFR_RNDN)), 'eq', '7C00', "+inf ok");

    Rmpfr_set_inf($op, -1);
    cmp_ok(uc(unpack_float16($op, MPFR_RNDN)), 'eq', 'FC00', "-inf ok");

    Rmpfr_set_zero($op, 1);
    cmp_ok(unpack_float16($op, MPFR_RNDN), 'eq', '0000', "0 ok");

    Rmpfr_set_zero($op, -1);
    cmp_ok(unpack_float16($op, MPFR_RNDN), 'eq', '8000', "-0 ok");

    my $nan = unpack_float16(Math::MPFR->new(), MPFR_RNDN);
    my $ok = 0;
    $ok = 1 if length($nan) == 4 && $nan =~/^7|^F/i
               && Math::MPFR->new(substr($nan, -3, 3), 16) > 0xc00;

    cmp_ok($ok, '==' , 1, "NaN unpacks correctly");
    warn "NaN unpacks incorrectly: got $nan\n" unless $ok;

  }
  else {
    cmp_ok(Math::MPFR::_have_float16(), '==', 0, "MPFR library support for_Float16 is not utilised");

    my ($op, $nv) = (Math::MPFR->new(), 0);
    eval { $nv = Rmpfr_get_float16($op, MPFR_RNDN);};
    like($@, qr/^Perl interface to Rmpfr_get_float16 not available/, 'Rmpfr_get_float16: $@ set as expected');

    eval { Rmpfr_set_float16($op, $nv, MPFR_RNDN);};
    like($@, qr/^Perl interface to Rmpfr_set_float16 not available/, 'Rmpfr_set_float16: $@ set as expected');
  }
}
else {

  cmp_ok(Rmpfr_buildopt_float16_p(), '==', 0, "Rmpfr_buildopt_float16_p() returns 0");
  cmp_ok(Math::MPFR::_have_float16(), '==', 0, "_Float16 support is lacking");

  my ($op, $nv) = (Math::MPFR->new(), 0);
  eval { $nv = Rmpfr_get_float16($op, MPFR_RNDN);};
  like($@, qr/^Perl interface to Rmpfr_get_float16 not available/, 'Rmpfr_get_float16: $@ set as expected');

  eval { Rmpfr_set_float16($op, $nv, MPFR_RNDN);};
  like($@, qr/^Perl interface to Rmpfr_set_float16 not available/, 'Rmpfr_set_float16: $@ set as expected');
}

done_testing();
