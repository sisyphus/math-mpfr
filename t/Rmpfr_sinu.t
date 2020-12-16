# Test file for Rmpfr_sinu() and Rmpfr_cosu()

use strict;
use warnings;
use Config;
use Test::More;
use Math::MPFR qw(:mpfr);

# For testing, set mpfr default precision
# to the same value as NV precision

my $default_prec = 53;
if($Config{nvsize} > 8) {
  if($Config{nvtype} eq '__float128' || Math::MPFR::_have_IEEE_754_long_double()) {
    $default_prec = 113;
  }
  else { $default_prec = 64 }
}
Rmpfr_set_default_prec($default_prec);

my $rop1 = Math::MPFR->new();
my $rop2 = Math::MPFR->new();

if(MPFR_VERSION() >= 262656) {
  # Rmpfr_sinu() and Rmpfr_cosu are available

  # With Rmpfr_sinu, when 2*$op divided by the third argument is an integer,
  # $rop should be set to 0 (-0 if $op is negative).

  Rmpfr_sinu($rop1, Math::MPFR->new(6), 3, MPFR_RNDN);
  cmp_ok( "$rop1", 'eq', '0', 'Rmpfr_sinu: Get 0 when 2*$op/3 is +ve integer');

  Rmpfr_sinu($rop1, Math::MPFR->new(-12), 4, MPFR_RNDN);
  cmp_ok( "$rop1", 'eq', '-0', 'Rmpfr_sinu: Get -0 when 2*$op/4 is -ve integer');

  # For Rmpfr_cosu, when 2*$op divided by the third argument is a half-integer,
  # $rop should be set to zero, irrespective of the sign of $op.

  Rmpfr_cosu($rop1, Math::MPFR->new(5), 4, MPFR_RNDN);
  cmp_ok( "$rop1", 'eq', '0', 'Rmpfr_cosu: Get 0 when 2*$op/4 is a +ve half-integer');

  Rmpfr_cosu($rop1, Math::MPFR->new(-6.5), 2, MPFR_RNDN);
  cmp_ok( "$rop1", 'eq', '0', 'Rmpfr_cosu: Get 0 when 2*$op/2 is a -ve half-integer');

  my $op1 = Math::MPFR->new(30);
  my $op2 = Math::MPFR->new(60);

  Rmpfr_sinu($rop1, $op1, 360, MPFR_RNDN);
  cmp_ok( $rop1, '==', 0.5, "sine of 30 degrees is 0.5");

  Rmpfr_sinu($rop2, $op2, 360, MPFR_RNDN);
  cmp_ok( $rop2, '==', sqrt(3) / 2, "sine of 60 degrees is 0.5 * sqrt(3)");

  Rmpfr_cosu($rop1, $op1, 360, MPFR_RNDN);
  cmp_ok( $rop1, '==', $rop2, "cosine of 30 degrees == sine of 60 degrees");

  Rmpfr_cosu($rop2, $op2, 360, MPFR_RNDN);
  cmp_ok( $rop2, '==', 0.5, "cosine of 60 degrees is 0.5");

}
else {
  # Rmpfr_sinu() is unavailable

  eval{ Rmpfr_sinu($rop1, Math::MPFR->new(6), 3, MPFR_RNDN); };

  like($@, qr/^Rmpfr_sinu function not implemented/, '$@ set as expected');

  # Rmpfr_cosu() is unavailable

  eval{ Rmpfr_cosu($rop1, Math::MPFR->new(6), 3, MPFR_RNDN); };

  like($@, qr/^Rmpfr_cosu function not implemented/, '$@ set as expected');
}


done_testing();
