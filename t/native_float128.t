use strict;
use warnings;
use Config;
use Math::MPFR qw(:mpfr);

my $t = 1;

if(Math::MPFR::_can_pass_float128()) {
  print "1..$t\n";
  warn "\n Can pass _float128 between perl subs and XSubs\n";
  print "ok 1\n";
}
elsif($Config{nvtype} eq '__float128') {
  print "1..$t\n";
  warn "\n Casting __float128 to long double\n";
  print "ok 1\n";
}
else {
  print "1..1\n";
  warn "\n Skipping all tests - nvtype is $Config{nvtype}\n";
  print "ok 1\n";
  exit 0;
}
