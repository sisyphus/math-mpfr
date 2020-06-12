
use warnings;
use strict;
use Math::MPFR qw(:mpfr);
use POSIX;

print "1..5\n";

my $have_new = 1;
my ($inex, $p, $ret, $ok);
my $rop = Math::MPFR->new();

if(!defined(MPFR_VERSION) || 262400 > MPFR_VERSION) {$have_new = 0} # mpfr version is pre 4.1.0

my @op1 = (Math::MPFR->new(200), Math::MPFR->new(-3), Math::MPFR->new(1001));
my @op2 = (Math::MPFR->new(5), Math::MPFR->new(30), Math::MPFR->new(90));


eval {$inex = Rmpfr_dot($rop, \@op1, \@op2, scalar(@op2), MPFR_RNDN);};

if($have_new) {
  if($rop == 91000) {print "ok 1\n"}
  else {
    warn "\nExpected 91000\nGot $rop\n";
    print "not ok 1\n";
  }

  if($inex == 0) {print "ok 2\n"}
  else {
    warn "\nExpected inex == 0\nGot inex == $inex\n";
    print "not ok 2\n";
  }

  push(@op1, 1);

  eval{$inex = Rmpfr_dot($rop, \@op1, \@op2, scalar(@op2) + 1, MPFR_RNDN);};

  if($@ =~ /^2nd last arg to Rmpfr_dot is too large/) {print "ok 3\n"}
  else {
    warn "\n \$\@:\n$@\n";
    print "not ok 3\n";
  }
}
else {
  if($@ =~ /^The Rmpfr_dot function requires mpfr\-4\.1\.0/) {print "ok 1\n"}
  else {
    warn "\n\$\@:\n $@\n";
    print "not ok 1\n";
  }

  warn "\n Skipping tests 2 & 3 - we don't have mpfr-4.1.0 or later\n";
  print "ok 2\nok 3\n";
}

eval {$p = Rmpfr_get_str_ndigits(5, 100);};

if($have_new) {
  my $expected = 1 + POSIX::ceil(100 * log(2) / log(5));
  if($expected == $p) {print "ok 4\n"}
  else {
    warn "\n Expected $expected, got $p\n";
    print "not ok 4\n";
  }
}
else {
  if($@ =~ /^The Rmpfr_get_str_ndigits function requires mpfr\-4\.1\.0/) {print "ok 4\n"}
  else {
    warn "\n \$\@:\n $@\n";
    print "not ok 4\n";
  }
}

$ok = 1;

my $pnan = Math::MPFR->new();              # NaN
my $nnan = Math::MPFR->new();
Rmpfr_setsign($nnan, $pnan, 1, MPFR_RNDN); # -NaN
my $pinf = Math::MPFR->new(1) / 0;         # Inf
my $ninf = Math::MPFR->new();
Rmpfr_setsign($ninf, $pinf, 1, MPFR_RNDN); # -Inf
my $preal = Math::MPFR->new(2);            # 2
my $nreal = Math::MPFR->new(-2);           # -2
my $pzero = Math::MPFR->new(0);            # 0
my $nzero = Math::MPFR->new(-0.0);         # - 0

eval {$ret = Rmpfr_total_order_p($nnan, $pnan);};

if($have_new) {

  for([$nnan, $ninf],   [$ninf, $nreal], [$nreal, $nzero], [$nzero, $pzero],
      [$pzero, $preal], [$preal, $pinf], [$pinf, $pnan],   [$nnan, $pnan]) {
    my @x = @{$_};
    if(!Rmpfr_total_order_p($x[0], $x[1])) {
      warn "$x[0] is not less than or equal to $x[1]\n";
      $ok = 0;
    }

    if(Rmpfr_total_order_p($x[1], $x[0])) {
      warn "$x[1] <= $x[0]\n";
     $ok = 0;
    }
  }

  for([$nnan, $nnan],   [$pnan, $pnan]) {
    my @x = @{$_};
    if(!Rmpfr_total_order_p($x[0], $x[1])) {
      warn "$x[0] is not less than or equal to $x[1]\n";
      $ok = 0;
    }

    if(!Rmpfr_total_order_p($x[1], $x[0])) {
      warn "$x[1] is not less than or equal to $x[0]\n";
     $ok = 0;
    }
  }

  if($ok) { print "ok 5\n" }
  else    { print "not ok 5\n" }
}

else {

  if($@ =~ /Rmpfr_total_order_p function requires/) { print "ok 5\n" }
  else {
    warn "\$\@: $@\n";
    print "not ok 5\n";
  }
}
