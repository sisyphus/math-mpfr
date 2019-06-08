use strict;
use warnings;

use Math::MPFR qw(:mpfr);
use Config;

if($Config{nvsize} != 8) {

  print "1..2\n";

  if(Math::MPFR::_fallback_notify()) { print "not ok 1\n"}
  else {print "ok 1\n"}

  eval {my $x = doubletoa(42.0) };

  if($@ =~ /^The doubletoa function is unavailable/) { print "ok 2\n" }
  else {
    warn "\$\@: $@\n";
    print "not ok 2\n";
  }

}

else {

  print "1..2\n";

  my $ok = 1;
  my ($count, $mismatch_count) = (0, 0);

  for my $iteration(1..1000) {
    last unless $ok;
    for my $exp(-326 .. 325) {
      $count++;
      my $str = rand(100);
      if($str !~ /e/) { $str .= (int(rand(10)) . int(rand(10)) . "e$exp") }
      $str = '-' . $str unless $iteration % 3;
      my $v = $str + 0;
      my $s1 = doubletoa($v, "S");
      my $s2 = nvtoa($v);

      if($s1 ne $s2) {
        $mismatch_count++;
        my $s1_alt = doubletoa($v);
        #print "$s1 | $s1_alt | $s2\n";
        if($s1 eq $s1_alt || $s1 != $s1_alt || $s1 != $s2) {
          $ok = 0;
          warn "\nmismatch for $str: $s1 ($s1_alt) $s2\n";
          last;
        }
      }
    }
  }

  #print "Fallback: $Math::MPFR::doubletoa_fallback Mismatch: $mismatch_count\n";

  if($ok) { print "ok 1\n" }
  else { print "not ok 1\n" }

  if(Math::MPFR::_fallback_notify()) {
    if($count > 10000) {
      if($Math::MPFR::doubletoa_fallback > 10 && $count / $Math::MPFR::doubletoa_fallback > 50) {
        print "ok 2\n";
      }
      else {
        warn "\n  Total Count: $count\nFallback count: $Math::MPFR::doubletoa_fallback\n";
        print "not ok 2\n";
      }
    }
    else {
      warn "\n Skipping - didn't test enough values\n";
      print "ok 2\n";
    }
  }
  else {
    if($Math::MPFR::doubletoa_fallback) { print "not ok 2\n" }
    else { print "ok 2\n" }
  }
}
