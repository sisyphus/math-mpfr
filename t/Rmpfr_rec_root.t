
use strict;
use warnings;
use Math::MPFR qw(:mpfr);

print "1..35\n";

my($inex1, $inex2, $check);
my($rop1, $rop2) = (Rmpfr_init(), Rmpfr_init());
my $root = 2;
my $op = Math::MPFR->new(17);

$inex1 = Rmpfr_rec_sqrt($rop1, $op,        MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $op, $root, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 1\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 1\n";
}

if($rop1 == $rop2) {print "ok 2\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 2\n";
}

$op *= -1; # -17

Rmpfr_clear_nanflag();

$inex1 = Rmpfr_rec_sqrt($rop1, $op,        MPFR_RNDN);

if(Rmpfr_nanflag_p()) {print "ok 3\n"}
else {print "not ok 3\n"}

Rmpfr_clear_nanflag();

$inex2 = Rmpfr_rec_root($rop2, $op, $root, MPFR_RNDN);

if(Rmpfr_nanflag_p()) {print "ok 4\n"}
else {print "not ok 4\n"}

if($inex1 == $inex2) {print "ok 5\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 5\n";
}

if(Rmpfr_nan_p($rop1) && Rmpfr_nan_p($rop2)) {print "ok 6\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 6\n";
}

$root = 5;

$inex1 = Rmpfr_root    ($rop1, $op, $root, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $op, $root, MPFR_RNDN);

$check = $rop1 * $rop2;

if($check < 1.0000001 && $check > 0.9999999) {print "ok 7\n"}
else {
  warn "\n \$check: $check\n";
  print "not ok 7\n";
}

## $op is +/- 0 ##
## root is even, root is odd, root is 0

my $pzero = Math::MPFR->new(0);
my $nzero = $pzero * -1;

$inex1 = Rmpfr_root    ($rop1, $pzero, $root, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $pzero, $root, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 8\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 8\n";
}

if($rop1 == 1 / $rop2) {print "ok 9\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 9\n";
}

$inex1 = Rmpfr_root    ($rop1, $nzero, $root, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $nzero, $root, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 10\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 10\n";
}

if($rop1 == 1 / $rop2) {print "ok 11\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 11\n";
}

$inex1 = Rmpfr_root    ($rop1, $pzero, $root - 1, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $pzero, $root - 1, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 12\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 12\n";
}

if($rop1 == 1 / $rop2) {print "ok 13\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 13\n";
}

$inex1 = Rmpfr_root    ($rop1, $nzero, $root - 1, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $nzero, $root - 1, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 14\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 14\n";
}

if($rop1 == 1 / $rop2) {print "ok 15\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 15\n";
}

$inex1 = Rmpfr_root    ($rop1, $pzero, 0, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $pzero, 0, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 16\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 16\n";
}

if($rop1 == 1 / $rop2) {print "ok 17\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 17\n";
}

## $op is +/- Inf ##
## root is even, root is odd, root is 0.

$root = 2;
Rmpfr_set_d($op, 999**(999**999), MPFR_RNDN);

$inex1 = Rmpfr_rec_sqrt($rop1, $op,        MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $op, $root, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 18\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 18\n";
}

if($rop1 == $rop2) {print "ok 19\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 19\n";
}

$op *= -1; # -Inf

$inex1 = Rmpfr_rec_sqrt($rop1, $op,        MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $op, $root, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 20\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 20\n";
}

if(Rmpfr_nan_p($rop1) && Rmpfr_nan_p($rop2)) {print "ok 21\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 21\n";
}

$root = 5;

$inex1 = Rmpfr_root    ($rop1, $op, $root, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $op, $root, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 22\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 22\n";
}

if($rop1 == 1 / $rop2) {print "ok 23\n"}
else {
  warn "\n \$check: $check\n";
  print "not ok 23\n";
}

$op *= -1; # +Inf

$inex1 = Rmpfr_root    ($rop1, $op, $root, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $op, $root, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 24\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 24\n";
}

if($rop1 == 1 / $rop2) {print "ok 25\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n";
  print "not ok 25\n";
}

$inex1 = Rmpfr_root    ($rop1, $op, $root - 1, MPFR_RNDN);
$inex2 = Rmpfr_rec_root($rop2, $op, $root - 1, MPFR_RNDN);

if($inex1 == $inex2) {print "ok 26\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 26\n";
}

if($rop1 == 1 / $rop2) {print "ok 27\n"}
else {
  warn "\n \$check: $check\n";
  print "not ok 27\n";
}

Rmpfr_clear_nanflag();

$inex1 = Rmpfr_root    ($rop1, $op, 0, MPFR_RNDN);

if(Rmpfr_nanflag_p()) {print "ok 28\n"}
else {print "not ok 28\n"}

Rmpfr_clear_nanflag();

$inex2 = Rmpfr_rec_root($rop2, $op, 0, MPFR_RNDN);

if(Rmpfr_nanflag_p()) {print "ok 29\n"}
else {print "not ok 29\n"}

if($inex1 == $inex2) {print "ok 30\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 30\n";
}

if(Rmpfr_nan_p($rop1) && Rmpfr_nan_p($rop2) && Rmpfr_nanflag_p()) {print "ok 31\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n ", Rmpfr_nanflag_p(), "\n";
  print "not ok 31\n";
}

$op *= -1; # -Inf

Rmpfr_clear_nanflag();

$inex1 = Rmpfr_root    ($rop1, $op, 0, MPFR_RNDN);

if(Rmpfr_nanflag_p()) {print "ok 32\n"}
else {print "not ok 32\n"}

Rmpfr_clear_nanflag();

$inex2 = Rmpfr_rec_root($rop2, $op, 0, MPFR_RNDN);

if(Rmpfr_nanflag_p()) {print "ok 33\n"}
else {print "not ok 33\n"}

if($inex1 == $inex2) {print "ok 34\n"}
else {
  warn "\n \$inex1: $inex1\n \$inex2: $inex2\n";
  print "not ok 34\n";
}

if(Rmpfr_nan_p($rop1) && Rmpfr_nan_p($rop2) && Rmpfr_nanflag_p()) {print "ok 35\n"}
else {
  warn "\n \$rop1: $rop1\n \$rop2: $rop2\n ", Rmpfr_nanflag_p(), "\n";
  print "not ok 35\n";
}
