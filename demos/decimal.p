
# Use Math::MPFR to perform decimal arithmetic.
# (Involves continually converting between
# Math:MPFR objects and Math::Decimal64 objects,
# which can be tedious.)

use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Math::Decimal64 qw(:all);

##########################################
# MPFR arithmetic must have precision of
# at least 55 bits for the purpose of
# performing decimal arithmetic.
##########################################

Rmpfr_set_default_prec(55);

##########################################
# DEMO 1:
# Do 0.3 - 0.2 - 0.1 in decimal arithmetic
# (In binary double precision arithemtic,
# this calcualtion produces a non-zero
# result.)
# First, create our variables.
##########################################

my($one, $two, $three) = (Math::MPFR->new(), Math::MPFR->new(), Math::MPFR->new());
my $d64 = Math::Decimal64->new();

##########################################
# Assign the values to the variables
##########################################

Rmpfr_set_DECIMAL64($one, Math::Decimal64->new('0.1'), MPFR_RNDN);
Rmpfr_set_DECIMAL64($two, Math::Decimal64->new('0.2'), MPFR_RNDN);
Rmpfr_set_DECIMAL64($three, Math::Decimal64->new('0.3'), MPFR_RNDN);

##########################################
# Do 0.3 - 0.2 and convert the result to a
# __Decimal64 value (which is held by the
# Math::Decimal64 object, $d64
##########################################

Rmpfr_get_DECIMAL64($d64, $three - $two, MPFR_RNDN);

##########################################
# Overwrite the original value of $three
# with the _Decimal64 value held by $d64
#########################################

Rmpfr_set_DECIMAL64($three, $d64, MPFR_RNDN);

##########################################
# Now subtract 0.1, and convert the result
# to a _Decimal64 object, saved in $d64
##########################################

Rmpfr_get_DECIMAL64($d64, $three - $one, MPFR_RNDN);

print $d64, "\n"; # Prints zero.

##########################################
# DEMO 2:
# Get the _Decimal64 square root of 3
##########################################

Rmpfr_get_DECIMAL64($d64, sqrt(Math::MPFR->new(3)), MPFR_RNDN);
print $d64, " ", $d64 * $d64, "\n"; # prints "1732050807568877e-15 2999999999999999e-15"

##########################################
# DEMO 3:
# Get the _Decimal64 log of 2
##########################################

Rmpfr_get_DECIMAL64($d64, log(Math::MPFR->new(2)), MPFR_RNDN);
print $d64, "\n"; # prints "6931471805599453e-16"





