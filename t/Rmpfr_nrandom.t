# Rmfpr_nrandom() is also tested in t/new_in_4.0.0.t
# This file actually tests the 2 new nrandom variants
# Rmpfr_nrandom_v1 and Rmpfr_nrandom_v2 which were added
# in the 4.3.0 development cycle.

use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Test::More;

my($rop0, $rop1, $rop2, $rop3) = (Math::MPFR->new(), Math::MPFR->new(),
                                  Math::MPFR->new(), Math::MPFR->new());
my($state0, $state1, $state2, $state3) = (Rmpfr_randinit_mt(), Rmpfr_randinit_mt(),
                                          Rmpfr_randinit_mt(), Rmpfr_randinit_mt());
my $seed = 12345678;

if(RMPFR_VERSION_NUM(4,3,0) > MPFR_VERSION) {
  eval { my $inex = Rmpfr_nrandom_v1($rop0, $state0, MPFR_RNDN);};
  like($@, qr/^Rmpfr_nrandom_v1 not implemented \- need at least mpfr\-4\.3\.0/, '$@ set as expected');

  eval { my $inex = Rmpfr_nrandom_v2($rop0, $state0, MPFR_RNDN);};
  like($@, qr/^Rmpfr_nrandom_v2 not implemented \- need at least mpfr\-4\.3\.0/, '$@ set as expected');

  done_testing();
  exit 0;
}

Rmpfr_randseed_ui($state0, $seed);
Rmpfr_randseed_ui($state1, $seed);
Rmpfr_randseed_ui($state2, $seed);
Rmpfr_randseed_ui($state3, $seed);

Rmpfr_nrandom($rop0,  $state0, MPFR_RNDN);
Rmpfr_nrandom_v1($rop1,  $state1, MPFR_RNDN);
Rmpfr_nrandom_v2($rop2,  $state2, MPFR_RNDN);

# At time of writing, Rmpfr_nrandom calls mpfr_nrandom_v1.
# However, at some future time, Rmpfr_nrandom will switch
# to calling mpfr_nrandom_v2.
# We allow for both situations.

if($rop0 == $rop1) {
  cmp_ok($rop0, '==', $rop1, '$rop0 == $rop1'); # Rmpfr_nrandom calls Rmpfr_nrandom_v1.
  cmp_ok($rop0, '!=', $rop2, '$rop0 != $rop2'); # Rmpfr_nrandom and Rmpfr_nrandom_v2
                                                # produce different results.
}
else {
  cmp_ok($rop0, '==', $rop2, '$rop0 == $rop2'); # Rmpfr_nrandom calls Rmpfr_nrandom_v2.
  cmp_ok($rop0, '!=', $rop1, '$rop0 != $rop1'); # Rmpfr_nrandom and Rmpfr_nrandom_v1
                                                # produce different results.
}

done_testing();

