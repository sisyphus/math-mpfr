# Check that scalars that are (or might be)
# both POK and NOK are being handled correctly.

use strict;
use warnings;

warn "\n The string 'nan' apparently numifies to zero\n"
  if 'nan' + 0 == 0;

use Math::MPFR qw(:mpfr);
*_ITSA = \&Math::MPFR::_itsa;

use Test::More;

# Check that both the perl environment and the XS
# environment agree on whether the problem is present.
cmp_ok(MPFR_PV_NV_BUG, '==', Math::MPFR::_has_pv_nv_bug(),
       "Perl environment and XS environment agree");       # Test 1

my $nv_1 = 1.3;
my $s    = "$nv_1";

cmp_ok(_ITSA($nv_1), '==', 3, "NV slot will be used");     # Test 2

my $nv_2 = '1.7';

if($nv_2 > 1) {      # True
  cmp_ok(_ITSA($nv_2), '==', 4, "PV slot will be used");   # Test 3
}

my $pv_finite = '5e5000';

if($pv_finite > 0) { # True
  my $fr = Math::MPFR->new($pv_finite);
  cmp_ok("$fr", 'eq', '5.0000000000000002e5000',
         "'5e5000' is not an Inf");                        # Test 4
}

if('nan' + 0 != 'nan' + 0) { # Skip if numification of
                              # 'nan' fails to DWIM
  my $pv_nan = 'nan';

  if($pv_nan != 42) { # True
    # On perl-5.8.8 any string which numifies to an integer value
    # (including 0) will have its IOK flag set. Brilliant !!
    print "_ITSA: ", _ITSA($pv_nan), "\n";
    my $fr = Math::MPFR->new($pv_nan);
    cmp_ok(Rmpfr_nan_p($fr), '!=', 0,
           "NaN Math::MPFR object was created");           # Test 5
  }
}
else { # Instead verify that 'nan' numifies to zero
  cmp_ok('nan' + 0, '==', 0, "'nan' numifies to zero");    # Test 5 alt.
}

my $nv_inf = Rmpfr_get_NV(Math::MPFR->new('Inf'), MPFR_RNDN);
$s = "$nv_inf";

cmp_ok(Rmpfr_inf_p(Math::MPFR->new($nv_inf)), '!=', 0,
       "Inf Math::MPFR object was created");               # Test 6

my $nv_nan = Rmpfr_get_NV(Math::MPFR->new(), MPFR_RNDN);
$s = "$nv_nan";
  cmp_ok(Rmpfr_nan_p(Math::MPFR->new($nv_nan)), '!=', 0,
         "NaN Math::MPFR object was created");             # Test 7

Rmpfr_set_default_prec($Math::MPFR::NV_properties{bits});
my $mpfr_sqrt = sqrt(Math::MPFR->new(2));

my $perl_sqrt = Rmpfr_get_NV($mpfr_sqrt, MPFR_RNDN); # sqrt(2) as NV
my $str = "$perl_sqrt"; # sqrt(2) as decimal string, rounded twice.

if($str > 0) {
  cmp_ok(_ITSA($str), '==', 4,
         "Correctly designated a PV");                     # Test 8
  cmp_ok(_ITSA($perl_sqrt), '==', 3,
         "Correctly designated as an NV");                 # Test 9
}

done_testing();