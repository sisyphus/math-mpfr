use warnings;
use strict;
use Math::MPFR qw(:mpfr);

my $proceed = Math::MPFR::_MPFR_WANT_FLOAT128();

unless($proceed) {
  print "1..1\n";
  my $why = "Math::MPFR built without float128 support\n";
  warn "\n Skipping all tests: $why";
  print "ok 1\n";
  exit 0;
}

my $t = 2;

print "1..$t\n";


eval {require Math::Float128; Math::Float128->import (qw(:all));};

if($@) {
  my $why = "Couldn't load Math::Float128\n";
  warn "\n Skipping test 1: $why: $@\n";
  print "ok 1\n";
}
else {

  my $ok = 1;
  my $rop1 = Math::Float128->new();
  my $rop2 = Math::Float128->new();
  my $op1 = Rmpfr_init2(60);
  my $op2 = Rmpfr_init2(114);
  my $op3 = Rmpfr_init2(117);
  my $op4 = Rmpfr_init2(120);
  my $op5 = Rmpfr_init2(128);


  for my $rnd(MPFR_RNDN, MPFR_RNDZ, MPFR_RNDU, MPFR_RNDD, MPFR_RNDA) {
    for my $exp(-16382..-16493) {
      for my $f($op1, $op2, $op3, $op4, $op5) {
        my $rounder;
        my $count = 0;
        my $t = Rmpfr_init2(128);
        my $prec = Rmpfr_get_prec($f);
        my $str = random_string($prec) . "e$exp";
        Rmpfr_set_str($f, $str, 2, MPFR_RNDN);
        $rop1 = Rmpfr_get_FLOAT128($f, $rnd);
        Rmpfr_set($t, $f, MPFR_RNDZ); # rnd mode irrelevant


        if($exp < -16381 && $exp > -16494) {
          $rounder = $exp + 16494;
          Rmpfr_prec_round($t, $rounder, $rnd);
          $rop2 = _CALCULATE($t, MPFR_RNDZ); # rnd mode irrelevant
        }

        if($rop1 != $rop2) {
          $ok = 0;
          $count ++;
          if($count <= 2) {
            my $n_dig = Rmpfr_get_prec($f);
            $n_dig = 2 if $n_dig < 2;
            my @orig = Rmpfr_deref2($f, 2, $n_dig, MPFR_RNDZ);
            $n_dig = Rmpfr_get_prec($t);
            $n_dig = 2 if $n_dig < 2;
            my @rnded = Rmpfr_deref2($t, 2, $n_dig, MPFR_RNDZ);
            warn "\noriginal: @orig\n rounded @rnded\n";
          }
        }
      }
    }
  }

  if($ok) {print "ok 1\n"}
  else {print "not ok 1\n"}
}

$proceed = Math::MPFR::_can_pass_float128();

unless($proceed) {
  my $why = "Cannot receive __float128 values from XSubs\n";
  warn "\n Skipping test 2: $why";
  print "ok 2\n";
}
else {
  my $ok = 1;
  my $rop1;# = Math::Float128->new();
  my $rop2;# = Math::Float128->new();
  my $op1 = Rmpfr_init2(60);
  my $op2 = Rmpfr_init2(114);
  my $op3 = Rmpfr_init2(117);
  my $op4 = Rmpfr_init2(120);
  my $op5 = Rmpfr_init2(128);


  for my $rnd(MPFR_RNDN, MPFR_RNDZ, MPFR_RNDU, MPFR_RNDD, MPFR_RNDA) {
    for my $exp(-16382..-16493) {
      for my $f($op1, $op2, $op3, $op4, $op5) {
        my $rounder;
        my $count = 0;
        my $t = Rmpfr_init2(128);
        my $prec = Rmpfr_get_prec($f);
        my $str = random_string($prec) . "e$exp";
        Rmpfr_set_str($f, $str, 2, MPFR_RNDN);
        $rop1 = Rmpfr_get_float128($f, $rnd);
        Rmpfr_set($t, $f, MPFR_RNDZ); # rnd mode irrelevant


        if($exp < -16381 && $exp > -16494) {
          $rounder = $exp + 16494;
          Rmpfr_prec_round($t, $rounder, $rnd);
          $rop2 = _calculate($t, MPFR_RNDZ); # rnd mode irrelevant
        }

        if($rop1 != $rop2) {
          $ok = 0;
          $count ++;
          if($count <= 2) {
            my $n_dig = Rmpfr_get_prec($f);
            $n_dig = 2 if $n_dig < 2;
            my @orig = Rmpfr_deref2($f, 2, $n_dig, MPFR_RNDZ);
            $n_dig = Rmpfr_get_prec($t);
            $n_dig = 2 if $n_dig < 2;
            my @rnded = Rmpfr_deref2($t, 2, $n_dig, MPFR_RNDZ);
            warn "\noriginal: @orig\n rounded @rnded\n";
          }
        }
      }
    }
  }

  if($ok) {print "ok 2\n"}
  else {print "not ok 2\n"}
}

sub random_string {
  my $ret = '';
  for (1..$_[0]) {$ret .= int rand(2)}
  $ret =~ s/^0+//;
  if(int(rand(2))) {$ret =  '0.' . $ret}
  else             {$ret = '-0.' . $ret}
  return $ret;
}

# Calculate the value the __float128 value of the given mpfr_t
# Both _calculate() and _CALCULATE() expect to be handed a subnormal value.
# The difference between _calculate and _CALCULATE is that the former uses
# the __float128 type to do the calculation, whereas _CALCULATE uses
# a Math::Float128 object.

sub _calculate {
  my $n_digits = Rmpfr_get_prec($_[0]);
  $n_digits = 2 if $n_digits < 2;
  my ($s, $exp) = Rmpfr_deref2($_[0], 2, $n_digits, MPFR_RNDN);

  my $sign = 1.0;
  if($s =~ s/^\-//) {$sign = -1.0}

  my $pow = $exp - 1;
  my $ret = 0.0;
  my $len = length($s);

  for(my $i = 0; $i < $len; $i++) {
    if(substr($s, $i, 1) eq '1') {
      $ret += 2 ** $pow;
    }
    $pow--;
  }

  return $ret * $sign;
}

sub _CALCULATE {
  my $n_digits = Rmpfr_get_prec($_[0]);
  $n_digits = 2 if $n_digits < 2;
  my ($s, $exp) = Rmpfr_deref2($_[0], 2, $n_digits, MPFR_RNDN);

  my $sign = 1.0;
  if($s =~ s/^\-//) {$sign = -1.0}

  my $pow = $exp - 1;
  my $ret = Math::Float128->new(0);
  my $two = Math::Float128->new(2);
  my $len = length($s);

  for(my $i = 0; $i < $len; $i++) {
    if(substr($s, $i, 1) eq '1') {
      $ret += $two ** $pow;
    }
    $pow--;
  }

  return $ret * $sign;
}
