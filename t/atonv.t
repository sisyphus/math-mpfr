use strict;
use warnings;
use Math::MPFR qw(:mpfr);

my $t = 3;

print "1..$t\n";

my($have_atonv, $mpfr_has_float128);

eval{$mpfr_has_float128 = Rmpfr_buildopt_float128_p()};

$mpfr_has_float128 = 0 if $@; # else it's whatever Rmpfr_buildopt_float128_p() returned

$have_atonv = MPFR_VERSION <= 196869 ? 0 : 1;

if($have_atonv) {

  my($nv1, $nv2, $double);

  if($Config::Config{nvtype} eq 'double' ||
      ($Config::Config{nvtype} eq 'long double' && ($Config::Config{nvsize} == 8 ||
                                                    Math::MPFR::_required_ldbl_mant_dig() == 2098))) {
    $double = atodouble('0b0.100001e-1074');
    $nv1 = atonv('0b0.100001e-1074');
    $nv2 = atonv('4.96e-324');
    if($nv1 == $nv2 && $double == $nv2 && $nv1 > 0) {print "ok 1\n"}
    else {
      warn "\n \$double: $double\n \$nv1: $nv1\n \$nv2: $nv2\n";
      print "not ok 1\n";
    }

    print "ok 2\n"; # Original test removed
  }

  elsif($Config::Config{nvtype} eq 'long double') {
    $nv1 = atonv('0b0.100001e-16445');
    $nv2 = atonv('3.7e-4951');
    if($nv1 == $nv2 && $nv1 > 0) {print "ok 1\n"}
    else {
      warn "\n \$nv1: $nv1\n \$nv2: $nv2\n";
      print "not ok 1\n";
    }


    # Let's now check to see whether failures reported at:
    # http://www.cpantesters.org/cpan/report/d6a27d3c-2a0d-11e9-bf31-80c71e9d5857 and
    # http://www.cpantesters.org/cpan/report/f8c159e0-2a0f-11e9-bf31-80c71e9d5857
    # might represent a bug in atonv().

    if(Math::MPFR::_required_ldbl_mant_dig() == 64) {

      my $ok = 1;

      my $nv = atonv('97646e-4945');
      unless(sprintf("%a", $nv) eq '0x6.3ca9b8fep-16410') {
        warn "97646e-4945: Expected 0x6.3ca9b8fep-16410 got ", sprintf("%a", $nv), "\n";
        $ok = 0;
      }

      $nv = atonv('7286408931649326e-4956');
      unless(sprintf("%a", $nv) eq '0x4.a770c127p-16410') {
        warn "7286408931649326e-4956: Expected 0x4.a770c127p-16410 got ", sprintf("%a", $nv), "\n";
        $ok = 0;
      }

      if($ok) { print "ok 2\n"; }
      else    { print "not ok 2\n"; }
    }
    else {
      print "ok 2\n"; # Original test removed
    }
  }

  elsif($Config::Config{nvtype} eq '__float128') {

    if($mpfr_has_float128) {                # Don't assume mpfr supports libquadmath types
      $nv1 = atonv('0b0.100001e-16494');
      $nv2 = atonv('6.5e-4966');
      if($nv1 == $nv2 && $nv1 > 0) {print "ok 1\n"}
      else {
        warn "\n \$nv1: $nv1\n \$nv2: $nv2\n";
        print "not ok 1\n";
      }

      print "ok 2\n"; # Original test removed
    }

    else {
      eval { $nv1 = atonv('0b0.100001e-16494') };
      if($@ =~ /^The atonv function is unavailable for this __float128 build/) {
        print "ok 1\n";
      }
      else {
        warn "\$\@: $@\n";
        print "not ok 1\n";
      }

      if(Math::MPFR::_MPFR_WANT_FLOAT128()) {

        # MPFR_WANT_FLOAT128 should be not defined if mpfr
        # library does not support libquadmath types

        warn "Serious inconsistency regarding mpfr library's quadmath support\n";
        print "not ok 2\n";
      }
      else {
        print "ok2\n";
      }
    }
  }

  else {
    warn "\n Unrecognized nvtype in atonv.t\n";
    print "not ok 1\nnot ok 2\n";
  }

  $nv1 = atonv('0.625');
  if($nv1 == 5 / 8) { print "ok 3\n"}
  else {
    warn "\n $nv1 != ", 5 / 8, "\n";
    print "not ok 3\n";
  }

}
else {

  eval{atonv('1234.5');};

  if($@ =~ /^The atonv function requires mpfr-3.1.6 or later/) {print "ok 1\n"}
  else {
    warn "\n \$\@: $@\n";
    print "not ok 1\n";
  }

  warn "\n Skipping tests 2 to $t - nothing else to check\n";
  print "ok $_\n" for 2 .. $t;
}


