# Add various tests here as they come to mind.

use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Config;
use Test::More;

if($] < 5.03 && $Config{nvtype} ne '__float128') {
  plan skip_all => "Perl's string to NV assignment is unreliable\n";
}

else {

  plan tests => 8;

  my $m = 9.007199254740991e15; # 2 ** 53

  cmp_ok(nvtoa(2 ** 105), '==', 2 ** 105, "nvtoa(2 ** 105) == 2 ** 105");
  cmp_ok(nvtoa(2 ** 106), '==', 2 ** 106, "nvtoa(2 ** 106) == 2 ** 106");

  cmp_ok(nvtoa($m * (2 ** 53)), '==', $m * (2 ** 53), "nvtoa($m*(2**53)) == $m*(2**53)");
  cmp_ok(nvtoa($m * (2 ** 54)), '==', $m * (2 ** 54), "nvtoa($m*(2**54)) == $m*(2**54)");

  cmp_ok(nvtoa(2 ** 120), '==', 2 ** 120, "nvtoa(2 ** 120) == 2 ** 120");

  cmp_ok(nvtoa(29 * (2 ** 1001)), '==', 29 * (2 ** 1001), "nvtoa(29 * (2 ** 1001)) == 29 * (2 ** 1001)");

  cmp_ok(nvtoa(1.7976931348623157e+308), '==', 1.7976931348623157e+308, "nvtoa(DBL_MAX) == DBL_MAX");

  cmp_ok(nvtoa(123456789012345.0), '==', 123456789012345.0, "nvtoa(123456789012345.0) == 123456789012345.0");

}
