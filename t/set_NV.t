use strict;
use warnings;
use Math::MPFR qw(:mpfr);

print "1..2\n";

Rmpfr_set_default_prec(70);

my $fr1 = Rmpfr_init();
my $fr2 = Rmpfr_init();
my ($ret1, $ret2);

$ret1 = Rmpfr_set_NV($fr1, sqrt(2.0), MPFR_RNDN);

if(Math::MPFR::_has_longdouble()) {
  $ret2 = Rmpfr_set_ld($fr2, sqrt(2.0), MPFR_RNDN);
}
else {
  $ret2 = Rmpfr_set_d($fr2, sqrt(2.0), MPFR_RNDN);
}

if($fr1 == $fr2) {print "ok 1\n"}
else {
  warn "\n\$fr1: $fr1\n\$fr2: $fr2\n";
  print "not ok 1\n";
}

if($ret1 == $ret2) {print "ok 2\n"}
else {
  warn "\n\$ret1: $ret1\n\$ret2: $ret2\n";
  print "not ok 2\n";
}
