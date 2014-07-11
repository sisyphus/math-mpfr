use warnings;
use strict;
use Math::MPFR qw(:mpfr);

print "1..6\n";

print  "# Using Math::MPFR version ", $Math::MPFR::VERSION, "\n";
print  "# Using mpfr library version ", MPFR_VERSION_STRING, "\n";
print  "# Using gmp library version ", Math::MPFR::gmp_v(), "\n";

if(GMP_RNDN == MPFR_RNDN) {print "ok 1\n"}
else {
  warn "GMP_RNDN: ", GMP_RNDN, " MPFR_RNDN: ", MPFR_RNDN, "\n";
  print "not ok 1\n";
}

if(GMP_RNDZ == MPFR_RNDZ) {print "ok 2\n"}
else {
  warn "GMP_RNDZ: ", GMP_RNDZ, " MPFR_RNDZ: ", MPFR_RNDZ, "\n";
  print "not ok 2\n";
}

if(GMP_RNDU == MPFR_RNDU) {print "ok 3\n"}
else {
  warn "GMP_RNDU: ", GMP_RNDU, " MPFR_RNDU: ", MPFR_RNDU, "\n";
  print "not ok 3\n";
}

if(GMP_RNDD == MPFR_RNDD) {print "ok 4\n"}
else {
  warn "GMP_RNDD: ", GMP_RNDD, " MPFR_RNDD: ", MPFR_RNDD, "\n";
  print "not ok 4\n";
}

if(MPFR_RNDA == 4) {print "ok 5\n"}
else {
  warn "MPFR_RNDA: ", MPFR_RNDA, "\n";
  print "not ok 5\n";
}

if(MPFR_VERSION_MAJOR >= 3) {
  my ($mpfr, $dis) = Rmpfr_init_set_ui(12345, MPFR_RNDA);
  if($mpfr == 12345) {print "ok 6\n"}
  else {
    warn "\$mpfr: $mpfr\n";
    print "not ok 6\n";
  }
}
else {
  eval {my ($mpfr, $dis) = Rmpfr_init_set_ui(12345, MPFR_RNDA);};
  if($@ =~ /Illegal rounding value supplied/) {print "ok 6\n"}
  else {
    warn "\$\@: $@\n";
    print "not ok 6\n";
  }
}
