use warnings;
use strict;
use Math::MPFR qw(:mpfr);

print "1..2\n";

print  "# Using Math::MPFR version ", $Math::MPFR::VERSION, "\n";
print  "# Using mpfr library version ", MPFR_VERSION_STRING, "\n";
print  "# Using gmp library version ", Math::MPFR::gmp_v(), "\n";

my $ok = '';

Rmpfr_set_overflow();
if(Rmpfr_overflow_p()) {$ok .= 'a'}
Rmpfr_clear_overflow();
if(!Rmpfr_overflow_p()) {$ok .= 'b'}

Rmpfr_set_underflow();
if(Rmpfr_underflow_p()) {$ok .= 'c'}
Rmpfr_clear_underflow();
if(!Rmpfr_underflow_p()) {$ok .= 'd'}

Rmpfr_set_inexflag();
if(Rmpfr_inexflag_p()) {$ok .= 'e'}
Rmpfr_clear_inexflag();
if(!Rmpfr_inexflag_p()) {$ok .= 'f'}

Rmpfr_set_erangeflag();
if(Rmpfr_erangeflag_p()) {$ok .= 'g'}
Rmpfr_clear_erangeflag();
if(!Rmpfr_erangeflag_p()) {$ok .= 'h'}

Rmpfr_set_nanflag();
if(Rmpfr_nanflag_p()) {$ok .= 'i'}
Rmpfr_clear_nanflag();
if(!Rmpfr_nanflag_p()) {$ok .= 'j'}

if($ok eq 'abcdefghij') {print "ok 1\n"}
else {print "not ok 1\n"}

my $zero = Math::MPFR->new(0);
my $inf = Math::MPFR->new(1);

$ok = '';

$inf /= $zero;

Rmpfr_clear_overflow();
if(!Rmpfr_overflow_p()) {$ok .= 'a'}
Rmpfr_check_range($inf, 123, GMP_RNDN);
if(Rmpfr_overflow_p()) {$ok .= 'b'}

$inf *= -1;

Rmpfr_clear_overflow();
if(!Rmpfr_overflow_p()) {$ok .= 'c'}
Rmpfr_check_range($inf, 123, GMP_RNDN);
if(Rmpfr_overflow_p()) {$ok .= 'd'}

if($ok eq 'abcd') {print "ok 2\n"}
else {print "not ok 2 $ok\n"}
