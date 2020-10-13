use strict;
use warnings;
use Math::MPFR qw(:mpfr);
use Test::More;

# With version 4 and later of mpfr, minimum precision is 1.
# For version 3 and earlier, minimum precision is 2.
my $prec_correction = 0;
$prec_correction++ if 4 > MPFR_VERSION_MAJOR;

if(Math::MPFR::MPFR_3_1_6_OR_LATER) {

  cmp_ok(decimalize(get_exact_decimal(Math::MPFR->new())), 'eq', 'NaN',
         'NaN decimalizes as expected');

  cmp_ok(decimalize(get_exact_decimal(Math::MPFR->new('inf' + 0))), 'eq', 'Inf',
         'Inf decimalizes as expected');

  cmp_ok(decimalize(get_exact_decimal(Math::MPFR->new('-inf' + 0))), 'eq', '-Inf',
         '-Inf decimalizes as expected');

  cmp_ok(decimalize(get_exact_decimal(Math::MPFR->new(0))), 'eq', '0',
        '0 decimalizes as expected');

  cmp_ok(decimalize(get_exact_decimal(Math::MPFR->new('-0'))), 'eq', '-0',
        '-0 decimalizes as expected');

  for my $v (1 .. 1290) {

   my $exp =  $v < 900 ? int(rand(25))
                     : int(rand(5000));

   $exp = -$exp if $v % 3;
   my $x = 1 + int(rand(100000));
   my $z = 5 - length($x);
   my $s1 = '0.' . ('0' x $z) . "${x}e${exp}";
   my $s2 = int(rand(500)) . "." . ('0' x $z) . "${x}e${exp}";
   my $s3 = '1' . ('0' x $z) . "${x}e${exp}";

   unless($v % 5) {
     for my $string($s1, $s2, $s3) { $string = '-' . $string }
   }

   my $prec;
   $prec = $v < 10 ? $v + $prec_correction
                   : 1 + int(rand(200));
   Rmpfr_set_default_prec($prec);

   my $f1 = Math::MPFR->new($s1);
   my $f2 = Math::MPFR->new($s2);
   my $f3 = Math::MPFR->new($s3);

   my @f1 = get_exact_decimal($f1);
   my @f2 = get_exact_decimal($f2);
   my @f3 = get_exact_decimal($f3);

   cmp_ok(check_exact_decimal($f1, @f1), '==', 1, "'$s1', at precision $prec, decimalized as expected");
   cmp_ok(check_exact_decimal($f2, @f2), '==', 1, "'$s2', at precision $prec, decimalized as expected");
   cmp_ok(check_exact_decimal($f3, @f3), '==', 1, "'$s3', at precision $prec, decimalized as expected");

   ok(decimalize(@f1) =~ /^\-?[1-9]\.\d/, "'$s1', at precision $prec, begins as expected");
   ok(decimalize(@f1) =~ /\de\-?\d/, "'$s1', at precision $prec, has an exponent");

   ok(decimalize(@f2) =~ /^\-?[1-9]\.\d/, "'$s2', at precision $prec, begins as expected");
   ok(decimalize(@f2) =~ /\de\-?\d/, "'$s2', at precision $prec, has an exponent");

   ok(decimalize(@f3) =~ /^\-?[1-9]\.\d/, "'$s3', at precision $prec, begins as expected");
   ok(decimalize(@f3) =~ /\de\-?\d/, "'$s3', at precision $prec, has an exponent");

  }
}

else {
    warn " Unable to validate decimalize() results.\n";
    warn " check_exact_decimal() requires mpfr-3.1.6 or later.\n";
    warn " Math::MPFR was built against mpfr-", MPFR_VERSION_STRING, ".";

    eval { check_exact_decimal(get_exact_decimal(Math::MPFR->new(23.2))) };

    ok( $@ =~ m/Math::MPFR was built against mpfr-/, '$@ set as expected' );

}

done_testing();
