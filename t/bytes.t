use warnings;
use strict;
use Config;
use Math::MPFR qw(:mpfr);


print  "# Using Math::MPFR version ", $Math::MPFR::VERSION, "\n";
print  "# Using mpfr library version ", MPFR_VERSION_STRING, "\n";
print  "# Using gmp library version ", Math::MPFR::gmp_v(), "\n";

print "1..9\n";

my $arb = 40;
Rmpfr_set_default_prec($arb);

my @bytes;

eval {@bytes = Math::MPFR::_ld_bytes('2.3', 64);};

if($@) {

  my $mess = $@;

  my $dd = 0;
  my $nv1 = 1.0;
  my $nv2 = $nv1 + (2 ** -1000);
  $dd = 1 if $nv2 != $nv1;

  if($Config{longdblkind} == 6 || $dd == 1) {
    warn "\ndouble-double detected\n";
    if($mess =~ /^2nd arg \(/) {print "ok 1\n"}
    else {
      warn "\n\$\@: $mess\n";
      print "not ok 1\n";
    }
  }
  elsif(64 != MPFR_LDBL_DIG) {
    my $dig = MPFR_LDBL_DIG;
    warn "\n$dig != 64\n";
    if($mess =~ /^2nd arg \(/) {print "ok 1\n"}
    else {
      warn "\n\$\@: $mess\n";
      print "not ok 1\n";
    }
  }
  else {
    warn "\n\$\@: $mess\n";
    print "not ok 1\n";
  }

  warn "\nSkipping tests 2-4\n";
  print "ok 2\nok 3\nok 4\n";

}
else {

  my $hex = join '', @bytes;

  if($hex eq '40009333333333333333') {print "ok 1\n"}
  else {
    warn "expected 40009333333333333333, got $hex";
    print "not ok 1\n";
  }

  @bytes = Math::MPFR::_ld_bytes('2.93', 64);
  $hex = join '', @bytes;

  if($hex eq '4000bb851eb851eb851f') {print "ok 2\n"}
  else {
    warn "expected 4000bb851eb851eb851f, got $hex";
    print "not ok 2\n";
  }

  eval{Math::MPFR::_ld_bytes('2.93', 63);};

  if($@ =~ /^2nd arg to Math::MPFR::_ld_bytes must be 64/) {print "ok 3\n"}
  else {
    warn "\nIn Math::MPFR::_ld_bytes: $@\n";
    print "not ok 3\n";
  }

  eval{Math::MPFR::_ld_bytes(2.93, 64);};

  if($@ =~ /^1st arg supplied to Math::MPFR::_ld_bytes is not a string/) {print "ok 4\n"}
  else {
    warn "\nIn Math::MPFR::_ld_bytes: $@\n";
    print "not ok 4\n";
  }

}

#####################################################
#####################################################

eval {@bytes = Math::MPFR::_f128_bytes('2.3', 113);};

if($@) {

  my $mess = $@;

  my $dd = 0;
  my $nv1 = 1.0;
  my $nv2 = $nv1 + (2 ** -1000);
  $dd = 1 if $nv2 != $nv1;

  if($Config{longdblkind} == 6 || $dd == 1) {
    warn "\ndouble-double detected\n";
    if($mess =~ /^__float128 support not built into this Math::MPFR/) {print "ok 5\n"}
    else {
      warn "\n\$\@: $mess\n";
      print "not ok 5\n";
    }
  }
  elsif(113 != MPFR_FLT128_DIG) {
    my $dig = MPFR_FLT128_DIG;
    warn "\n$dig != 113\n";
    if($mess =~ /^2nd arg \(/) {print "ok 5\n"}
    else {
      warn "\n\$\@: $mess\n";
      print "not ok 5\n";
    }
  }
  else {
    warn "\n\$\@: $mess\n";
    print "not ok 5\n";
  }

  warn "\nSkipping tests 6-8\n";
  print "ok 6\nok 7\nok 8\n";

}
else {

  my $hex = join '', @bytes;

  if($hex eq '40002666666666666666666666666666') {print "ok 5\n"}
  else {
    warn "expected 40002666666666666666666666666666, got $hex";
    print "not ok 5\n";
  }

  @bytes = Math::MPFR::_f128_bytes('2.93', 113);
  $hex = join '', @bytes;

  if($hex eq '4000770a3d70a3d70a3d70a3d70a3d71') {print "ok 6\n"}
  else {
    warn "expected 4000770a3d70a3d70a3d70a3d70a3d71, got $hex";
    print "not ok 6\n";
  }

  eval{Math::MPFR::_f128_bytes('2.93', 63);};

  if($@ =~ /^2nd arg to Math::MPFR::_f128_bytes must be 113/) {print "ok 7\n"}
  else {
    warn "\nIn Math::MPFR::_f128_bytes: $@\n";
    print "not ok 7\n";
  }

  eval{Math::MPFR::_f128_bytes(2.93, 113);};

  if($@ =~ /^1st arg supplied to Math::MPFR::_f128_bytes is not a string/) {print "ok 8\n"}
  else {
    warn "\nIn Math::MPFR::_f128_bytes: $@\n";
    print "not ok 8\n";
  }

}

my $now = Rmpfr_get_default_prec();

if($now == $arb) {print "ok 9\n"}
else {
  warn "Default precision has changed from $arb to $now\n";
  print "not ok 9\n";
}



