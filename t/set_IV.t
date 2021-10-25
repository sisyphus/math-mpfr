# Check some values to verify that Rmpfr_set_IV is functioning
# correctly. We check some values that are not IVs.
# In all cases Rmpfr_set_IV should agree with both MPFR_SET_IV()
# and MPFR_INIT_SET_IV().
use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Config;

use Test::More;

my $bits = $Config{ivsize} * 8;

if($Config{ivtype} eq 'long' &&
   $Config{ivsize} == $Config{longsize}) { *MPFR_SET_IV      = \&Rmpfr_set_si;
                                           *MPFR_INIT_SET_IV = \&Rmpfr_init_set_si;
                                           *MPFR_SET_UV      = \&Rmpfr_set_ui;
                                           *MPFR_INIT_SET_UV = \&Rmpfr_init_set_ui;
                                           warn "\nUsing *_set_ui and *_set_si functions\n"; }

else                                     { *MPFR_SET_IV      = \&Rmpfr_set_sj;
                                           *MPFR_INIT_SET_IV = \&init_set_sj;          # provided below
                                           *MPFR_SET_UV      = \&Rmpfr_set_uj;
                                           *MPFR_INIT_SET_UV = \&init_set_uj;          # provided below
                                           warn "\nUsing set_uj and _set_sj functions\n"; }
Rmpfr_set_default_prec($bits);

my $x = '42.3';
my $y = ~0;
my $z = -1;

for(0, 'inf', '-inf', 'nan', '-nan', 'hello', ~0, -1, sqrt(2), Math::MPFR->new(),
    Math::MPFR->new(-11), $x, \$x, "$y", "$z", 2 ** 32, 2 ** 64) {

  no warnings 'numeric';

  # Create copies of $_ - and use each copy only once
  # as perl might change the flags.
  my($c1, $c2, $c3, $c4, $c5, $c6) = ($_, $_, $_, $_, $_, $_);

  my($rop1, $rop2, $rop3, $rop4, $inex1, $inex2, $inex3, $inex4);
  my $rnd = int(rand(4));
  ($rop1, $inex1) = Rmpfr_init_set_IV($c1, $rnd);

  if($rop1 < (~0 >> 1)) {
    ($rop2, $inex2) = MPFR_INIT_SET_IV ($c2, $rnd);
  }
  else {
    ($rop2, $inex2) = MPFR_INIT_SET_UV ($c2, $rnd);
  }

  $rop3  = Math::MPFR->new();
  $rop4  = Math::MPFR->new();

  $inex3 = Rmpfr_set_IV($rop3, $c3, $rnd);

  if($rop1 < (~0 >> 1)) {
    $inex4 = MPFR_SET_IV ($rop4, $c4, $rnd);
  }
  else {
    $inex4 = MPFR_SET_UV ($rop4, $c4, $rnd);
  }

  cmp_ok($inex1, '==', $inex2, "$rnd: $_: \$inex1 == \$inex2");
  cmp_ok($inex1, '==', $inex3, "$rnd: $_: \$inex1 == \$inex3");
  cmp_ok($inex1, '==', $inex4, "$rnd: $_: \$inex1 == \$inex4");

  cmp_ok(Rmpfr_nan_p($rop1), '==', 0, "$rnd: $_: not a NaN");
  cmp_ok(Rmpfr_nan_p($rop2), '==', 0, "$rnd: $_: not a NaN");
  cmp_ok(Rmpfr_nan_p($rop3), '==', 0, "$rnd: $_: not a NaN");
  cmp_ok(Rmpfr_nan_p($rop4), '==', 0, "$rnd: $_: not a NaN");

  cmp_ok($rop1, '==', $rop2, "$rnd: $_: \$rop1 == \$rop2");
  cmp_ok($rop1, '==', $rop3, "$rnd: $_: \$rop1 == \$rop3");
  cmp_ok($rop1, '==', $rop4, "$rnd: $_: \$rop1 == \$rop2");
}

done_testing();

sub init_set_sj {
  no warnings 'numeric';
  my $ret = Math::MPFR->new();
  my $inex = Rmpfr_set_sj($ret, $_[0], $_[1]);
  return ($ret, $inex);
}

sub init_set_uj {
  no warnings 'numeric';
  my $ret = Math::MPFR->new();
  my $inex = Rmpfr_set_uj($ret, $_[0], $_[1]);
  return ($ret, $inex);
}
