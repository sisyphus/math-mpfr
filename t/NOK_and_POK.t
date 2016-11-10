use strict;
use warnings;
use Math::MPFR qw(:mpfr);

print "1..4\n";

my $n = '98765' x 80;
my $r = '98765' x 80;
my $z;

if($n > 0) { # sets NV slot to inf, and turns on the NOK flag
  $z = Math::MPFR->new($n);
}

if($z == $r) {print "ok 1\n"}
else {
  warn "$z != $r\n";
  print "not ok 1\n";
}

my $inf = 999**(999**999); # value is inf, NOK flag is set.
my $nan = $inf / $inf; # value is nan, NOK flag is set.



eval{"$inf"}; # POK flag is now also set for $inf
eval{"$nan"}; # POK flag is now also set for $nan

$z = Math::MPFR->new($inf);

if(Rmpfr_inf_p($z)) {print "ok 2\n"}
else {
  warn "\n Expected inf\n Got $z\n";
  print "not ok 2\n";
}

if($z == $inf) {print "ok 3\n"}
else {
  warn "$z != inf\n";
  print "not ok 3\n";
}

my $z2 = Math::MPFR->new($nan);

if(Rmpfr_nan_p($z2)) {print "ok 4\n"}
else {
  warn "\n Expected nan\n Got $z2\n";
  print "not ok 4\n";
}

