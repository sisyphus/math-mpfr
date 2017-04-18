use strict;
use warnings;
use Math::MPFR qw(:mpfr);

print "1..10\n";

eval{require Math::GMPq;};

if($@) {
  warn "\n\$\@: $@\n";
  warn "\nSkipping mpq tests - couldn't load Math::GMPq\n";
  for(1..5) {print "ok $_\n"}
}
else {
  my $rop = Math::MPFR->new();
  my $fr = Math::MPFR->new(23);
  my $q = Math::GMPq->new('1/3');
  my $check = Math::MPFR->new(Math::GMPq->new('1/69'));

  my $inex = Rmpfr_q_div($fr, $q, $fr, MPFR_RNDN);

  if($inex) {print "ok 1\n"}
  else {
    warn "\n\$inex: $inex\n";
    print "not ok 1\n";
  }

  if($check == $fr) {print "ok 2\n"}
  else {
    warn "\nExpected $check, got $fr\n";
    print "not ok 2\n";
  }

  $inex = Rmpfr_q_div($rop, $q, Math::MPFR->new(27), MPFR_RNDN);

  my $inex2 = Rmpfr_set_q($check, Math::GMPq->new('1/81'), MPFR_RNDN);

  if($inex == $inex2) {print "ok 3\n"}
  else {
    warn "\nExpected $inex, got $inex2\n";
    print "not ok 3\n";
  }

  if($rop == $check) {print "ok 4\n"}
  else {
    warn "\nExpected $rop, got $check\n";
    print "not ok 4\n";
  }

  $rop = $q / Math::MPFR->new(-10);
  Rmpfr_set_q($check, Math::GMPq->new('-1/30'), MPFR_RNDN);
  if($rop == $check) {print "ok 5\n"}
  else {
    warn "$rop != $check\n";
    print "not ok 5\n";
  }
}

eval{require Math::GMPz;};

if($@) {
  warn "\n\$\@: $@\n";
  warn "\nSkipping mpz tests - couldn't load Math::GMPz\n";
  for(6..10) {print "ok $_\n"}
}
else {
  my $rop = Math::MPFR->new();
  my $fr = Math::MPFR->new(23);
  my $z = Math::GMPq->new(11);
  my $check = Math::MPFR->new(Math::GMPq->new('11/23'));

  my $inex = Rmpfr_z_div($fr, $z, $fr, MPFR_RNDN);

  if($inex) {print "ok 6\n"}
  else {
    warn "\n\$inex: $inex\n";
    print "not ok 6\n";
  }

  if($check == $fr) {print "ok 7\n"}
  else {
    warn "\nExpected $check, got $fr\n";
    print "not ok 7\n";
  }

  $inex = Rmpfr_z_div($rop, $z, Math::MPFR->new(27), MPFR_RNDN);

  my $inex2 = Rmpfr_set_q($check, Math::GMPq->new('11/27'), MPFR_RNDN);

  if($inex == $inex2) {print "ok 8\n"}
  else {
    warn "\nExpected $inex, got $inex2\n";
    print "not ok 8\n";
  }

  if($rop == $check) {print "ok 9\n"}
  else {
    warn "\nExpected $rop, got $check\n";
    print "not ok 9\n";
  }

  $rop = $z / Math::MPFR->new(-10);
  Rmpfr_set_q($check, Math::GMPq->new('-11/10'), MPFR_RNDN);
  if($rop == $check) {print "ok 10\n"}
  else {
    warn "$rop != $check\n";
    print "not ok 10\n";
  }
}
