## This file generated by InlineX::C2XS (version 0.24) using Inline::C (version 0.73)
package Math::MPFR::Random;
use strict;
use warnings;

require Exporter;
*import = \&Exporter::import;
require DynaLoader;

our $VERSION = '4.36';
#$VERSION = eval $VERSION;
Math::MPFR::Random->DynaLoader::bootstrap($VERSION);

@Math::MPFR::Random::EXPORT = ();
@Math::MPFR::Random::EXPORT_OK = ();

sub dl_load_flags {0} # Prevent DynaLoader from complaining and croaking

sub _issue_19550 { # https://github.com/Perl/perl5/issues/19550
  my $inf = 999 ** (999 ** 999);
  my $discard = "$inf";
  my $inf_copy = $inf;
  # Using Math::MPFR::Random::_is_NOK_and_POK():
  return 1
    if(!_is_NOK_and_POK($inf) && _is_NOK_and_POK($inf_copy));
  return 0;
}

sub _buggy {
  return 0 unless $^O =~ /MSWin/;
  if(_win32_fmt_bug_ignore()) {
    warn("This Math::MPFR build was instructed to ignore the WIN32_FMT_BUG, if present");
    return 0;
  }
  return 0 if _win32_formatting_ok();
  return 1;
}

sub _win32_formatting_ok {   # Duplicated in MPFR.pm
    # Return 1 if either __GMP_CC or __GMP_CFLAGS
    # include the string '-D__USE_MINGW_ANSI_STDIO'.
    # Else return 0.

    my $cc = _gmp_cc();		# __GMP_CC
    my $cflags = _gmp_cflags();	# __GMP_CFLAGS

    return 1 if ( defined($cc)     && $cc     =~/\-D__USE_MINGW_ANSI_STDIO/ );
    return 1 if ( defined($cflags) && $cflags =~/\-D__USE_MINGW_ANSI_STDIO/ );
    return 0;
}

1;
