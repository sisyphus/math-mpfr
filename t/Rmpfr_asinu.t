# Test file for Rmpfr_asinpi(), Rmpfr_acospi(), Rmpfr_atanpi(), Rmpfr_atan2pi(),
# and also for Rmpfr_asinu(), Rmpfr_acosu(), Rmpfr_atanu() anf Rmpfr_atan2u().

use strict;
use warnings;
use Config;
use Test::More;
use Math::MPFR qw(:mpfr);

my $has_420 = 0;
$has_420++ if MPFR_VERSION() >= 262656; # mpfr-4.2.0 or later

my $rop   = Math::MPFR->new();
my $ropu  = Math::MPFR->new();
my $roppi = Math::MPFR->new();
my $pi    = Math::MPFR->new('3.1415926535897931');
my $op    = Math::MPFR->new('0.5');
my $op2   = Math::MPFR->new('0.7');
my $ui    = 128;


if($has_420) {

  #### acos ####
  Rmpfr_acos  ($rop,   $op,      MPFR_RNDN);
  Rmpfr_acospi($roppi, $op,      MPFR_RNDN);
  Rmpfr_acosu ($ropu,  $op, 128, MPFR_RNDN);

  # $ropu = $rop * 128 / (2 * $pi)
  my $rop_check = ($rop * 128) / (2 * $pi);
  cmp_ok(abs($ropu - $rop_check), '<', 1e-14, "Rmpfr_acosu in range ($ropu | $rop_check");

  # $roppi = $rop / $pi
  $rop_check = $rop / $pi;
  cmp_ok(abs($roppi - $rop_check), '<', 1e-16, "Rmpfr_acospi in range ($roppi | $rop_check");

  ### asin ###
  Rmpfr_asin  ($rop,   $op,      MPFR_RNDN);
  Rmpfr_asinpi($roppi, $op,      MPFR_RNDN);
  Rmpfr_asinu ($ropu,  $op, 128, MPFR_RNDN);

  # $ropu = $rop * 128 / (2 * $pi)
  $rop_check = ($rop * 128) / (2 * $pi);
  cmp_ok(abs($ropu - $rop_check), '<', 1e-14, "Rmpfr_asinu in range ($ropu | $rop_check");

  # $roppi = $rop / $pi
  $rop_check = $rop / $pi;
  cmp_ok(abs($roppi - $rop_check), '<', 1e-16, "Rmpfr_asinpi in range ($roppi | $rop_check");

  ### atan ###
  Rmpfr_atan  ($rop,   $op,      MPFR_RNDN);
  Rmpfr_atanpi($roppi, $op,      MPFR_RNDN);
  Rmpfr_atanu ($ropu,  $op, 128, MPFR_RNDN);

  # $ropu = $rop * 128 / (2 * $pi)
  $rop_check = ($rop * 128) / (2 * $pi);
  cmp_ok(abs($ropu - $rop_check), '==', 0, "Rmpfr_atanu in range ($ropu | $rop_check"); # 1e-14

  # $roppi = $rop / $pi
  $rop_check = $rop / $pi;
  cmp_ok(abs($roppi - $rop_check), '==', 0, "Rmpfr_atanpi in range ($roppi | $rop_check"); # 1e-16

  #### atan2 ####
  Rmpfr_atan2  ($rop,   $op, $op2,      MPFR_RNDN);
  Rmpfr_atan2pi($roppi, $op, $op2,      MPFR_RNDN);
  Rmpfr_atan2u ($ropu,  $op, $op2, 128, MPFR_RNDN);

  # $ropu = ($rop * 128) / (2 * $pi)
  $rop_check = ($rop * 128) / (2 * $pi);
  cmp_ok(abs($ropu - $rop_check), '==', 0, "Rmpfr_atan2u in range ($ropu | $rop_check"); # 1e-14

  Rmpfr_atan2u ($rop_check,  $op, $op2, 2, MPFR_RNDN);
  cmp_ok(abs($roppi - $rop_check), '==', 0, "Rmpfr_atan2pi in range ($roppi | $rop_check"); # 1e-16

}
else {
  for (qw(Rmpfr_acosu Rmpfr_acospi Rmpfr_asinu Rmpfr_asinpi Rmpfr_atanu Rmpfr_atanpi Rmpfr_atan2u Rmpfr_atan2pi)) {
    if($_ =~ /u/) { version_check($_, 'u') }
    else { version_check($_, 'pi') }
  }
}


done_testing();

sub version_check{
  my $f = shift;
  my $which = shift;
  my $op = Math::MPFR->new('0.5');
  my $s;

  if($which eq 'pi') {
    if($f =~ /2/) { $s = "$f(\$op, \$op, \$op, MPFR_RNDN)" } # atan2
    else { $s = "$f(\$op, \$op, MPFR_RNDN)" }
    eval( $s );
  }
  else {
    if($f =~ /2/) { $s = "$f(\$op, \$op, \$op, 7, MPFR_RNDN)" } # atan2
    else { $s = "$f(\$op, \$op, 7, MPFR_RNDN)" }
    eval( $s );
  }

  like($@, qr/^$f function not implemented until/, "$f not implemented");
}

