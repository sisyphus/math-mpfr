use strict;
use warnings;
use Math::MPFR qw(:mpfr);

my $zero = 0.0;
my $nzero = Rmpfr_get_NV(Math::MPFR->new('-0'), MPFR_RNDN);
my $inf = 1e4950;
my $ninf = $inf * -1;
my $nan = Rmpfr_get_NV(Math::MPFR->new(), MPFR_RNDN);

if($Math::MPFR::NV_properties{'bits'} == 53) {
  print "1..6\n";

  if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
  else {
    warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
    print "not ok 1\n";
  }

  if(nvtoa($zero) eq '0.0') { print "ok 2\n" }
  else {
    warn nvtoa($zero), " ne '0.0'\n";
    print "not ok 2\n";
  }

  if($] < 5.010) {
    warn "This version of perl ($]) is old - skipping test 3\n";
  }
  else {
  if(nvtoa($nzero) eq '-0.0') { print "ok 3\n" }
    else {
      warn nvtoa($nzero), " ne '-0.0'\n";
      print "not ok 3\n";
    }
  }

  if(nvtoa($inf) eq 'Inf') { print "ok 4\n" }
  else {
    warn nvtoa($inf), " ne 'Inf'\n";
    print "not ok 4\n";
  }

  if(nvtoa($ninf) eq '-Inf') { print "ok 5\n" }
  else {
    warn nvtoa($ninf), " ne '-Inf'\n";
    print "not ok 5\n";
  }

  if(nvtoa($nan) eq 'NaN') { print "ok 6\n" }
  else {
    warn nvtoa($nan), " ne 'NaN'\n";
    print "not ok 6\n";
  }
}

elsif($Math::MPFR::NV_properties{'bits'} == 64) {
  print "1..6\n";

  if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" }
  else {
    warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
    print "not ok 1\n";
  }

  if(nvtoa($zero) eq '0.0') { print "ok 2\n" }
  else {
    warn nvtoa($zero), " ne '0.0'\n";
    print "not ok 2\n";
  }

  if($] < 5.010) {
    warn "This version of perl ($]) is old - skipping test 3\n";
  }
  else {
  if(nvtoa($nzero) eq '-0.0') { print "ok 3\n" }
    else {
      warn nvtoa($nzero), " ne '-0.0'\n";
      print "not ok 3\n";
    }
  }

  if(nvtoa($inf) eq 'Inf') { print "ok 4\n" }
  else {
    warn nvtoa($inf), " ne 'Inf'\n";
    print "not ok 4\n";
  }

  if(nvtoa($ninf) eq '-Inf') { print "ok 5\n" }
  else {
    warn nvtoa($ninf), " ne '-Inf'\n";
    print "not ok 5\n";
  }

  if(nvtoa($nan) eq 'NaN') { print "ok 6\n" }
  else {
    warn nvtoa($nan), " ne 'NaN'\n";
    print "not ok 6\n";
  }
}

elsif($Math::MPFR::NV_properties{'bits'} == 113) {
  print "1..6\n";

  if(nvtoa(sqrt(2.0)) == sqrt(2.0)) { print "ok 1\n" } # 1.4142135623730950488016887242096982
  else {
    warn nvtoa(sqrt(2.0)), " != sqrt(2.0)\n";
    print "not ok 1\n";
  }

  if(nvtoa($zero) eq '0.0') { print "ok 2\n" }
  else {
    warn nvtoa($zero), " ne '0.0'\n";
    print "not ok 2\n";
  }

  if($] < 5.010) {
    warn "This version of perl ($]) is old - skipping test 3\n";
  }
  else {
  if(nvtoa($nzero) eq '-0.0') { print "ok 3\n" }
    else {
      warn nvtoa($nzero), " ne '-0.0'\n";
      print "not ok 3\n";
    }
  }

  if(nvtoa($inf) eq 'Inf') { print "ok 4\n" }
  else {
    warn nvtoa($inf), " ne 'Inf'\n";
    print "not ok 4\n";
  }

  if(nvtoa($ninf) eq '-Inf') { print "ok 5\n" }
  else {
    warn nvtoa($ninf), " ne '-Inf'\n";
    print "not ok 5\n";
  }

  if(nvtoa($nan) eq 'NaN') { print "ok 6\n" }
  else {
    warn nvtoa($nan), " ne 'NaN'\n";
    print "not ok 6\n";
  }

}

else {
  print "1..1\n";
  warn "Error: Unrecognized nvtype\n";
  print "not ok 1\n";
}
