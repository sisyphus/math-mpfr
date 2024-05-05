
# Test script for:
# mpfr_compound_si - new in 4.2.0
# mpfr_compound - new in 4.3.0

use strict;
use warnings;
use Math::MPFR qw(:mpfr);

use Test::More;

my $rop = Math::MPFR->new();
my $op1 = Math::MPFR->new(5);
my $op2 = Math::MPFR->new(3);

warn "MPFR_VERSION: ", MPFR_VERSION, "\n";

if(MPFR_VERSION >= 262656) {
  my $inex = Rmpfr_compound_si($rop, $op1, 3, MPFR_RNDN);
  cmp_ok($rop, '==', 216, "Rmpfr_compound_si: 6 ** 3 == 216");
}
else {
  eval {Rmpfr_compound_si($rop, $op1, 0, MPFR_RNDN);};
  like($@, qr/^Rmpfr_compound_si function not implemented/, "Rmpfr_compound_si requires mpfr-4.2.0");
}

if(MPFR_VERSION >= 262912) {
  my $inex = Rmpfr_compound($rop, $op1, $op2, MPFR_RNDN);
  cmp_ok($rop, '==', 216, "Rmpfr_compound: 6 ** 3 == 216");
}
else {
  eval {Rmpfr_compound($rop, $op1, $op2, MPFR_RNDN);};
  like($@, qr/^Rmpfr_compound function not implemented/, "Rmpfr_compound requires mpfr-4.3.0");
}

done_testing();
