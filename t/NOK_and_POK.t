use strict;
use warnings;
use Math::MPFR qw(:mpfr);

print "1..10\n";

my $n = '98765' x 80;
my $r = '98765' x 80;
my $z;

if(Math::MPFR::nok_pokflag() == 0) {print "ok 1\n"}
else {
  warn "\n Math::MPFR::nok_pokflag(): ", Math::MPFR::nok_pokflag(), "\n";
  print "not ok 1\n";
}

if($n > 0) { # sets NV slot to inf, and turns on the NOK flag
  $z = Math::MPFR->new($n);
}

if(Math::MPFR::nok_pokflag() == 1) {print "ok 2\n"}
else {
  warn "\n Math::MPFR::nok_pokflag(): ", Math::MPFR::nok_pokflag(), "\n";
  print "not ok 2\n";
}

if($z == $r) {print "ok 3\n"}
else {
  warn "$z != $r\n";
  print "not ok 3\n";
}

if(Math::MPFR::nok_pokflag() == 1) {print "ok 4\n"} # No change as $r is not a dualvar.
else {
  warn "\n Math::MPFR::nok_pokflag(): ", Math::MPFR::nok_pokflag(), "\n";
  print "not ok 4\n";
}

my $inf = 999**(999**999); # value is inf, NOK flag is set.
my $nan = $inf / $inf; # value is nan, NOK flag is set.



my $discard = eval{"$inf"}; # POK flag is now also set for $inf
$discard    = eval{"$nan"}; # POK flag is now also set for $nan

$z = Math::MPFR->new($inf);

if(Math::MPFR::nok_pokflag() == 2) {print "ok 5\n"}
else {
  warn "\n Math::MPFR::nok_pokflag(): ", Math::MPFR::nok_pokflag(), "\n";
  print "not ok 5\n";
}

if(Rmpfr_inf_p($z)) {print "ok 6\n"}
else {
  warn "\n Expected inf\n Got $z\n";
  print "not ok 6\n";
}

if($z == $inf) {print "ok 7\n"}
else {
  warn "$z != inf\n";
  print "not ok 7\n";
}

if(Math::MPFR::nok_pokflag() == 3) {print "ok 8\n"}
else {
  warn "\n Math::MPFR::nok_pokflag(): ", Math::MPFR::nok_pokflag(), "\n";
  print "not ok 8\n";
}

my $z2 = Math::MPFR->new($nan);

if(Math::MPFR::nok_pokflag() == 4) {print "ok 9\n"}
else {
  warn "\n Math::MPFR::nok_pokflag(): ", Math::MPFR::nok_pokflag(), "\n";
  print "not ok 9\n";
}

if(Rmpfr_nan_p($z2)) {print "ok 10\n"}
else {
  warn "\n Expected nan\n Got $z2\n";
  print "not ok 10\n";
}

