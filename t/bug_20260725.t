# A bug in set_str/get_str reported by Mikhail Hogrefe in July 2026.
# This script will not pass if the MPFR library version is less than 4.3.0
# It's a rare bug - so we skip the detection of it when the version < 4.3.0.
use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Test::More;

my ($have_gmpz, $have_gmp) = (0, 0);
eval{ require Math::GMPz;};

if(!$@) {
  $have_gmpz = 1;
  *NEWZ = \&assign_from_math_gmpz;
}
else {
  eval{ require Math::GMP;};

  if(!$@) {
    $have_gmp = 1;
    *NEWZ = \&assign_from_math_gmp;
  }
}

if(Math::MPFR::MPFR_VERSION < 262912) {
  # MPFR library version is less than 4.3.0
  warn "No testing to be done as MPFR library version is less than 4.3.0\n";
  is(1,1);
  done_testing();
  exit 0;
}

if($have_gmpz || $have_gmp) {
  my $n = 760455;
  my $z = NEWZ() ** $n;
  $z -= 1;          # == (21 ** 760455) - 1
  my $s = 'k' x $n; # == base 21 representation of $z

  my $prec = 3340000; # 160 bits less than bitsize of $z
  my $x = Rmpfr_init2($prec);
  my $y = Rmpfr_init2($prec);

  ## Assign $s to $x
  Rmpfr_set_str($x, $s, 21, MPFR_RNDN);
  # Rmpfr_strtofr($x, $s, 21, MPFR_RNDN); # Same result

  ## Assign $z to $y
  Rmpfr_set_z($y, $z, MPFR_RNDN);

  ## $x and $y should be equivalent
  cmp_ok(Rmpfr_cmp($x, $y), '==', 0, 'assignments are equivalent');

  Rmpfr_set_default_prec(100);
  cmp_ok(Math::MPFR->new($x), '==', Math::MPFR->new($y), 'reassigned Math::MPFR objects are equivalent');

  my $y_str = Rmpfr_get_str($y, 21, 20, MPFR_RNDN);
  cmp_ok($y_str, 'eq', '1.0000000000000000000@760455', 'string derived from GMP library is correct');

  my $x_str = Rmpfr_get_str($x, 21, 20, MPFR_RNDN);
  cmp_ok($x_str, 'eq', '1.0000000000000000000@760455', 'string derived from MPFR library is correct');
}
else {
  warn "Skipping tests as neither Math::GMPz nor Math::GMP are available\n";
  is(1,1);
}

done_testing();

sub assign_from_math_gmp {
  warn "Assigning from Math::GMP\n";
  return Math::GMP->new(21);
}

sub assign_from_math_gmpz {
  warn "Assigning from Math::GMPz\n";
  return Math::GMPz->new(21);
}
