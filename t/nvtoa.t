use strict;
use warnings;
use Math::MPFR qw(:mpfr);

if($Math::MPFR::NV_properties{'bits'} == 53) {
  print "1..1\n";

  if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
  else {
    warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
    print "not ok 1\n";
  }
}

elsif($Math::MPFR::NV_properties{'bits'} == 64) {
  print "1..1\n";

  if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
  else {
    warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
    print "not ok 1\n";
  }

}

elsif($Math::MPFR::NV_properties{'bits'} == 113) {
  print "1..1\n";

  if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
  else {
    warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
    print "not ok 1\n";
  }

}

else {
  print "1..1\n";
  warn "Error: Unrecognized nvtype\n";
  print "not ok 1\n";
}
