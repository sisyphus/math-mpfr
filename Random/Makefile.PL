use strict;
use warnings;
use ExtUtils::MakeMaker;

our $LIBS;
our $defines;

my $d = '';
if($defines =~ /\-DMPFR_PV_NV_BUG/) {
  print "Defining -DMPFR_PV_NV_BUG in Math/MPFR/Random\n";
  $d = '-DMPFR_PV_NV_BUG';
}
else {
  print "Not defining -DMPFR_PV_NV_BUG in Math/MPFR/Random\n";
}

my %options = %{
{
  'TYPEMAPS' => [],
  'NAME'     => 'Math::MPFR::Random',
  'LIBS'     => $LIBS,
  'DEFINE'   => $d,
  'INC'      => $INC,
  'VERSION_FROM' => 'Random.pm',
}
};
WriteMakefile(%options);

# Remove the Makefile dependency. Causes problems on a few systems.
# sub MY::makefile { '' }
