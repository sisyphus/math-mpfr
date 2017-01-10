use strict;
use warnings;
use Math::MPFR qw(:mpfr);

print "1..48\n";

my $ok = 1;

for(1..10) {
  my $str = '1.';
  for(1..70) {$str .= int(rand(2));}
  $str .= '01';
  my $nstr = '-' . $str;

  my $longrop  = Rmpfr_init2(73);
  my $check    = Rmpfr_init2(72);
  my $shortrop = Rmpfr_init2(72);

  my $coderef = \&Rmpfr_set;

  my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

  if($inex) {die "Rmpfr_set_str falsely returned $inex"}

  my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded up, $longrop is exact.

  unless($shortrop > $longrop && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
  unless($shortrop == $check && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n";
  }

  $longrop *= -1;

  $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded down, $longrop is exact.

  unless($shortrop < $longrop && $ret < 0) {
   $ok = 0;
   warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
  unless($shortrop == $check && $ret < 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }
}

if($ok) {print "ok 1\n"}
else    {print "not ok 1\n"}
$ok = 1;

for(1..10) {
  my $str = '1.';
  for(1..70) {$str .= int(rand(2));}
  $str .= '011';
  my $nstr = '-' . $str;

  my $longrop = Rmpfr_init2(74);
  my $check    = Rmpfr_init2(72);
  my $shortrop = Rmpfr_init2(72);

  my $coderef = \&Rmpfr_set;

  my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

  if($inex) {die "Rmpfr_set_str falsely returned $inex"}

  my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded up, $longrop is exact.

  unless($shortrop > $longrop && $ret > 0) {
    $ok = 0;
    warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
  unless($shortrop == $check && $ret > 0) {
    $ok = 0;
    warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

  $longrop *= -1;

  $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded down, $longrop is exact.

  unless($shortrop < $longrop && $ret < 0) {
   $ok = 0;
   warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
  unless($shortrop == $check && $ret < 0) {
    $ok = 0;
    warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

}

if($ok) {print "ok 2\n"}
else    {print "not ok 2\n"}
$ok = 1;

for(1..10) {
  my $str = '1.';
  for(1..70) {$str .= int(rand(2));}
  $str .= '001';
  my $nstr = '-' . $str;

  my $longrop = Rmpfr_init2(74);
  my $check    = Rmpfr_init2(72);
  my $shortrop = Rmpfr_init2(72);

  my $coderef = \&Rmpfr_set;

  my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

  if($inex) {die "Rmpfr_set_str falsely returned $inex"}

  my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded down, $longrop is exact.

  unless($shortrop < $longrop && $ret < 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
  unless($shortrop == $check && $ret < 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

  $longrop *= -1;

  $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded up, $longrop is exact.

  unless($shortrop > $longrop && $ret > 0) {
   $ok = 0;
   warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
  unless($shortrop == $check && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

}

if($ok) {print "ok 3\n"}
else    {print "not ok 3\n"}
$ok = 1;

####################################

for my $suffix('010', '011', '110', '111') {
  for(1..10) {
    my $str = '1.';
    for(1..70) {$str .= int(rand(2));
    }
    $str .= $suffix;
    my $nstr = '-' . $str;

    my $longrop = Rmpfr_init2(74);
    my $check    = Rmpfr_init2(72);
    my $shortrop = Rmpfr_init2(72);

    my $coderef = \&Rmpfr_set;

    my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

    if($inex) {die "Rmpfr_set_str falsely returned $inex"}

    my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

    # $shortrop should always be rounded up, $longrop is exact.

    unless($shortrop > $longrop && $ret > 0) {
     $ok = 0;
     warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
    }

    $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
    unless($shortrop == $check && $ret > 0) {
     $ok = 0;
     warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
    }

    $longrop *= -1;

    $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

    # $shortrop should always be rounded down, $longrop is exact.

    unless($shortrop < $longrop && $ret < 0) {
      $ok = 0;
      warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
    }

    $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
    unless($shortrop == $check && $ret < 0) {
      $ok = 0;
      warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
    }
  }
  if($ok) {
    print "ok 4\n" if $suffix eq '010';
    print "ok 5\n" if $suffix eq '011';
    print "ok 6\n" if $suffix eq '110';
    print "ok 7\n" if $suffix eq '111';
  }
  else    {
    print "not ok 4\n" if $suffix eq '010';
    print "not ok 5\n" if $suffix eq '011';
    print "not ok 6\n" if $suffix eq '110';
    print "not ok 7\n" if $suffix eq '111';
  }
  $ok = 1;
}

####################################
####################################

for my $suffix('001', '101') {
  for(1..10) {
    my $str = '1.';
    for(1..70) {$str .= int(rand(2));}
    $str .= $suffix;
    my $nstr = '-' . $str;

    my $longrop = Rmpfr_init2(74);
    my $check    = Rmpfr_init2(72);
    my $shortrop = Rmpfr_init2(72);

    my $coderef = \&Rmpfr_set;

    my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

    if($inex) {die "Rmpfr_set_str falsely returned $inex"}

    my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

    # $shortrop should always be rounded down, $longrop is exact.

    unless($shortrop < $longrop && $ret < 0) {
      $ok = 0;
      warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
    }

    $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
    unless($shortrop == $check && $ret < 0) {
      $ok = 0;
      warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
    }

    $longrop *= -1;

    $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

    # $shortrop should always be rounded up, $longrop is exact.

    unless($shortrop > $longrop && $ret > 0) {
      $ok = 0;
      warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
    }

    $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
    unless($shortrop == $check && $ret > 0) {
      $ok = 0;
      warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
    }
  }
  if($ok) {
    print "ok 8\n" if $suffix eq '001';
    print "ok 9\n" if $suffix eq '101';
  }
  else    {
    print "not ok 8\n" if $suffix eq '001';
    print "not ok 9\n" if $suffix eq '101';
  }
  $ok = 1;
}

####################################
####################################
####################################

for my $suffix('000', '100') {
  for(1..10) {
    my $str = '1.';
    for(1..70) {$str .= int(rand(2));}
    $str .= $suffix;
    my $nstr = '-' . $str;

    my $longrop = Rmpfr_init2(74);
    my $check    = Rmpfr_init2(72);
    my $shortrop = Rmpfr_init2(72);

    my $coderef = \&Rmpfr_set;

    my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

    if($inex) {die "Rmpfr_set_str falsely returned $inex"}

    my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

    # No rounding, result is exact.

    unless($shortrop == $longrop && $ret == 0) {
      $ok = 0;
      warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
    }

    $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
    unless($shortrop == $check && $ret == 0) {
      $ok = 0;
      warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
    }

    $longrop *= -1;

    $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

    # No rounding, result is exact

    unless($shortrop == $longrop && $ret == 0) {
      $ok = 0;
      warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
    }

    $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
    unless($shortrop == $check && $ret == 0) {
      $ok = 0;
      warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
    }
  }
  if($ok) {
    print "ok 10\n" if $suffix eq '000';
    print "ok 11\n" if $suffix eq '100';
  }
  else    {
    print "not ok 10\n" if $suffix eq '000';
    print "not ok 11\n" if $suffix eq '100';
  }
  $ok = 1;
}

####################################
####################################
####################################
####################################

$ok = 1;

for(1..10) {
  my $str = '0.1';
  for(1..70) {$str .= int(rand(2));}
  $str .= '01' . '@' . Rmpfr_get_emin();
  my $nstr = '-' . $str;

  my $longrop = Rmpfr_init2(73);
  my $check    = Rmpfr_init2(72);
  my $shortrop = Rmpfr_init2(72);

  my $coderef = \&Rmpfr_set;

  my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

  if($inex) {die "Rmpfr_set_str falsely returned $inex"}

  my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded up, $longrop is exact.

  unless($shortrop > $longrop && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
  unless($shortrop == $check && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

  $longrop *= -1;

  $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded down, $longrop is exact.

  unless($shortrop < $longrop && $ret < 0) {
   $ok = 0;
   warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
  unless($shortrop == $check && $ret < 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

}
if($ok) {print "ok 12\n"}
else    {print "not ok 12\n"}
$ok = 1;

for(1..10) {
  my $str = '0.1';
  for(1..70) {$str .= int(rand(2));}
  $str .= '011' . '@' . Rmpfr_get_emin();
  my $nstr = '-' . $str;

  my $longrop = Rmpfr_init2(74);
  my $check    = Rmpfr_init2(72);
  my $shortrop = Rmpfr_init2(72);

  my $coderef = \&Rmpfr_set;

  my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

  if($inex) {die "Rmpfr_set_str falsely returned $inex"}

  my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded up, $longrop is exact.

  unless($shortrop > $longrop && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
  unless($shortrop == $check && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

  $longrop *= -1;

  $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded down, $longrop is exact.

  unless($shortrop < $longrop && $ret < 0) {
   $ok = 0;
   warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
  unless($shortrop == $check && $ret < 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret";
  }

}

if($ok) {print "ok 13\n"}
else    {print "not ok 13\n"}
$ok = 1;

for(1..10) {
  my $str = '0.1';
  for(1..70) {$str .= int(rand(2));}
  $str .= '001'  . '@' . Rmpfr_get_emin();
  my $nstr = '-' . $str;

  my $longrop = Rmpfr_init2(74);
  my $check    = Rmpfr_init2(72);
  my $shortrop = Rmpfr_init2(72);

  my $coderef = \&Rmpfr_set;

  my $inex = Rmpfr_set_str($longrop, $str, 2, MPFR_RNDN);

  if($inex) {die "Rmpfr_set_str falsely returned $inex"}

  my $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded down, $longrop is exact.

  unless($shortrop < $longrop && $ret < 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $str, 2);
  unless($shortrop == $check && $ret < 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }

  $longrop *= -1;

  $ret = Rmpfr_round_nearest_away($coderef, $shortrop, $longrop);

  # $shortrop should always be rounded up, $longrop is exact.

  unless($shortrop > $longrop && $ret > 0) {
   $ok = 0;
   warn "\n lt: \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  }

  $ret = Rmpfr_round_nearest_away(\&Rmpfr_strtofr, $check, $nstr, 2);
  unless($shortrop == $check && $ret > 0) {
   $ok = 0;
   warn "\n gt: \$shortrop: $shortrop\n \$check: $check\n \$ret: $ret\n";
  }
}

if($ok) {print "ok 14\n"}
else    {print "not ok 14\n"}
$ok = 1;

my $longrop = Rmpfr_init2(73);
my $shortrop = Rmpfr_init2(72);

my $coderef = \&Rmpfr_set;

################

Rmpfr_set_inf($longrop, 1);
my $ret = Rmpfr_round_nearest_away($coderef,$shortrop, $longrop);

if($shortrop == $longrop && $ret == 0) {
  print "ok 15\n";
}
else {
  warn "\n $shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  print "not ok 15\n";
}

################
################

Rmpfr_set_inf($longrop, -1);
$ret = Rmpfr_round_nearest_away($coderef,$shortrop, $longrop);

if($shortrop == $longrop && $ret == 0) {
  print "ok 16\n";
}
else {
  warn "\n \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  print "not ok 16\n";
}

################
################

Rmpfr_set_zero($longrop, 1);
$ret = Rmpfr_round_nearest_away($coderef,$shortrop, $longrop);

if($shortrop == $longrop && $ret == 0) {
  print "ok 17\n";
}
else {
  warn "\n \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  print "not ok 17\n";
}

################
################

Rmpfr_set_zero($longrop, -1);
$ret = Rmpfr_round_nearest_away($coderef,$shortrop, $longrop);

if($shortrop == $longrop && $ret == 0) {
  print "ok 18\n";
}
else {
  warn "\n \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  print "not ok 18\n";
}

################
################

Rmpfr_set_nan($longrop);
$ret = Rmpfr_round_nearest_away($coderef,$shortrop, $longrop);

if(Rmpfr_nan_p($shortrop) && Rmpfr_nan_p($longrop) && $ret == 0) {
  print "ok 19\n";
}
else {
  warn "\n \$shortrop: $shortrop\n \$longrop: $longrop\n \$ret: $ret\n";
  print "not ok 19\n";
}

my $small_1 = Math::MPFR->new(7.5);
my $small_2 = Math::MPFR->new(6.5);

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_1, 3);

if($ret > 0 && $small_1 == 8) {print "ok 20\n"}
else {
  warn "\n \$ret: $ret\n \$small_1:$small_1\n";
  print "not ok 20\n";
}

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_2, 3);

if($ret > 0 && $small_2 == 7) {print "ok 21\n"}
else {
  warn "\n \$ret: $ret\n \$small_2:$small_2\n";
  print "not ok 21\n";
}

####################################

# Change precision to 53.
Rmpfr_set_prec($small_1, 53);
Rmpfr_set_prec($small_2, 53);

Rmpfr_set_d($small_1, 7.4, MPFR_RNDN);
Rmpfr_set_d($small_2, 6.6, MPFR_RNDN);

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_1, 3);

if($ret < 0 && $small_1 == 7) {print "ok 22\n"}
else {
  warn "\n \$ret: $ret\n \$small_1:$small_1\n";
  print "not ok 22\n";
}

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_2, 3);

if($ret > 0 && $small_2 == 7) {print "ok 23\n"}
else {
  warn "\n \$ret: $ret\n \$small_2:$small_2\n";
  print "not ok 23\n";
}

####################################

# Change precision to 53.
Rmpfr_set_prec($small_1, 53);
Rmpfr_set_prec($small_2, 53);

Rmpfr_set_d($small_1, 7.5, MPFR_RNDN);
Rmpfr_set_d($small_2, 6.5, MPFR_RNDN);

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_1, 4);

if($ret == 0 && $small_1 == 7.5) {print "ok 24\n"}
else {
  warn "\n \$ret: $ret\n \$small_1:$small_1\n";
  print "not ok 24\n";
}

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_2, 4);

if($ret == 0 && $small_2 == 6.5) {print "ok 25\n"}
else {
  warn "\n \$ret: $ret\n \$small_2:$small_2\n";
  print "not ok 25\n";
}

####################################

# Change precision to 53.
Rmpfr_set_prec($small_1, 53);
Rmpfr_set_prec($small_2, 53);

Rmpfr_set_d($small_1, 7.25, MPFR_RNDN);
Rmpfr_set_d($small_2, 6.25, MPFR_RNDN);

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_1, 3);

if($ret < 0 && $small_1 == 7) {print "ok 26\n"}
else {
  warn "\n \$ret: $ret\n \$small_1:$small_1\n";
  print "not ok 26\n";
}

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_2, 3);

if($ret < 0 && $small_2 == 6) {print "ok 27\n"}
else {
  warn "\n \$ret: $ret\n \$small_2:$small_2\n";
  print "not ok 27\n";
}

####################################

# Change precision to 53.
Rmpfr_set_prec($small_1, 53);
Rmpfr_set_prec($small_2, 53);

Rmpfr_set_d($small_1, 7.0, MPFR_RNDN);
Rmpfr_set_d($small_2, 6.0, MPFR_RNDN);

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_1, 3);

if($ret == 0 && $small_1 == 7) {print "ok 28\n"}
else {
  warn "\n \$ret: $ret\n \$small_1:$small_1\n";
  print "not ok 28\n";
}

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $small_2, 3);

if($ret == 0 && $small_2 == 6) {print "ok 29\n"}
else {
  warn "\n \$ret: $ret\n \$small_2:$small_2\n";
  print "not ok 29\n";
}

####################################

my $nan  = Rmpfr_init();
my $inf  = Math::MPFR->new(1)  / Math::MPFR->new(0);
my $ninf = Math::MPFR->new(-1) / Math::MPFR->new(0);

####################################

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $nan, 2);

if(Rmpfr_get_prec($nan) == 2 && Rmpfr_nan_p($nan) && $ret == 0) {print "ok 30\n"}
else {
  warn "\n prec: ", Rmpfr_get_prec($nan), "\n \$nan: $nan\n \$ret: $ret\n";
  print "not ok 30\n";
}

####################################

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $inf, 2);

if(Rmpfr_get_prec($inf) == 2 && Rmpfr_inf_p($inf) && $ret == 0 && $inf > 0) {print "ok 31\n"}
else {
  warn "\n prec: ", Rmpfr_get_prec($inf), "\n \$inf: $inf\n \$ret: $ret\n";
  print "not ok 31\n";
}

####################################

$ret = Rmpfr_round_nearest_away(\&Rmpfr_prec_round, $ninf, 2);

if(Rmpfr_get_prec($ninf) == 2 && Rmpfr_inf_p($ninf) && $ret == 0 && $ninf < 0) {print "ok 32\n"}
else {
  warn "\n prec: ", Rmpfr_get_prec($ninf), "\n \$ninf: $ninf\n \$ret: $ret\n";
  print "not ok 32\n";
}

####################################
####################################

my $rop = Rmpfr_init();
my $min = Rmpfr_init();
my $minstring = '0.1@' . Rmpfr_get_emin_min();
Rmpfr_set_str($min, $minstring, 2, MPFR_RNDN);

my $mul = Math::MPFR->new(2);
Rmpfr_pow_si($mul, $mul, Rmpfr_get_emin_min(), MPFR_RNDN);

if($mul * 0.5 == $min) {print "ok 33\n"}
else {
  warn "\n $mul * 0.5 != $min\n Ensuing tests may fail\n";
  print "not ok 33\n";
}

if(is_rop_min(\&Rmpfr_mul_d, $rop, $mul, 0.5)) {print "ok 34\n"}
else {
  Rmpfr_mul_d($rop, $mul, 0.5, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 34\n";
}

if(is_rop_min(\&Rmpfr_mul_d, $rop, $mul, 0.25)) {print "ok 35\n"}
else {
  Rmpfr_mul_d($rop, $mul, 0.25, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 35\n";
}

if(is_rop_min(\&Rmpfr_mul_d, $rop, $mul, 0.0625)) {print "ok 36\n"}
else {
  Rmpfr_mul_d($rop, $mul, 0.0625, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 36\n";
}

if(!is_rop_min(\&Rmpfr_mul_d, $rop, $mul, 0.75)) {print "ok 37\n"}
else {
  Rmpfr_mul_d($rop, $mul, 0.75, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 37\n";
}

################################

if(is_rop_min(\&Rmpfr_mul_d, $rop, $mul, -0.5)) {print "ok 38\n"}
else {
  Rmpfr_mul_d($rop, $mul, -0.5, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 38\n";
}

if(is_rop_min(\&Rmpfr_mul_d, $rop, $mul, -0.25)) {print "ok 39\n"}
else {
  Rmpfr_mul_d($rop, $mul, -0.25, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 39\n";
}

if(is_rop_min(\&Rmpfr_mul_d, $rop, $mul, -0.0625)) {print "ok 40\n"}
else {
  Rmpfr_mul_d($rop, $mul, -0.0625, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 40\n";
}

if(!is_rop_min(\&Rmpfr_mul_d, $rop, $mul, -0.75)) {print "ok 41\n"}
else {
  Rmpfr_mul_d($rop, $mul, -0.75, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 41\n";
}

if(!is_rop_min(\&Rmpfr_mul_d, $rop, $mul, -0.0)) {print "ok 42\n"}
else {
  Rmpfr_mul_d($rop, $mul, -0.0, MPFR_RNDA);
  warn "\n \$rop: $rop\n";
  print "not ok 42\n";
}

Rmpfr_set_default_prec(41);

my $ps = Math::MPFR->new();
my $ns = Math::MPFR->new();

$ok = 1;

for(1..100) {
  my $str = int(rand(2));
  my $str_check = $str;
  for(1..40) {$str .= int(rand(2))}
  my $str_keep = $str;
  $str_check = substr($str, -1, 1) if $str_check;
  my $mul = int(rand(2)) == 0 ? 1 : -1;
  my $exponent = int(rand(100));
  $exponent *= $mul;
  $str .= '@' . $exponent;
  Rmpfr_set_str($ps, $str, 2, MPFR_RNDN);
  Rmpfr_neg($ns, $ps, MPFR_RNDN);
  my $lsb = Math::MPFR::_lsb($ps);

  if(Math::MPFR::_lsb($ns) != $lsb) {$ok = 2}

  if(substr($str, 0, 1) eq '0' && "$lsb" ne '0') {
    $ok = 3;
  }

  if(substr($str_keep, 0, 1) eq '1' && substr($str_keep, -1, 1) eq '1' && "$lsb" ne '1') {
    warn "\n \$str_keep: $str_keep\n \$lsb: $lsb\n";
    $ok = 4;
  }

  if($lsb != $str_check) {$ok = 0}
}

if($ok == 1) {print "ok 43\n"}
else {
  warn "\n \$ok: $ok\n";
  print "not ok 43\n";
}

$ok = 1;

Rmpfr_set_default_prec(67);

my $ps2 = Math::MPFR->new();
my $ns2 = Math::MPFR->new();

for(1..100) {
  my $str = int(rand(2));
  my $str_check = $str;
  for(1..66) {$str .= int(rand(2))}
  my $str_keep = $str;
  $str_check = substr($str, -1, 1) if $str_check;
  my $mul = int(rand(2)) == 0 ? 1 : -1;
  my $exponent = int(rand(1000));
  $exponent *= $mul;
  $str .= '@' . $exponent;
  Rmpfr_set_str($ps2, $str, 2, MPFR_RNDN);
  Rmpfr_neg($ns2, $ps2, MPFR_RNDN);
  my $lsb = Math::MPFR::_lsb($ps2);

  if(Math::MPFR::_lsb($ns2) != $lsb) {$ok = 2}

  if(substr($str, 0, 1) eq '0' && "$lsb" ne '0') {
    $ok = 3;
  }

  if(substr($str_keep, 0, 1) eq '1' && substr($str_keep, -1, 1) eq '1' && "$lsb" ne '1') {
    warn "\n \$str_keep: $str_keep\n \$lsb: $lsb\n";
    $ok = 4;
  }

  if($lsb != $str_check) {$ok = 0}
}

if($ok == 1) {print "ok 44\n"}
else {
  warn "\n \$ok: $ok\n";
  print "not ok 44\n";
}

$ok = 1;

if(Math::MPFR::_lsb(Math::MPFR->new()) == 0) {print "ok 45\n"}
else {
  warn "\n ", Math::MPFR::_lsb(Math::MPFR->new()), "\n";
  print "not ok 45\n";
}

if(Math::MPFR::_lsb(Math::MPFR->new(1) / Math::MPFR->new(0)) == 0) {print "ok 46\n"}
else {
  warn "\n ", Math::MPFR::_lsb(Math::MPFR->new(1) / Math::MPFR->new(0)), "\n";
  print "not ok 46\n";
}

if(Math::MPFR::_lsb(Math::MPFR->new(-1) / Math::MPFR->new(0)) == 0) {print "ok 47\n"}
else {
  warn "\n ", Math::MPFR::_lsb(Math::MPFR->new(-1) / Math::MPFR->new(0)), "\n";
  print "not ok 47\n";
}

if(Math::MPFR::_lsb(Math::MPFR->new(0)) == 0) {print "ok 48\n"}
else {
  warn "\n ", Math::MPFR::_lsb(Math::MPFR->new(0)), "\n";
  print "not ok 48\n";
}


