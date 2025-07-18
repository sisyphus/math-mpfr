use strict;
use warnings;
use Config;
use ExtUtils::MakeMaker;

#require 5.008008;

our %args = map { split /\s*=\s*/ } @ARGV;
our $LIBS = $args{ LIBS } || "-lmpfr -lgmp";
our $INC = $args{ INC };
our $DEFS = '';
my $defines = '';

my $use_64_bit_int  = 0; # Let perl decide whether to include 64-bit 'long long' support
my $use_long_double = 0; # Let perl decide whether to include 'long double' support
my $use_quadmath    = 0; # Let perl decide whether to include '__float128' support
my $have_decimal64  = undef; # Default value
my $have_decimal128 = undef; # Default value
my $have_float128   = undef; # Default value
my $want_float128   = undef; # Default value
my $have_float16    = undef; # Default value
my $have_bfloat16   = undef; # Default value
my $checklib        = 1;     # Check for availability of mpfr and gmp libraries.
my $skip_msvc       = 0;     # Will be reset to 1 for MS compiler builds of perl.

my ($d64_message, $d128_message, $float128_message);

for(@ARGV) {
  $have_decimal128 = 1 if $_ eq 'D128=1';
  $have_decimal128 = 0 if $_ eq 'D128=0';
  $have_float16 = 1 if $_ eq 'F16=1';
  $have_float16 = 0 if $_ eq 'F16=0';
  $have_bfloat16 = 1 if $_ eq 'BF16=1';
  $have_bfloat16 = 0 if $_ eq 'BF16=0';
}

# The following tests don't work with perls built using MS Visual Studio.
# We skip them all, as they are not particularly important ... some are
# even irrelevant.
# In skipping these tests we assumpe (perhaps incorrectly) that, if you're
# running MS Visual Studio, then you have gmp and mpfr libraries that are
# compatible with that toolchain, && that those libraries will be found
# when needed.
$skip_msvc = 1 if ($Config{'make'} eq 'nmake' && $Config{'cc'} eq 'cl');

unless($skip_msvc) {
  print " Running some (possibly noisy) pre-build checks\n to find out what's available ....\n\n";

  my $SAVE;
  my $save = open $SAVE, '>', 'save_config.txt';

  warn "Couldn't open save_config.txt for writing: $!" unless $save;

  my($mycc, $mklib, $mkinc, $mylibpth) = ('', '', '', '') ;


  if(@ARGV) {
    for my $arg(@ARGV) {
      $mycc   = (split /=/, $arg)[1] if $arg =~ /^cc=/i;
      $mklib = (split /=/, $arg)[1] if $arg =~ /^libs=/i;
      $mkinc  = (split /=/, $arg)[1] if $arg =~ /^inc=/i;
      $checklib = 0 if $arg =~ /^check=0/i;
    }
  }

  unless($mycc) {
    $mycc = defined($Config{cc}) ? $Config{cc} : 'cc';
  }

  my @libpth = split /\s+/, $Config{libpth};
  for(@libpth) { $mylibpth .= " -L$_" }
  $mylibpth .= " -lmpfr -lgmp";

  ###############################################################
  # Check that -lmpfr and -lgmp can be found. Don't worry about #
  # checking for mpfr.h and gmp.h - if they can't be found when #
  # needed by a smoker then it won't be reported as a FAIL      #
  ###############################################################

  if($checklib) {

    my $mylibs = $mklib . " " . $mylibpth;

    my $out = `$mycc -o checklib.exe -x c checklib.in $mylibs 2>&1`;

    if($out) {
      print "$out\n";
      if($save) {print $SAVE "checklib build: $out\n"}
    }

    if(-e 'checklib.exe') {
      $out = $^O =~ /MSWin32/i ? `checklib.exe` : `./checklib.exe`;
      if($save) {print $SAVE "checklib.exe: $out\n"}
    }
    else {
      warn "\n  Could not resolve '-lmpfr' and/or '-lgmp'\n",
           "  If this is incorrect please see the 'Checklib' section in the README\n",
           "  Aborting the build of Math::MPFR\n";
      exit 0;
    }
  }

  ##################################
  # Whether _Float16 is recognized #
  ##################################

  unless(defined($have_float16)) { # make no changes and conduct no further
                                   # tests if $have_float16 is defined.
    if($Config{ptrsize} == 4 && $^O =~ /MSWin32/) {
      $have_float16 = 0;           # Currently not supported by Math::MPFR
    }
    else {
      my $mylibs = $mklib . " " . $mylibpth;
      my $out = `$mycc -o have_float16.exe -x c have_float16.in $mylibs 2>&1`;

      if( -e 'have_float16.exe') {
        my $size = $^O =~ /MSWin32/i ? `have_float16.exe` : `./have_float16.exe`;
        $have_float16 = 1 if $size eq '-2';
      }
    }
  }

  if(defined $have_float16 && $have_float16 == 1) {
    $defines .= ' -DMPFR_WANT_FLOAT16=1';
  }

  ################################
  # Whether __bf16 is recognized #
  ################################

  unless(defined($have_bfloat16)) { # make no changes and conduct no further
                                    # tests if $have_bfloat16 is defined.
    if($Config{ptrsize} == 4 && $^O =~ /MSWin32/) {
      $have_float16 = 0;           # Currently not supported by Math::MPFR
    }
    else {
      my $mylibs = $mklib . " " . $mylibpth;
      my $out = `$mycc -o have_bfloat16.exe -x c have_bfloat16.in $mylibs 2>&1`;

      if( -e 'have_bfloat16.exe') {
        my $size = $^O =~ /MSWin32/i ? `have_bfloat16.exe` : `./have_bfloat16.exe`;
        $have_bfloat16 = 1 if $size eq '-2';
      }
    }
  }

  if(defined $have_bfloat16 && $have_bfloat16 == 1) {
    $defines .= ' -DMPFR_WANT_BFLOAT16=1';
  }

  ############################################
  # Whether to build with _Decimal64 support #
  ############################################

  for(@ARGV) {
    $have_decimal64 = 1 if $_ eq 'D64=1';
    $have_decimal64 = 0 if $_ eq 'D64=0';
  }

  if(!defined($have_decimal64)) { # _Decimal64 support still undetermined

    my $mylibs = $mklib . " " . $mylibpth;

    my $out = `$mycc -o have_d64.exe -x c have_d64.in 2>&1`;

    if($out) {
      print "$out\n";
      if($save) {print $SAVE "try_64 build: $out\n"}
    }

    unless(-e 'have_d64.exe') {$have_decimal64 = 0}

    else { # _Decimal64 support still undetermined

      my $out = `$mycc -o try_dec64.exe -x c try_dec64.in $mkinc $mylibs 2>&1`;

      if($out) {
        print "$out\n";
        if($save) {print $SAVE "try_dec64 build: $out\n"}
      }

      if(-e 'try_dec64.exe') {
        $out = $^O =~ /MSWin32/i ? `try_dec64.exe` : `./try_dec64.exe`;
        {
          no warnings 'numeric';
          if($out == 42) {$have_decimal64 = 1}
        }
        if($save) {print $SAVE "try_dec64.exe: $out\n"}
      }
    }
  }


  $d64_message = $have_decimal64 ? "Attempting to build with Math::Decimal64 support\n"
                                  : "Building without Math::Decimal64 support\n";

  #############################################

  #############################################
  # Whether to build with _Decimal128 support #
  #############################################

  if(!defined($have_decimal128)) { # _Decimal128 support still undetermined

    my $mylibs = $mklib . " " . $mylibpth;

    my $out = `$mycc -o have_d128.exe -x c have_d128.in 2>&1`;

    if($out) {
      print "$out\n";
      if($save) {print $SAVE "try_128 build: $out\n"}
    }

    unless(-e 'have_d128.exe') {$have_decimal128 = 0}

    else { # _Decimal128 support still undetermined

      my $out = `$mycc -o try_dec128.exe -x c try_dec128.in $mkinc $mylibs 2>&1`;

      if($out) {
        print "$out\n";
        if($save) {print $SAVE "try_dec128 build: $out\n"}
      }

      if(-e 'try_dec128.exe') {
        $out = $^O =~ /MSWin32/i ? `try_dec128.exe` : `./try_dec128.exe`;
        {
          no warnings 'numeric';
          if($out == 128) {$have_decimal128 = 1}
        }
        if($save) {print $SAVE "try_dec128.exe: $out\n"}
      }
    }
  }

  $d128_message = $have_decimal128 ? "Attempting to build with Math::Decimal128 support\n"
                                    : "Building without Math::Decimal128 support\n";

  ###########################################

  ###########################################
  # Whether to build with __float128 support #
  ###########################################

  for(@ARGV) {
     $have_float128 = 1 if $_ eq 'F128=1';
     $have_float128 = 0 if $_ eq 'F128=0';
  }

  if(!defined($have_float128)) { # __float128 support, having not yet been
                                 # specified by the user, is still undetermined

    print $SAVE "\n\n" if $save;

    my $mylibs = $mklib . " " . $mylibpth . " -lquadmath";

    # First up, build have_f128.exe from have_f128.c.
    # This simply establishes whether the __float128 type is available.
    # The gmp and mpfr libraries are not needed for this'

    my $out = `$mycc -o have_f128.exe -x c have_f128.in 2>&1`;

    if($out) {
      print "$out\n";
      if($save) {print $SAVE "have_f128 build: $out\n"}
    }

    # If have_f128.exe does not exist, we assume that the __float128
    # type is unavailable, and that __float128  support is therefore
    # impossible. The messages written to 'save_config.txt' should
    # confirm the correctness of this assessment.

    unless(-e 'have_f128.exe') {$have_float128 = 0}

    # But if have_f128.exe exists then we need to establish whether
    # the mpfr library has been built with support for the __float128
    # type. For this we attempt to build try_flt128.exe from
    # try_flt128.in. This build *does* require the gmp and mpfr headers
    # and libraries.
    # If the execution of try_flt128.exe produces output of 42, then
    # we know that the mpfr library has been built with --enable-float128,
    # we set $have_float128 to 1, and Math::MPFR will then be built to
    # utilise that __float128 support.
    # Otherwise we leave $have_float128 as undef, and no __float128
    # support will be built into Math::MPFR.

    else {
      # $Config{ccflags} might include the '-I' switch needed to
      # locate the gmp and mpfr header files. We therefore include
      # those ccflags inthe command:

      my $ccflags = $Config{ccflags};

      my $out = `$mycc $ccflags -o try_flt128.exe -x c try_flt128.in $mkinc $mylibs 2>&1`;

      if($out) {
        # print "$out\n"; # No need to confuse people by
                          # displaying contents of $out.

        if($save) {print $SAVE "try_flt128 build: $out\n"}
      }

      if(-e 'try_flt128.exe') {
        $out = $^O =~ /MSWin32/i ? `try_flt128.exe` : `./try_flt128.exe`;
        {
          no warnings 'numeric';
          if($out == 42) {$have_float128 = 1}
        }
        if($save) {print $SAVE "try_flt128.exe: $out\n"}
      }
    }
  }

  close $SAVE or warn "Couldn't close save_config.txt";

  print " .... pre-build checks completed\n\n";

  $float128_message = $have_float128 ? "Attempting to build with Math::Float128 support\n"
                                        : "Building without Math::Float128 support\n";
} # close 'unless($kip_msvc)

$defines .= $] < 5.008 ? " -DOLDPERL" : " -DNEWPERL";

####################################
# Next, we check to see whether there's some unhelpful beaviour regarding
# the setting of the POK flag - but only if $] < 5.035010.
# This typically occurs in versions of perl prior to 5.22.0, but it can
# arise elsewhere, eg:
# http://www.cpantesters.org/cpan/report/dc17e330-900b-11ec-bfc9-d1f1448276d4
# This procedure is stolen from:
# https://metacpan.org/release/HAARG/Sub-Quote-2.006006/source/t/quotify.t
# Thank you, Haarg.

if($] < 5.035010) {
  use B qw(svref_2object);

  my %flags;
  {
    no strict 'refs';
    for my $flag (qw(
      SVf_IOK
      SVf_NOK
      SVf_POK
      SVp_IOK
      SVp_NOK
      SVp_POK
              )) {
      if (defined &{'B::'.$flag}) {
        $flags{$flag} = &{'B::'.$flag};
      }
    }
  }

  sub flags {
    my $flags = B::svref_2object(\($_[0]))->FLAGS;
    join ' ', sort grep $flags & $flags{$_}, keys %flags;
  }

  my $pv_nv_bug = 0;
  my $test_nv = 1.3;
  my $buggery = "$test_nv";
  my $f = flags($test_nv);

  if($f =~ /SVf_POK/) {
    print "Dealing with unhelpful setting of POK flag\n";
    $pv_nv_bug = 1;
  }

  if($pv_nv_bug) {
    $defines .= " -DMPFR_PV_NV_BUG";
    $DEFS    .= " -DMPFR_PV_NV_BUG";
    print "Defining MPFR_PV_NV_BUG\n\n";
  }
  else {
    print "Not defining MPFR_PV_NV_BUG\n\n";
  }
}
else { print "Not defining MPFR_PV_NV_BUG as perl version >= 5.035010\n\n" }

####################################


unless($Config{ivsize} < 8 || $Config{ivtype} eq 'long') {
  $defines .= " -DMATH_MPFR_NEED_LONG_LONG_INT -DIVSIZE_BITS=" . (8 * $Config{ivsize});
}

if($Config::Config{nvsize} > 8 ) {
  $use_quadmath = 1    if $Config{nvtype} eq '__float128';
  $use_long_double = 1 if $Config{nvtype} eq 'long double';
}

$defines .= " -DMPFR_WANT_DECIMAL_FLOATS" if ($have_decimal64 || $have_decimal128);
$defines .= " -DMPFR_WANT_DECIMAL64"  if $have_decimal64;
$defines .= " -DMPFR_WANT_DECIMAL128" if $have_decimal128;
$defines .= " -DMPFR_WANT_FLOAT128"   if $have_float128;


print "\nThis module requires the following C libraries:\n";
print " gmp-4.2.0 (or later)\n mpfr-3.0.0 (or later)\n\n";
$defines =~ /\-DMATH_MPFR_NEED_LONG_LONG_INT/ ? print "Building with 'long long' support\n" :
                                 print "Building without 'long long' support\n";

if($use_long_double || $use_quadmath) {
  print "Building with 'long double' support\n";
}
else {
  print "Building without 'long double' support\n";
}


if($use_quadmath) {
  print "Building with support for a __float128 NV\n";
}
else {
  print "Building without support for a __float128 NV\n";
}

unless($skip_msvc) {
  print "\n$d64_message";
  print "If this is wrong, see the \"Decimal64 and Decimal128 conversion\" section in the README\n\n";

  print "\n$d128_message";
  print "If this is wrong, see the \"Decimal64 and Decimal128 conversion\" section in the README\n\n";

  print "\n$float128_message";
  print "If this is wrong, see the \"Math::Float128 conversion\" section in the README\n\n";
}

$defines .= $Config::Config{byteorder} =~ /^1234/ ? " -DMPFR_HAVE_LENDIAN" : " -DMPFR_HAVE_BENDIAN";

if(defined $Config{longdblkind}) {
  if($Config{longdblkind} == 1 || $Config{longdblkind} == 2) {
    $defines .= " -DHAVE_IEEE_754_LONG_DOUBLE";
  }
  if($Config{longdblkind} == 3 || $Config{longdblkind} == 4) {
    $defines .= " -DHAVE_EXTENDED_PRECISION_LONG_DOUBLE";
  }
}

if($^O =~ /MSWin32/i && $] < 5.022) {
  $defines .= " -D_WIN32_BIZARRE_INFNAN";
}

if($Config{nvsize} == 8) {
  my $fallback_notify = 1;
  for(@ARGV) {
    $fallback_notify = 0 if $_ eq "FB=0";
  }

  if($fallback_notify) {
    $defines .= " -DFALLBACK_NOTIFY";
    print "\ndoubletoa() fallback notification ENABLED (default)\n\n";
  }
  else { print "\ndoubletoa() fallback notification DISABLED\n\n" }
}

# The following defines serve as debugging
# aids for nvtoa() and doubletoa()
for(@ARGV) {
  $defines .= ' -DNVTOA_DEBUG'  if $_ =~ /NVTOA_DEBUG/i;  # prints out (to STDERR) intermediate
                                                          # values in nvtoa().
  $defines .= ' -DDTOA_ASSERT'   if $_ =~ /DTOA_ASSERT/i; # runs checks at various points in doubletoa()
                                                          # and croaks whenever a check fails.
}

# NOTE: The '-lquadmath' link we provide below
#       to 'LIBS' is generally not needed.
#       It is, however, currently needed on at
#       least some quadmath Cygwin builds.
#             Jan 8 2018.
#       If the quadmath library cannot be found
#       then EU::MM should remove that link -
#       so no big deal ... right ?
#       But then there's (eg):
#       https://www.cpantesters.org/report/7bc0f088-0b21-11ef-a9cc-b541ccdb2386
#       where the link cannot be resolved, yet
#       it does NOT get removed. WTF ??
#       Apparently EU::MM can locate the library
#       but the build process cannot.

my %options = (
  NAME         => 'Math::MPFR',
  AUTHOR       => 'Sisyphus (sisyphus at (@) cpan dot (.) org)',
  ABSTRACT     => 'Perl interface to the MPFR (floating point) library',
  DEFINE       => $defines,
  LIBS         => [ '-lmpfr -lgmp -lquadmath' ],
  PREREQ_PM    => { 'Test::More' => '0.88', },
  #OBJECT       => '$(O_FILES)', # set below if $Config{nvsize} == 8
  LICENSE      => 'perl',
  VERSION_FROM => 'MPFR.pm',
  clean        => { FILES => '*.exe *.txt' },
  META_MERGE   => {
    'meta-spec'  => { version => 2 },
    resources    => {
      repository   => {
        type         => 'git',
        url          => 'https://github.com/sisyphus/math-mpfr.git',
        web          => 'https://github.com/sisyphus/math-mpfr',
      },
    },
  },
);

# Invlolve grisu3.h and grisu3.c if $Config{nvsize} == 8.
# Otherwise they're not needed :

$options{OBJECT} = '$(O_FILES)'
  if $Config{nvsize} == 8;

# The following stuffs up Decimal128 conversions
# & __float128 conversions, though it does allow
# support for _Float16 on 32-bit windows.
# $options{CCFLAGS} = $Config{ccflags} . " -msse2 "
#   if($Config{ptrsize} == 4 && $have_float16 == 1);

WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
sub MY::makefile { '' }

