# Provide one or more floating point values on the command line (@ARGV) and see those
# values represented in doubledouble big endian format.
# The subs dd_str() and dd_obj() return both doubles ($msd, $lsd) - where $msd is the most
# significant double and $lsd the least significant double. The actual value represented by
# the double is the sum of the two doubles.
# The correctness of this script relies on precision being set (at line 19) to 2098 bits.

use warnings;
use strict;

use Math::MPFR qw(:mpfr);

eval {require Data::Float;};

my $have_fd = $@ ? 0 : 1;

die "Must provide at least one command line argument" if !@ARGV;

Rmpfr_set_default_prec(2098); # Max precision that can be encapsulated in doubledouble

for my $float(@ARGV) {
  my($msd, $lsd) = dd_str($float);
  print "$float\n";
  printf "%.14e %.14e\n", $msd, $lsd;
  print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
    if $have_fd;
  print internal_hex($msd) .  " ";
  print internal_hex($lsd) .  "\n\n";
}

print "Now we'll print out the exponential e in doubledouble big endian format:\n\n";

my $e = Math::MPFR->new(1);
Rmpfr_exp($e, $e, MPFR_RNDN);

my($msd, $lsd) = dd_obj($e);
print "e\n";
printf "%.14e %.14e\n", $msd, $lsd;
print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
  if $have_fd;
print internal_hex($msd) .  " ";
print internal_hex($lsd) .  "\n\n";

print "Now we'll print out sqrt(2) in doubledouble big endian format:\n\n";

my $s = Math::MPFR->new(2);
$s **= 0.5;

($msd, $lsd) = dd_obj($s);
print "sqrt(2)\n";
printf "%.14e %.14e\n", $msd, $lsd;
print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
  if $have_fd;
print internal_hex($msd) .  " ";
print internal_hex($lsd) .  "\n\n";

print "And, print out 2**1023 - 2**-1074 in doubledouble big endian format:\n\n";

my $max_prec = Math::MPFR->new(2 ** 1023);
$max_prec -= (2 ** -1074);

($msd, $lsd) = dd_obj($max_prec);
print "2098-bit precision value\n";
printf "%.14e %.14e\n", $msd, $lsd;
print Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
  if $have_fd;
print internal_hex($msd) .  " ";
print internal_hex($lsd) .  "\n\n";

print "For the unwary, note eg that dd_obj(Math::MPFR->new(1.23)) and\n",
      "dd_obj(Math::MPFR->new('1.23') return different values (unless your perl's NV\n",
      "happens to be doubledouble, __float128 or a quad long double).\n",
      "On a perl whose NV type is 'double', the former is:\n\n";

($msd, $lsd) = dd_obj(Math::MPFR->new(1.23));

printf "%.14e %.14e\n\n and the latter:\n\n", $msd, $lsd;

($msd, $lsd) = dd_obj(Math::MPFR->new('1.23'));

printf "%.14e %.14e\n", $msd, $lsd;

print "\nNext we'll take a look at how the value 9.7 + 0.02 will be represented\n",
      "as a double-double. Is it (9.7, 0.02) ?\n\n";

($msd, $lsd) = dd2dd(9.7, 0.02);
printf " %.14e %.14e\n\n", $msd, $lsd;

print "It is not. Therefore (9.7. 0.02) or (4023666666666666 3f947ae147ae147b) is\n",
      "not a valid double-double pairing. Is the double-double representation of\n",
      "9.7 + 0.02 the same as the double-double representation of 9.72 ?\n\n";

($msd, $lsd) = dd_str('9.72');
printf " %.14e %.14e\n\n", $msd, $lsd;

print "Again, the answer is, as to be expected, \"No\"\n\n";

print "Earlier we saw that the double-double (internal hex) representation of 1.1 is:\n",
      "    3ff199999999999a bc9999999999999a.\n",
      "Let's check that dd2dd() returns identical outputs for those 2 doubles:\n\n";

($msd, $lsd) = dd2dd(internal_hex2dec('3ff199999999999a'),
                     internal_hex2dec('bc9999999999999a'));

print " ", Data::Float::float_hex($msd), " ", Data::Float::float_hex($lsd), "\n"
  if $have_fd;
printf " %.14e %.14e\n\n", $msd, $lsd;

print "This time the outputs are equivalent/identical to the inputs,\n",
      "proving that the input values form a valid double-double - which\n",
      "is something we already knew, anyway,\n",
      "Note that if the hex strings are identical then the values are identical, but\n",
      "(owing to rounding) the same is not necessarily true of the decimal strings.\n";

# sub dd_str takes a string as its arg.
# Works correctly if default Math::MPFR precision is 2098 bits - else might return incorrect values.
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

# sub dd2dd takes 2 doubles as arguments. It returns the 2 doubles (msd, lsd) that form the
# double-double representation of the sum of the 2 arguments. We can therefore use this function
# to question whether the 2 arguments are a valid double-double pair - the answer being "yes" if
# and only if dd2dd() returns the identical 2 values that it received as arguments.
# In the process, it prints out the internal hex representations of both arguments, and the
# internal hex representations of the 2 doubles that it returns.
# Works correctly if default Math::MPFR precision is 2098 bits - else might return incorrect values.
sub dd2dd {
  my $val = Math::MPFR->new(0);
  print " HEX_INPUT :  ", internal_hex($_[0]), " ", internal_hex($_[1]), "\n";
  Rmpfr_add_d($val, $val, $_[0], MPFR_RNDN);
  Rmpfr_add_d($val, $val, $_[1], MPFR_RNDN);
  my @ret = dd_obj($val);
  print " HEX_OUTPUT:  ", internal_hex($ret[0]), " ", internal_hex($ret[1]), "\n";
  return @ret;
}

# sub internal_hex returns the internal hex format (byte structure) of the double precision
# argument it received.
sub internal_hex {
  return scalar(reverse(unpack("h*", (pack "d<", $_[0]))));
}

# sub internal_hex2dec does the reverse of internal_hex() - ie returns the value, derived from
# the internal hex argument.
sub internal_hex2dec {
  return unpack "d<", pack "h*", scalar reverse $_[0];
}

__END__

For me, running this script as "perl doubledouble.p 1.1 1.23 123e-2"
on my Windows 7 box (where nvtype is "double") outputs as given below.
Note that the Data::Float hex representations might append trailing zeroes to the values
if your nvtype is not double.

1.1
1.10000000000000e+000 -8.88178419700125e-017
+0x1.199999999999ap+0 -0x1.999999999999ap-54
3ff199999999999a bc9999999999999a

1.23
1.23000000000000e+000 1.77635683940025e-017
+0x1.3ae147ae147aep+0 +0x1.47ae147ae147bp-56
3ff3ae147ae147ae 3c747ae147ae147b

123e-2
1.23000000000000e+000 1.77635683940025e-017
+0x1.3ae147ae147aep+0 +0x1.47ae147ae147bp-56
3ff3ae147ae147ae 3c747ae147ae147b

Now we'll print out the exponential e in doubledouble big endian format:

e
2.71828182845905 1.44564689172925e-016
+0x1.5bf0a8b145769p+1 +0x1.4d57ee2b1013ap-53
4005bf0a8b145769 3ca4d57ee2b1013a

Now we'll print out sqrt(2) in doubledouble big endian format:

sqrt(2)
1.41421356237310 -9.66729331345291e-017
+0x1.6a09e667f3bcdp+0 -0x1.bdd3413b26456p-54
3ff6a09e667f3bcd bc9bdd3413b26456

And, print out 2**1023 - 2**-1074 in doubledouble big endian format:

2098-bit precision value
8.98846567431158e+307 -4.94065645841247e-324
+0x1.0000000000000p+1023 -0x0.0000000000001p-1022
7fe0000000000000 8000000000000001

For the unwary, note eg that dd_obj(Math::MPFR->new(1.23)) and
dd_obj(Math::MPFR->new('1.23') return different values. The former:

 1.23000000000000e+000 0.00000000000000e+000
(1.23000000000000e+000 1.77809156287623e-017 if nvtype is 80-bit prec long double)

 and the latter:

 1.23000000000000e+000 1.77635683940025e-017

Next we'll take a look at how the value 9.7 + 0.02 will be represented
as a double-double. Is it (9.7, 0.02) ?

 HEX_INPUT :  4023666666666666 3f947ae147ae147b
 HEX_OUTPUT:  402370a3d70a3d70 3cbec00000000000
 9.72000000000000e+000 4.26741975090295e-016

It is not. Therefore (9.7. 0.02) or (4023666666666666 3f947ae147ae147b) is
not a valid double-double pairing. Is the double-double representation of
9.7 + 0.02 the same as the double-double representation of 9.72 ?

 9.72000000000000e+000 -6.39488462184090e-016

Again, the answer is, as to be expected, "No"

Earlier we saw that the double-double (internal hex) representation of 1.1 is:
    3ff199999999999a bc9999999999999a.
Let's check that dd2dd() returns identical outputs for those 2 doubles:

 HEX_INPUT :  3ff199999999999a bc9999999999999a
 HEX_OUTPUT:  3ff199999999999a bc9999999999999a
 +0x1.199999999999ap+0 -0x1.999999999999ap-54
 1.10000000000000e+000 -8.88178419700125e-017

This time the outputs are equivalent/identical to the inputs,
proving that the input values form a valid double-double - which
is something we already knew, anyway,
Note that if the hex strings are identical then the values are identical, but
(owing to rounding) the same is not necessarily true of the decimal strings.
