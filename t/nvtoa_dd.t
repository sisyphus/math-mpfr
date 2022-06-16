use strict;
use warnings;
use Math::MPFR qw(:mpfr);

use Test::More;

unless(Math::MPFR::MPFR_3_1_6_OR_LATER) {
  plan skip_all => "nvtoa.t utilizes Math::MPFR functionality that requires mpfr-3.1.6\n";
  exit 0;
}

for(-1075..1024) {
  my $nv = 2 ** $_;
  cmp_ok(nvtoa_test(nvtoa($nv), $nv), '==', 7, "2 ** $_");
#  cmp_ok(nvtoa_test(nvtoa(-$nv), -$nv), '==', 7, "-(2 ** $_)");
}

my @pows = (50, 100, 150, 200, 250, 300, 350, 400, 450, 500,
         550, 600, 650, 700, 750, 800, 850, 900, 950, 1000);

  die "wrong sized array" unless @pows == 20;

my $ret = (2** -1020) + (2 ** -1021);
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "(2** -1020) + (2 ** -1021)");

$ret = (2** -1021) + (2 ** -1064);
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "(2** -1021) + (2 ** -1064)");

$ret = (2** -1020) - (2 ** -1021);
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "(2** -1020) - (2 ** -1021)");

$ret = (2** -1021) - (2 ** -1064);
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "(2** -1021) - (2 ** -1064)");

#   Failed test '[2 11] / [12 9] repro ok'
#   at t/sparse.t line 64.
#          got: [3.054936363499605e-151 4.9406564584124654e-324]
#     expected: [3.054936363499605e-151 0.0]

my @in0 = qw(2 11);
my @in1 = qw(12 9);
$ret = my_assign(\@in0, \@in1, '/');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 / @in1");

@in0 = qw(2 -17);
@in1 = qw(9 -17);
$ret = my_assign(\@in0, \@in1, '/');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 / @in1");

#   Failed test '[3 3] - [3 10] repro ok'
#   at t/sparse.t line 69.
#          got: [6.223015277861142e-61 -2.713328551617527e-166]
#     expected: [6.223015277861142e-61 -2.7133285516175262e-166]

@in0 = qw(3 3);
@in1 = qw(3 10);
$ret = my_assign(\@in0, \@in1, '-');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 - @in1");

#   Failed test '[13 -1] * [1 -7] repro ok'
#   at t/sparse.t line 54.
#          got: [6.668014432879854e+240 -2.0370359763344865e+90]
#     expected: [6.668014432879854e+240 -2.037035976334486e+90]

@in0 = qw(13 -1);
@in1 = qw(1 -7);
$ret = my_assign(\@in0, \@in1, '*');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 * @in1");

#   Failed test '[14 1] - [11 4] repro ok'
#   at t/sparse.t line 69.
#          got: [5.922386521532856e+225 -4.1495155688809925e+180]
#     expected: [5.922386521532856e+225 -4.149515568880993e+180]

@in0 = qw(14 1);
@in1 = qw(11 4);
$ret = my_assign(\@in0, \@in1, '-');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 - @in1");

#   Failed test '[17 -16] + [11 -2] repro ok'
#   at t/sparse.t line 59.
#          got: [8.452712498170644e+270 4.1495155688809925e+180]
#     expected: [8.452712498170644e+270 4.149515568880993e+180]

@in0 = qw(17 -16);
@in1 = qw(11 -2);
$ret = my_assign(\@in0, \@in1, '+');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 + @in1");

#   Failed test '[1 8] * [0 11] repro ok'
#   at t/sparse.t line 54.
#          got: [1.42724769270596e+45 3.872591914849318e-121]
#     expected: [1.42724769270596e+45 3.8725919148493183e-121]

@in0 = qw(1 8);
@in1 = qw(0 11);
$ret = my_assign(\@in0, \@in1, '*');
cmp_ok(nvtoa_test(nvtoa($ret), $ret, 2), '==', 7, "@in0 * @in1");

#   Failed test '[8 -18] / [13 -1] repro ok'
#   at t/sparse.t line 64.
#          got: [5.527148e-76 -1.9501547226722595e-92]
#     expected: [5.527147875260445e-76 8.289046058458095e-317]

@in0 = qw(8 -18);
@in1 = qw(13 -1);
$ret = my_assign(\@in0, \@in1, '/');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 / @in1");

# [3 13] / [14 9]

@in0 = qw(3 13);
@in1 = qw(14 9);
$ret = my_assign(\@in0, \@in1, '/');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "@in0 / @in1");

# 0.66029111258694e-111 fails chop test.
$ret = atonv('0.66029111258694e-111');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "0.66029111258694e-111");

# 0.876771194648327e219 fails chop test
$ret = atonv('0.876771194648327e219');
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "0.876771194648327e219");

#   Failed test 'chop test ok for [11 -14]'
#   at t/sparse.t line 90.
#     '[4.149515568880993e+180 -1.688508503057271e-226]'
#         <
#     '[4.149515568880993e+180 -1.688508503057271e-226]'

@in0 = qw(11 -14);
$ret = (2 ** $pows[11]) - (2 ** -$pows[14]);
cmp_ok(nvtoa_test(nvtoa($ret), $ret), '==', 7, "(2 ** $pows[11]) - (2 ** -$pows[14])");
done_testing();

##############################################################
##############################################################
##############################################################

sub my_assign {

my @p = (50, 100, 150, 200, 250, 300, 350, 400, 450, 500,
         550, 600, 650, 700, 750, 800, 850, 900, 950, 1000);

  die "wrong sized array" unless @p == 20;

  my($xb, $xl) = @{$_[0]};
  my($yb, $yl) = @{$_[1]};

  my $x = $xl =~ /\-/ ? (2 **$p[$xb]) - (2** -( $p[-$xl]) )
                      : (2 **$p[$xb]) + (2** -( $p[$xl ]) );
  my $y = $yl =~ /\-/ ? (2 **$p[$yb]) - (2** -( $p[-$yl]) )
                      : (2 **$p[$yb]) + (2** -( $p[$yl ]) );

  my $op = $_[2];

  return $x * $y if($op eq '*') ;
  return $x + $y if($op eq '+') ;
  return $x / $y if($op eq '/') ;
  return $x - $y if($op eq '-') ;

  die "Error in my_assign();"
}
