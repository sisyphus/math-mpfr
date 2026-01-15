# Testing of Rmpfr_fpif_export_mem() and Rmpfr_fpif_import_mem
# which were added mpfr-4.3.0.
# Testing of Rmpfr_fpif_export() and Rmpfr_fpif_import(), which
# were added in mpfr-4.0.0, is performed in new_in_4.0.0.t

use strict;
use warnings;

use Math::MPFR qw(:mpfr);

use Test::More;

my $len = 16;
my $string = chr(0) x $len;

my $op = Rmpfr_init2(100);   # 100-bit precision;

my $rop = Math::MPFR->new(); # 53-bit precision

Rmpfr_const_pi($op, MPFR_RNDN);

if(262912 > MPFR_VERSION) {
  eval { my $ret = Rmpfr_fpif_export_mem($string, $len, $op);};
  like($@, qr/^Rmpfr_fpif_export_mem not implemented/, "Test 1 ok");

  eval{ my $ret = Rmpfr_fpif_import_mem($rop, $string, $len);};
  like($@, qr/^Rmpfr_fpif_import_mem not implemented/, "Test 2 ok");
}
else {
  my $ret = Rmpfr_fpif_export_mem($string, $len, $op);
  cmp_ok($ret, '==', 0, "Test 1 export ok");

  $ret = Rmpfr_fpif_import_mem($rop, $string, $len);
  cmp_ok($ret, '==', 0, "Test 2 import ok");

  cmp_ok(ref($rop), 'eq', 'Math::MPFR', "Test 3 import returned a Math::MPFR object");
  cmp_ok(Rmpfr_get_prec($rop), '==', 100, "Test 4 precision altered to 100");
  cmp_ok($rop, '==', $rop, "Test 5 value survived round trip");

  # Check that this string equates with what gets written to file by Rmpfr_fpif_export.

  my $file = 'fpif_mem.txt';
  my $check = '';

  my $success = open my $wr, '>', $file;
  if($success) {
    binmode($wr);

    $ret = Rmpfr_fpif_export($wr, $op);
    cmp_ok($ret, '==', 0, "Test 5 - Export to file ok");

    $success = open my $rd, '<', $file;
    if($success) {
      $check = <$rd>;
      # Remove the NULL padding that $string might contain
      # before comparing $check with $string.
      #while ( length($string) > length($check) ) {
      #  if( substr($string, -1, 1) eq chr(0)) {chop $string}
      #  else {last}
      #}

      cmp_ok($string, 'eq', $check, "Test 6 - buffer content matches file content");
    }
    else { warn "Failed to open $file for reading: $!" };
  }
  else {
    warn "Failed to open $file for writing: $!";
  }

  #####################################################
  my $emin = Rmpfr_get_emin();
  my @exps = ($emin);
  while ($emin < -5) {
    $emin = int($emin / (3 + int(rand(4))) );
    push @exps, $emin;
  }

  #my $emax = Rmpfr_get_emax();
  #my @exps = ($emax);
  #while ($emax > 5) {
  #  $emax = int($emax / 5);
  #  push @exps, $emax;
  #}

  my $max_prec = 1e8;
  $max_prec = RMPFR_PREC_MAX if RMPFR_PREC_MAX < $max_prec;
  my @precs = ($max_prec);

  while ($max_prec > 5) {
    $max_prec = int($max_prec / (3 + int(rand(4))) );
    push @precs, $max_prec;
  }

  #print "@precs\n@exps\n";

  my $irregular_string = chr(0) x 7;
  for(my $i = scalar(@precs) - 1; $i >= 0; $i--) {
    my $obj = Rmpfr_init2($precs[$i]);
    cmp_ok(Rmpfr_fpif_export_mem($irregular_string, 7, $obj), '==', 0, "7 OK for NaN prec $precs[$i] and exponent " . Rmpfr_get_exp($obj));

    Rmpfr_set_inf($obj, 1);
    cmp_ok(Rmpfr_fpif_export_mem($irregular_string, 7, $obj), '==', 0, "7 OK for +Inf prec $precs[$i] and exponent " . Rmpfr_get_exp($obj));
    Rmpfr_set_inf($obj, -1);
    cmp_ok(Rmpfr_fpif_export_mem($irregular_string, 7, $obj), '==', 0, "7 OK for -Inf prec $precs[$i] and exponent " . Rmpfr_get_exp($obj));

    Rmpfr_set_zero($obj, 1);
    cmp_ok(Rmpfr_fpif_export_mem($irregular_string, 7, $obj), '==', 0, "7 OK for +0 prec $precs[$i] and exponent " . Rmpfr_get_exp($obj));
    Rmpfr_set_inf($obj, -1);
    cmp_ok(Rmpfr_fpif_export_mem($irregular_string, 7, $obj), '==', 0, "7 OK for -0 prec $precs[$i] and exponent " . Rmpfr_get_exp($obj));

    Rmpfr_strtofr($obj, '0.1', 10, MPFR_RNDN);

    for(my $j = scalar(@exps) - 1; $j >= 0; $j--) {
      Rmpfr_set_exp($obj, $exps[$j]);
      my $size = Rmpfr_fpif_size($obj);
      my $s = chr(0) x $size;
      cmp_ok(Rmpfr_fpif_export_mem($s, $size + 1, $obj), '==', 0, "$size OK for prec $precs[$i] and exponent $exps[$j]");
    }
  }
  #####################################################


#####################
}
done_testing();
#####################

