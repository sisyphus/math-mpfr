# Provide one or more floating point values on the command line (@ARGV) and see those
# values represented in doubledouble big endian format.
# The subs dd_str() and dd_obj() return both doubles ($msd, $lsd) - where $msd is the most
# significant double and $lsd the least significant double

use warnings;
use strict;

use Math::MPFR qw(:mpfr);

eval {require Data::Float;};

my $have_fd = $@ ? 0 : 1;

die "Must provide at least one command line argument" if !@ARGV;

Rmpfr_set_default_prec(2098); # Max precision that can be encapsulated in doubledouble

for my $float(@ARGV) {
  my($msd, $lsd) = dd_str($float);
  print "$float\n$msd $lsd\n";
  print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
    if $have_fd;
  print scalar(reverse(unpack("h*", (pack "d<", $msd)))) .  " ";
  print scalar(reverse(unpack("h*", (pack "d<", $lsd)))) .  "\n\n";
}

print "Now we'll print out the exponential e in doubledouble big endian format:\n\n";

my $e = Math::MPFR->new(1);
Rmpfr_exp($e, $e, MPFR_RNDN);

my($msd, $lsd) = dd_obj($e);
print "e\n$msd $lsd\n";
print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
  if $have_fd;
print scalar(reverse(unpack("h*", (pack "d<", $msd)))) .  " ";
print scalar(reverse(unpack("h*", (pack "d<", $lsd)))) .  "\n\n";

print "Now we'll print out sqrt(2) in doubledouble big endian format:\n\n";

my $s = Math::MPFR->new(2);
$s **= 0.5;

($msd, $lsd) = dd_obj($s);
print "sqrt(2)\n$msd $lsd\n";
print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
  if $have_fd;
print scalar(reverse(unpack("h*", (pack "d<", $msd)))) .  " ";
print scalar(reverse(unpack("h*", (pack "d<", $lsd)))) .  "\n\n";

print "And, print out 2**1023 - 2**-1074 in doubledouble big endian format:\n\n";

my $max_prec = Math::MPFR->new(2 ** 1023);
$max_prec -= (2 ** -1074);

($msd, $lsd) = dd_obj($max_prec);
print "2098-bit precision value\n$msd $lsd\n";
print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
  if $have_fd;
print scalar(reverse(unpack("h*", (pack "d<", $msd)))) .  " ";
print scalar(reverse(unpack("h*", (pack "d<", $lsd)))) .  "\n\n";

print "Finally, for the unwary, note eg that dd_obj(Math::MPFR->new(1.23)) and\n",
      "dd_obj(Math::MPFR->new('1.23') return different values. The former:\n\n";

($msd, $lsd) = dd_obj(Math::MPFR->new(1.23));

print "$msd $lsd\n\n and the latter:\n\n";

($msd, $lsd) = dd_obj(Math::MPFR->new('1.23'));

print "$msd $lsd\n";


# sub dd_str takes a string as its arg
sub dd_str {
  my $val = Math::MPFR->new($_[0]);
  my $msd = Rmpfr_get_d($val, MPFR_RNDN);
  $val -= $msd;
  return ($msd, Rmpfr_get_d($val, MPFR_RNDN));
}

# sub dd_obj takes a Math::MPFR object (with 2098-bit precision) as its arg
sub dd_obj {
  my $obj = shift;
  my $msd = Rmpfr_get_d($obj, MPFR_RNDN);
  $obj -= $msd;
  return ($msd, Rmpfr_get_d($obj, MPFR_RNDN));
}


__END__

For me, running this script as "perl doubledouble.p 1.1 1.23 123e-2"
on my Windows 7 box (where nvtype is "double") outputs:

1.1
1.1 -8.88178419700125e-017
+0x1.199999999999ap+0 -0x1.999999999999ap-54
3ff199999999999a bc9999999999999a

1.23
1.23 1.77635683940025e-017
+0x1.3ae147ae147aep+0 +0x1.47ae147ae147bp-56
3ff3ae147ae147ae 3c747ae147ae147b

123e-2
1.23 1.77635683940025e-017
+0x1.3ae147ae147aep+0 +0x1.47ae147ae147bp-56
3ff3ae147ae147ae 3c747ae147ae147b

Now we'll print out the exponential e in doubledouble big endian format:

e
2.71828182845905 1.44564689172925e-016
+0x1.5bf0a8b145769p+1 +0x1.4d57ee2b1013ap-53
4005bf0a8b145769 3ca4d57ee2b1013a

Now we'll print out sqrt(2) in doubledouble big endian format:

sqrt(2)
1.4142135623731 -9.66729331345291e-017
+0x1.6a09e667f3bcdp+0 -0x1.bdd3413b26456p-54
3ff6a09e667f3bcd bc9bdd3413b26456

And, print out 2**1023 - 2**-1074 in doubledouble big endian format:

2098-bit precision value
8.98846567431158e+307 -4.94065645841247e-324
+0x1.0000000000000p+1023 -0x0.0000000000001p-1022
7fe0000000000000 8000000000000001

Finally, for the unwary, note eg that dd_obj(Math::MPFR->new(1.23)) and
dd_obj(Math::MPFR->new('1.23') return different values. The former:

1.23 0

 and the latter:

1.23 1.77635683940025e-017

C:\sisyphusion\working\math-mpfr\Math-MPFR-3.24\demos>perl doubledouble.p 1.1 1.
23 123e-2
1.1
1.1 -8.88178419700125e-017
+0x1.199999999999ap+0 -0x1.999999999999ap-54
3ff199999999999a bc9999999999999a

1.23
1.23 1.77635683940025e-017
+0x1.3ae147ae147aep+0 +0x1.47ae147ae147bp-56
3ff3ae147ae147ae 3c747ae147ae147b

123e-2
1.23 1.77635683940025e-017
+0x1.3ae147ae147aep+0 +0x1.47ae147ae147bp-56
3ff3ae147ae147ae 3c747ae147ae147b

Now we'll print out the exponential e in doubledouble big endian format:

e
2.71828182845905 1.44564689172925e-016
+0x1.5bf0a8b145769p+1 +0x1.4d57ee2b1013ap-53
4005bf0a8b145769 3ca4d57ee2b1013a

Now we'll print out sqrt(2) in doubledouble big endian format:

sqrt(2)
1.4142135623731 -9.66729331345291e-017
+0x1.6a09e667f3bcdp+0 -0x1.bdd3413b26456p-54
3ff6a09e667f3bcd bc9bdd3413b26456

And, print out 2**1023 - 2**-1074 in doubledouble big endian format:

2098-bit precision value
8.98846567431158e+307 -4.94065645841247e-324
+0x1.0000000000000p+1023 -0x0.0000000000001p-1022
7fe0000000000000 8000000000000001

Finally, for the unwary, note eg that dd_obj(Math::MPFR->new(1.23)) and
dd_obj(Math::MPFR->new('1.23')) return different values. The former:

1.23 0

 and the latter:

1.23 1.77635683940025e-017
