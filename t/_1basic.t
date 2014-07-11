use warnings;
use strict;
use Config;
use Math::MPFR qw(:mpfr);

print "1..4\n";

print STDERR "\n# Using Math::MPFR version ", $Math::MPFR::VERSION, "\n";
print STDERR "# Using mpfr library version ", MPFR_VERSION_STRING, "\n";
print STDERR "# Using gmp library version ", Math::MPFR::gmp_v(), "\n";

if   (pack("L", 305419897) eq pack("N", 305419897)) {warn "# Machine appears to be big-endian\n"}
elsif(pack("L", 305419897) eq pack("V", 305419897)) {warn "# Machine appears to be little-endian\n"}

warn "# Byte Order: ", $Config{byteorder}, "\n";

if($Math::MPFR::VERSION eq '3.22') {print "ok 1\n"}
else {print "not ok 1 $Math::MPFR::VERSION\n"}

if(Math::MPFR::_get_xs_version() eq '3.22') {print "ok 2\n"}
else {
  warn "Module version: $Math::MPFR::VERSION\nXS version: ", Math::MPFR::_get_xs_version(), "\n";
  print "not ok 2\n";
}

if(Rmpfr_get_version() eq MPFR_VERSION_STRING) {print "ok 3\n"}
else {print "not ok 3 - Header and Library do not match\n"}

my $max_base = Math::MPFR::_max_base();

if($max_base == 62) {
  if(3 <= MPFR_VERSION_MAJOR) {print "ok 4\n"}
  else {
    warn "\n\$max_base: $max_base\n";
    warn "VERSION_MAJOR ", MPFR_VERSION_MAJOR, "\n";
    print "not ok 4\n";
  }
}
elsif($max_base == 36) {
  if(3 > MPFR_VERSION_MAJOR) {print "ok 4\n"}
  else {
    warn "\n\$max_base: $max_base\n";
    warn "VERSION_MAJOR ", MPFR_VERSION_MAJOR, "\n";
    print "not ok 4\n";
  }
}
else {
  warn "\n\$max_base: $max_base\n";
  print "not ok 4\n";
}
