# Keep an eye on the precisions of the objects that "op" and "op="
# overloading returns. (Just in case something changes.)

use strict;
use warnings;
use Math::MPFR qw(:mpfr);

use Test::More;

my $fixed_prec = Rmpfr_init2(100);
Rmpfr_set_ui($fixed_prec, 42, MPFR_RNDN); # precision of 100 bits

{
  my $x = $fixed_prec + 0;
  cmp_ok($x, '==', 42, "value ok for '+'");
  cmp_ok(Rmpfr_get_prec($x), '==', 53, "prec ok for '+'");

  $fixed_prec += 0;
  cmp_ok(Rmpfr_get_prec($fixed_prec), '==', 100, "prec ok for '+='");
}

{
  my $x = $fixed_prec - 0;
  cmp_ok($x, '==', 42, "value ok for '-'");
  cmp_ok(Rmpfr_get_prec($x), '==', 53, "prec ok for '-'");

  $fixed_prec -= 0;
  cmp_ok(Rmpfr_get_prec($fixed_prec), '==', 100, "prec ok for '-='");
}

{
  my $x = $fixed_prec * 1;
  cmp_ok($x, '==', 42, "value ok for '*'");
  cmp_ok(Rmpfr_get_prec($x), '==', 53, "prec ok for '*'");

  $fixed_prec *= 1;
  cmp_ok(Rmpfr_get_prec($fixed_prec), '==', 100, "prec ok for '*='");
}

{
  my $x = $fixed_prec / 1;
  cmp_ok($x, '==', 42, "value ok for '/'");
  cmp_ok(Rmpfr_get_prec($x), '==', 53, "prec ok for '/'");

  $fixed_prec /= 1;
  cmp_ok(Rmpfr_get_prec($fixed_prec), '==', 100, "prec ok for '/='");
}

{
  my $x = $fixed_prec % 50;
  cmp_ok($x, '==', 42, "value ok for '%'");
  cmp_ok(Rmpfr_get_prec($x), '==', 53, "prec ok for '%'");

  $fixed_prec %= 50;
  cmp_ok($fixed_prec, '==', 42, "value ok for '%='");
  cmp_ok(Rmpfr_get_prec($fixed_prec), '==', 100, "prec ok for '%='");
}

{
  my $x = $fixed_prec ** 1;
  cmp_ok($x, '==', 42, "value ok for '**'");
  cmp_ok(Rmpfr_get_prec($x), '==', 53, "prec ok for '**'");

  $fixed_prec **= 1;
  cmp_ok($fixed_prec, '==', 42, "value ok for '**='");
  cmp_ok(Rmpfr_get_prec($fixed_prec), '==', 100, "prec ok for '**='");
}

done_testing();
