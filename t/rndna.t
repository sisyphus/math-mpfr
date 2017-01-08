use strict;
use warnings;
use Math::MPFR qw(:mpfr);

print "1..23\n";

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

Rmpfr_set_prec($small_1, 53);
Rmpfr_set_prec($small_2, 53);

# Change precision from 3 back to 53.
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
