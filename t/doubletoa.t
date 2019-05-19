use strict;
use warnings;

use Math::MPFR qw(:mpfr);
use Config;

if($Config{nvsize} != 8) {

  print "1..4\n";

  if(Math::MPFR::_fallback_notify()) { print "not ok 1\n"}
  else {print "ok 1\n"}

  if(Math::MPFR::_fallback_to_nvtoa()) { print "not ok 2\n"}
  else {print "ok 2\n"}

  if(Math::MPFR::_fallback_to_sprintf()) { print "not ok 3\n"}
  else {print "ok 3\n"}

  eval {my $x = doubletoa(42.0) };

  if($@ =~ /^The doubletoa function is unavailable/) { print "ok 4\n" }
  else {
    warn "\$\@: $@\n";
    print "not ok 4\n";
  }

}

else {

  print "1..3\n";

  my $sum = Math::MPFR::_fallback_to_nvtoa() + Math::MPFR::_fallback_to_sprintf();

  if($sum == 1) {print "ok 1\n"}
  else {
    warn "\n  Expected 1\n  Got $sum\n";
    print "not ok 1\n";
  }

  my $chosen_fallback = Math::MPFR::_fallback_to_nvtoa() ? 'nvtoa' : 'sprintf';
  my $ok = 1;
  my ($count, $fallback_count) = (0, 0);

  for my $iteration(1..1000) {
    last unless $ok;
    for my $exp(-326 .. 325) {
      $count++;
      my $str = rand(100);
      if($str !~ /e/) { $str .= (int(rand(10)) . int(rand(10)) . "e$exp") }
      $str = '-' . $str unless $iteration % 3;
      my $v = $str + 0;
      $Math::MPFR::doubletoa_fallback = 0;
      my $s1 = doubletoa($v);
      $fallback_count++ if $Math::MPFR::doubletoa_fallback;
      my $s2 = nvtoa($v);

      if($s1 ne $s2) {
        if($chosen_fallback eq 'nvtoa') {
          $ok = 0;
          warn "\nmismatch for $str: $s1 $s2\n";
          last;
        }
        else {
          # We can expect that there will be mismatches, but only if doubletoa has
          # fallen back to sprintf().
          # And we don't know if sprintf() has been called unless
          # Math::MPFR::_fallback_notify() returns 1.
          if(Math::MPFR::_fallback_notify() && ! $Math::MPFR::doubletoa_fallback) {
            warn "\nmismatch for $str: $s1 $s2";
            $ok = 0;
            last;
          }
          # else, we cn't make a call on whether the discrepancy is acceptable.
        }
      }

      if($s1 != $s2) {
        warn "\ninequality for $str: $s1 != $s2\n";
        $ok = 0;
        last;
      }
    }
  }

  if($ok) { print "ok 2\n" }
  else { print "not ok 2\n" }

  if(Math::MPFR::_fallback_notify()) {
    if($count > 10000) {
      if($fallback_count > 10 && $count / $fallback_count > 50) {
        print "ok 3\n";
      }
      else {
        warn "\n  Total Count: $count\nFallback count: $fallback_count\n";
        print "not ok 3\n";
      }
    }
    else {
      warn "\n Skipping - didn't test enough values\n";
      print "ok 3\n";
    }
  }
  else {
    if($fallback_count) { print "not ok 3\n" }
    else { print "ok 3\n" }
  }
}
