
use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Test::More;

my @in = (~0, ~0 - 1, ~0 - 10000, ~0 >> 1, (~0 >> 1) * -1, 1e6, -1e6);

for my $n (@in) {
  cmp_ok(atonum("$n"), 'eq', "$n", "atonum(\"$n\") eq \"$n\"");
  cmp_ok(atonum("$n"), '==',  $n , "atonum(\"$n\") == $n");
}

my $pinf = 99 ** (99 ** 99);
my $ninf = $pinf * -1;
my $nan  = $pinf / $pinf;
my $pzero = 0.0;
my $nzero = $pzero * -1.0;

@in = ($pinf, $ninf, $nan, $pzero, $nzero, sqrt(2), 1 / 10, 1.3e-200, -1.3e-200, 2 ** 200, -(2 ** 200));

for my $n (@in) {
  cmp_ok(atonum("$n"), 'eq', atonv("$n"),  "atonum(\"$n\") eq atonv(\"$n\")");
  next if $n != $n;
  cmp_ok(atonum("$n"), '==',  atonv("$n"), "atonum(\"$n\") == atonv(\"$n\")");
}


done_testing();
