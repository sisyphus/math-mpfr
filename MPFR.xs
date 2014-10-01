
#ifdef  __MINGW32__
#ifndef __USE_MINGW_ANSI_STDIO
#define __USE_MINGW_ANSI_STDIO 1
#endif
#endif

#define PERL_NO_GET_CONTEXT 1

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"


#include <stdio.h>

#if defined MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
#include <inttypes.h>
#endif
#endif


#include <gmp.h>
#include <mpfr.h>
#include <float.h>

#ifdef MPFR_WANT_FLOAT128
#include <quadmath.h>
#if defined(NV_IS_FLOAT128) && defined(MPFR_VERSION) && MPFR_VERSION >= MPFR_VERSION_NUM(3,2,0)
#define CAN_PASS_FLOAT128
#endif
#ifdef __MINGW64__
typedef __float128 float128 __attribute__ ((aligned(8)));
#else
typedef __float128 float128;
#endif
#endif


#if defined(MPFR_VERSION_MAJOR) && MPFR_VERSION_MAJOR >= 3
#define MAXIMUM_ALLOWABLE_BASE 62
#else
#define MAXIMUM_ALLOWABLE_BASE 36
#endif

#define NEG_ZERO_BUG 196866 /* A bug affecting mpfr_fits_u*_p functions         */
                            /* Fixed in mpfr after MPFR_VERSION 196866 (3.1.2)  */
                            /* For earlier versions of mpfr, we fix this bug in */
                            /* our own code                                     */

#define LNGAMMA_BUG 196866  /* lngamma(-0) set to NaN instead of +Inf           */
                            /* Fixed in mpfr after MPFR_VERSION 196866 (3.1.2)  */
                            /* For earlier versions of mpfr, we fix this bug in */
                            /* our own code                                     */

/* Squash some annoying compiler warnings (Microsoft compilers only). */

#ifdef _MSC_VER
#pragma warning(disable:4700 4715 4716)
#endif

#ifdef OLDPERL
#define SvUOK SvIsUV
#endif

#ifndef Newx
#  define Newx(v,n,t) New(0,v,n,t)
#endif

#ifndef Newxz
#  define Newxz(v,n,t) Newz(0,v,n,t)
#endif

/* May one day be removed from mpfr.h */
#ifndef mp_rnd_t
# define mp_rnd_t  mpfr_rnd_t
#endif
#ifndef mp_prec_t
# define mp_prec_t mpfr_prec_t
#endif

#ifndef __gmpfr_default_rounding_mode
#define __gmpfr_default_rounding_mode mpfr_get_default_rounding_mode()
#endif

/* Has inttypes.h been included ? */
int _has_inttypes(void) {
#ifdef _MSC_VER
return 0;
#else
#if defined MATH_MPFR_NEED_LONG_LONG_INT
return 1;
#else
return 0;
#endif
#endif
}

void Rmpfr_set_default_rounding_mode(pTHX_ SV * round) {
#if MPFR_VERSION_MAJOR < 3
     if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     mpfr_set_default_rounding_mode((mp_rnd_t)SvUV(round));
}

unsigned long Rmpfr_get_default_rounding_mode(void) {
     return __gmpfr_default_rounding_mode;
}

SV * Rmpfr_prec_round(pTHX_ mpfr_t * p, SV * prec, SV * round) {
     return newSViv(mpfr_prec_round(*p, (mpfr_prec_t)SvIV(prec), (mp_rnd_t)SvUV(round)));
}

void DESTROY(pTHX_ mpfr_t * p) {
     mpfr_clear(*p);
     Safefree(p);
}

void Rmpfr_clear(pTHX_ mpfr_t * p) {
     mpfr_clear(*p);
     Safefree(p);
}

void Rmpfr_clear_mpfr(mpfr_t * p) {
     mpfr_clear(*p);
}

void Rmpfr_clear_ptr(pTHX_ mpfr_t * p) {
     Safefree(p);
}

void Rmpfr_clears(pTHX_ SV * p, ...) {
     dXSARGS;
     unsigned long i;
     for(i = 0; i < items; i++) {
        mpfr_clear(*(INT2PTR(mpfr_t *, SvIV(SvRV(ST(i))))));
        Safefree(INT2PTR(mpfr_t *, SvIV(SvRV(ST(i)))));
     }
     XSRETURN(0);
}

SV * Rmpfr_init(pTHX) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfr_init2(pTHX_ SV * prec) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init2 function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init2 (*mpfr_t_obj, (mpfr_prec_t)SvIV(prec));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfr_init_nobless(pTHX) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     mpfr_init(*mpfr_t_obj);

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rmpfr_init2_nobless(pTHX_ SV * prec) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init2_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     mpfr_init2 (*mpfr_t_obj, (mpfr_prec_t)SvIV(prec));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

void Rmpfr_init_set(pTHX_ mpfr_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;
/*
     if(GIMME_V != G_ARRAY && SvIV(get_sv("Math::MPFR::WARN", 0))) {
         warn("You are discarding the Math::MPFR object that Rmpfr_init_set has created.");
         warn("%s%s%s%s",
              "This is probably NOT what you want !!\n",
              "Refer to the Rmpfr_init_set documentation in the\n",
              "'COMBINED INITIALIZATION AND ASSIGNMENT' section.\n",
              "(You can disable this warning by setting $Math::MPFR::WARN to 0.)");
     }
*/
#if MPFR_VERSION_MAJOR < 3
     if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_ui(pTHX_ SV * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_ui function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set_ui(*mpfr_t_obj, (unsigned long)SvUV(q), (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_si(pTHX_ SV * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_si function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set_si(*mpfr_t_obj, (long)SvIV(q), (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_d(pTHX_ SV * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp =  mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_d function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set_d(*mpfr_t_obj, (double)SvNV(q), (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_ld(pTHX_ SV * q, SV * round) {
#ifdef USE_LONG_DOUBLE
#ifndef _MSC_VER
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_d function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set_ld(*mpfr_t_obj, (long double)SvNV(q), (mp_rnd_t)SvUV(round));
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
#else
     croak("Rmpfr_init_set_ld not implemented on this build of perl - use Rmpfr_init_set_d instead");
#endif
#else
     croak("Rmpfr_init_set_ld not implemented on this build of perl");
#endif
}

void Rmpfr_init_set_f(pTHX_ mpf_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_f function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set_f(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_z(pTHX_ mpz_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_z function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set_z(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_q(pTHX_ mpq_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_q function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     ret = mpfr_init_set_q(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_str(pTHX_ SV * q, SV * base, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret = (int)SvIV(base);

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     if(ret < 0 || ret > MAXIMUM_ALLOWABLE_BASE || ret == 1)
        croak("2nd argument supplied to Rmpfr_init_set str is out of allowable range");

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_str function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ret = mpfr_init_set_str(*mpfr_t_obj, SvPV_nolen(q), ret, (mp_rnd_t)SvUV(round));

     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_nobless(pTHX_ mpfr_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_ui_nobless(pTHX_ SV * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp  = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_ui_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set_ui(*mpfr_t_obj, (unsigned long)SvUV(q), (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_si_nobless(pTHX_ SV * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_si_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set_si(*mpfr_t_obj, (long)SvIV(q), (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_d_nobless(pTHX_ SV * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_d_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set_d(*mpfr_t_obj, (double)SvNV(q), (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_ld_nobless(pTHX_ SV * q, SV * round) {
#ifdef USE_LONG_DOUBLE
#ifndef _MSC_VER
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_d_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set_ld(*mpfr_t_obj, (long double)SvNV(q), (mp_rnd_t)SvUV(round));
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
#else
     croak("Rmpfr_init_set_ld_nobless not implemented on this build of perl - use Rmpfr_init_set_d_nobless instead");
#endif
#else
     croak("Rmpfr_init_set_ld_nobless not implemented on this build of perl");
#endif
}

void Rmpfr_init_set_f_nobless(pTHX_ mpf_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_f_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set_f(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1)  = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_z_nobless(pTHX_ mpz_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp  = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_z_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set_z(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_q_nobless(pTHX_ mpq_t * q, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_q_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     ret = mpfr_init_set_q(*mpfr_t_obj, *q, (mp_rnd_t)SvUV(round));

     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_init_set_str_nobless(pTHX_ SV * q, SV * base, SV * round) {
     dXSARGS;
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;
     int ret = (int)SvIV(base);

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     if(ret < 0 || ret > MAXIMUM_ALLOWABLE_BASE || ret == 1)
        croak("2nd argument supplied to Rmpfr_init_set_str_nobless is out of allowable range");

     /* sp = mark; *//* not needed */

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in Rmpfr_init_set_str_nobless function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     ret = mpfr_init_set_str(*mpfr_t_obj, SvPV_nolen(q), ret, (mp_rnd_t)SvUV(round));

     ST(0) = sv_2mortal(obj_ref);
     ST(1) = sv_2mortal(newSViv(ret));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_deref2(pTHX_ mpfr_t * p, SV * base, SV * n_digits, SV * round) {
     dXSARGS;
     char * out;
     mp_exp_t ptr;
     unsigned long b = (unsigned long)SvUV(base);

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     if(b < 2 || b > MAXIMUM_ALLOWABLE_BASE)
        croak("Second argument supplied to Rmpfr_get_str is not in acceptable range");

     out = mpfr_get_str(0, &ptr, b, (unsigned long)SvUV(n_digits), *p, (mp_rnd_t)SvUV(round));

     if(out == NULL) croak("An error occurred in mpfr_get_str\n");

     /* sp  = mark; *//* not needed */
     ST(0) = sv_2mortal(newSVpv(out, 0));
     mpfr_free_str(out);
     ST(1) = sv_2mortal(newSViv(ptr));
     /* PUTBACK; *//* not needed */
     XSRETURN(2);
}

void Rmpfr_set_default_prec(pTHX_ SV * prec) {
     mpfr_set_default_prec((mpfr_prec_t)SvIV(prec));
}

SV * Rmpfr_get_default_prec(pTHX) {
     return newSViv(mpfr_get_default_prec());
}

SV * Rmpfr_min_prec(pTHX_ mpfr_t * x) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv((mpfr_prec_t)mpfr_min_prec(*x));
#else
     croak("Rmpfr_min_prec function not implemented for mpfr versions prior to version 3");
#endif
}

void Rmpfr_set_prec(pTHX_ mpfr_t * p, SV * prec) {
     mpfr_set_prec(*p, (mpfr_prec_t)SvIV(prec));
}

void Rmpfr_set_prec_raw(pTHX_ mpfr_t * p, SV * prec) {
     mpfr_set_prec_raw(*p, (mpfr_prec_t)SvIV(prec));
}

SV * Rmpfr_get_prec(pTHX_ mpfr_t * p) {
     return newSViv(mpfr_get_prec(*p));
}

SV * Rmpfr_set(pTHX_ mpfr_t * p, mpfr_t * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_set(*p, *q, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_ui(pTHX_ mpfr_t * p, SV * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_set_ui(*p, (unsigned long)SvUV(q), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_si(pTHX_ mpfr_t * p, SV * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_set_si(*p, (long)SvIV(q), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_uj(pTHX_ mpfr_t * p, SV * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     return newSViv(mpfr_set_uj(*p, SvUV(q), (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_set_uj not implemented on this build of perl - use Rmpfr_set_str instead");
#endif
#else
     croak("Rmpfr_set_uj not implemented on this build of perl");
#endif
}

SV * Rmpfr_set_sj(pTHX_ mpfr_t * p, SV * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     return newSViv(mpfr_set_sj(*p, SvIV(q), (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_set_sj not implemented on this build of perl - use Rmpfr_set_str instead");
#endif
#else
     croak("Rmpfr_set_sj not implemented on this build of perl");
#endif
}

SV * Rmpfr_set_NV(pTHX_ mpfr_t * p, SV * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if defined(USE_LONG_DOUBLE) && !defined(_MSC_VER) && !defined(CAN_PASS_FLOAT128)
     return newSViv(mpfr_set_ld(*p, (long double)SvNV(q), (mp_rnd_t)SvUV(round)));
#elif defined(CAN_PASS_FLOAT128)
     return newSViv(mpfr_set_float128(*p, (float128)SvNV(q), (mp_rnd_t)SvUV(round)));
#else
     return newSViv(mpfr_set_d (*p, (double)SvNV(q), (mp_rnd_t)SvUV(round)));
#endif
}

SV * Rmpfr_set_ld(pTHX_ mpfr_t * p, SV * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef USE_LONG_DOUBLE
#ifndef _MSC_VER
     return newSViv(mpfr_set_ld(*p, (long double)SvNV(q), (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_set_ld not implemented on this build of perl - use Rmpfr_set_d instead");
#endif
#else
     croak("Rmpfr_set_ld not implemented on this build of perl");
#endif
}

SV * Rmpfr_set_d(pTHX_ mpfr_t * p, SV * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_set_d(*p, (double)SvNV(q), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_z(pTHX_ mpfr_t * p, mpz_t * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_set_z(*p, *q, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_q(pTHX_ mpfr_t * p, mpq_t * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_set_q(*p, *q, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_f(pTHX_ mpfr_t * p, mpf_t * q, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_set_f(*p, *q, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_str(pTHX_ mpfr_t * p, SV * num, SV * base, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     int b = (int)SvIV(base);
     if(b < 0 || b > MAXIMUM_ALLOWABLE_BASE || b == 1)
        croak("3rd argument supplied to Rmpfr_set_str is out of allowable range");
     return newSViv(mpfr_set_str(*p, SvPV_nolen(num), b, (mp_rnd_t)SvUV(round)));
}

void Rmpfr_set_str_binary(pTHX_ mpfr_t * p, SV * str) {
     mpfr_set_str_binary(*p, SvPV_nolen(str));
}

void Rmpfr_set_inf(mpfr_t * p, int sign) {
     mpfr_set_inf(*p, sign);
}

void Rmpfr_set_nan(mpfr_t * p) {
     mpfr_set_nan(*p);
}

void Rmpfr_swap(mpfr_t *p, mpfr_t * q) {
     mpfr_swap(*p, *q);
}

SV * Rmpfr_get_d(pTHX_ mpfr_t * p, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSVnv(mpfr_get_d(*p, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_get_d_2exp(pTHX_ SV * exp, mpfr_t * p, SV * round){
     long _exp;
     double ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     ret = mpfr_get_d_2exp(&_exp, *p, (mp_rnd_t)SvUV(round));
     sv_setiv(exp, _exp);
     return newSVnv(ret);
}

SV * Rmpfr_get_ld_2exp(pTHX_ SV * exp, mpfr_t * p, SV * round){
#ifdef USE_LONG_DOUBLE
#ifndef _MSC_VER
     long _exp;
     long double ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     ret = mpfr_get_ld_2exp(&_exp, *p, (mp_rnd_t)SvUV(round));
     sv_setiv(exp, _exp);
     return newSVnv(ret);
#else
     croak("Rmpfr_get_ld_2exp not implemented on this build of perl - use Rmpfr_get_d_2exp instead");
#endif
#else
     croak("Rmpfr_get_ld_2exp not implemented on this build of perl");
#endif
}

SV * Rmpfr_get_ld(pTHX_ mpfr_t * p, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef USE_LONG_DOUBLE
#ifndef _MSC_VER
     return newSVnv(mpfr_get_ld(*p, (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_get_ld not implemented on this build of perl - use Rmpfr_get_d instead");
#endif
#else
     croak("Rmpfr_get_ld not implemented on this build of perl");
#endif
}

double Rmpfr_get_d1(mpfr_t * p) {
     return mpfr_get_d1(*p);
}

/* Alias for the perl function Rmpfr_get_z_exp
*  (which will perhaps one day be removed).
*  The mpfr headers define 'mpfr_get_z_exp' to
*  'mpfr_get_z_2exp' when that function is
*  available.
*/
SV * Rmpfr_get_z_2exp(pTHX_ mpz_t * z, mpfr_t * p){
     return newSViv(mpfr_get_z_exp(*z, *p));
}

SV * Rmpfr_add(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_add(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_add_ui(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_add_ui(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_add_d(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_add_d(*a, *b, (double)SvNV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_add_si(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_add_si(*a, *b, (int)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_add_z(pTHX_ mpfr_t * a, mpfr_t * b, mpz_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_add_z(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_add_q(pTHX_ mpfr_t * a, mpfr_t * b, mpq_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_add_q(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sub(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sub(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sub_ui(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sub_ui(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sub_d(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sub_d(*a, *b, (double)SvNV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sub_z(pTHX_ mpfr_t * a, mpfr_t * b, mpz_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sub_z(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sub_q(pTHX_ mpfr_t * a, mpfr_t * b, mpq_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sub_q(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_ui_sub(pTHX_ mpfr_t * a, SV * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_ui_sub(*a, (unsigned long)SvUV(b), *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_d_sub(pTHX_ mpfr_t * a, SV * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_d_sub(*a, (double)SvNV(b), *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_ui(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_ui(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_d(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_d(*a, *b, (double)SvNV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_z(pTHX_ mpfr_t * a, mpfr_t * b, mpz_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_z(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_q(pTHX_ mpfr_t * a, mpfr_t * b, mpq_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_q(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_dim(pTHX_ mpfr_t * rop, mpfr_t * op1, mpfr_t * op2, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
         int ret = mpfr_dim( *rop, *op1, *op2, (mp_rnd_t)SvUV(round));
         return newSViv(ret);
}

SV * Rmpfr_div(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_ui(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_ui(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_d(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_d(*a, *b, (double)SvNV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_z(pTHX_ mpfr_t * a, mpfr_t * b, mpz_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_z(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_q(pTHX_ mpfr_t * a, mpfr_t * b, mpq_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_q(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_ui_div(pTHX_ mpfr_t * a, SV * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_ui_div(*a, (unsigned long)SvUV(b), *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_d_div(pTHX_ mpfr_t * a, SV * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_d_div(*a, (double)SvNV(b), *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sqrt(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sqrt(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_rec_sqrt(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_rec_sqrt(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_cbrt(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_cbrt(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sqrt_ui(pTHX_ mpfr_t * a, SV * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sqrt_ui(*a, (unsigned long)SvUV(b), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_pow_ui(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_pow_ui(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_ui_pow_ui(pTHX_ mpfr_t * a, SV * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_ui_pow_ui(*a, (unsigned long)SvUV(b), (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_ui_pow(pTHX_ mpfr_t * a, SV * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_ui_pow(*a, (unsigned long)SvUV(b), *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_pow_si(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_pow_si(*a, *b, (long)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_pow(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_pow(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_neg(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_neg(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_abs(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_abs(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_2exp(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_2exp(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_2ui(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_2ui(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_2si(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_2si(*a, *b, (long)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_2exp(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_2exp(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_2ui(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_2ui(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_2si(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_2si(*a, *b, (long)SvIV(c), (mp_rnd_t)SvUV(round)));
}

int Rmpfr_cmp(mpfr_t * a, mpfr_t * b) {
     return mpfr_cmp(*a, *b);
}

int Rmpfr_cmpabs(mpfr_t * a, mpfr_t * b) {
     return mpfr_cmpabs(*a, *b);
}

int Rmpfr_cmp_ui(mpfr_t * a, unsigned long b) {
     return mpfr_cmp_ui(*a, b);
}

int Rmpfr_cmp_d(mpfr_t * a, double b) {
     return mpfr_cmp_d(*a, b);
}

int Rmpfr_cmp_ld(pTHX_ mpfr_t * a, SV * b) {
#ifdef USE_LONG_DOUBLE
#ifndef _MSC_VER
     return mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
     croak("Rmpfr_cmp_ld not implemented on this build of perl - use Rmpfr_cmp_d instead");
#endif
#else
     croak("Rmpfr_cmp_ld not implemented on this build of perl");
#endif
}

int Rmpfr_cmp_si(mpfr_t * a, long b) {
     return mpfr_cmp_si(*a, b);
}

int Rmpfr_cmp_ui_2exp(pTHX_ mpfr_t * a, SV * b, SV * c) {
     return mpfr_cmp_ui_2exp(*a, (unsigned long)SvUV(b), (mp_exp_t)SvIV(c));
}

int Rmpfr_cmp_si_2exp(pTHX_ mpfr_t * a, SV * b, SV * c) {
     return mpfr_cmp_si_2exp(*a, (long)SvIV(b), (mp_exp_t)SvIV(c));
}

int Rmpfr_eq(mpfr_t * a, mpfr_t * b, unsigned long c) {
     return mpfr_eq(*a, *b, c);
}

int Rmpfr_nan_p(mpfr_t * p) {
     return mpfr_nan_p(*p);
}

int Rmpfr_inf_p(mpfr_t * p) {
     return mpfr_inf_p(*p);
}

int Rmpfr_number_p(mpfr_t * p) {
     return mpfr_number_p(*p);
}

void Rmpfr_reldiff(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     mpfr_reldiff(*a, *b, *c, (mp_rnd_t)SvUV(round));
}

int Rmpfr_sgn(mpfr_t * p) {
     return mpfr_sgn(*p);
}

int Rmpfr_greater_p(mpfr_t * a, mpfr_t * b) {
     return mpfr_greater_p(*a, *b);
}

int Rmpfr_greaterequal_p(mpfr_t * a, mpfr_t * b) {
     return mpfr_greaterequal_p(*a, *b);
}

int Rmpfr_less_p(mpfr_t * a, mpfr_t * b) {
     return mpfr_less_p(*a, *b);
}

int Rmpfr_lessequal_p(mpfr_t * a, mpfr_t * b) {
     return mpfr_lessequal_p(*a, *b);
}

int Rmpfr_lessgreater_p(mpfr_t * a, mpfr_t * b) {
     return mpfr_lessgreater_p(*a, *b);
}

int Rmpfr_equal_p(mpfr_t * a, mpfr_t * b) {
     return mpfr_equal_p(*a, *b);
}

int Rmpfr_unordered_p(mpfr_t * a, mpfr_t * b) {
     return mpfr_unordered_p(*a, *b);
}

SV * Rmpfr_sin_cos(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sin_cos(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sinh_cosh(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sinh_cosh(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sin(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sin(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_cos(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_cos(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_tan(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_tan(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_asin(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_asin(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_acos(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_acos(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_atan(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_atan(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sinh(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sinh(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_cosh(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_cosh(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_tanh(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_tanh(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_asinh(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_asinh(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_acosh(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_acosh(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_atanh(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_atanh(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fac_ui(pTHX_ mpfr_t * a, SV * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_fac_ui(*a, (unsigned long)SvUV(b), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_log1p(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_log1p(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_expm1(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_expm1(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_log2(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_log2(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_log10(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_log10(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fma(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, mpfr_t * d, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_fma(*a, *b, *c, *d, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fms(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, mpfr_t * d, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_fms(*a, *b, *c, *d, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_agm(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_agm(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_hypot(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_hypot(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_const_log2(pTHX_ mpfr_t * p, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_const_log2(*p, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_const_pi(pTHX_ mpfr_t * p, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_const_pi(*p, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_const_euler(pTHX_ mpfr_t * p, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_const_euler(*p, (mp_rnd_t)SvUV(round)));
}

void Rmpfr_print_binary(mpfr_t * p) {
     mpfr_print_binary(*p);
}

SV * Rmpfr_rint(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_rint(*a, *b, (mp_rnd_t)SvUV(round)));
}

int Rmpfr_ceil(mpfr_t * a, mpfr_t * b) {
     return mpfr_ceil(*a, *b);
}

int Rmpfr_floor(mpfr_t * a, mpfr_t * b) {
     return mpfr_floor(*a, *b);
}

int Rmpfr_round(mpfr_t * a, mpfr_t * b) {
     return mpfr_round(*a, *b);
}

int Rmpfr_trunc(mpfr_t * a, mpfr_t * b) {
     return mpfr_trunc(*a, *b);
}

/* NO LONGER SUPPORTED
SV * Rmpfr_add_one_ulp(mpfr_t * p, SV * round) {
     return newSViv(mpfr_add_one_ulp(*p, (mp_rnd_t)SvUV(round)));
} */

/* NO LONGER SUPPORTED
SV * Rmpfr_sub_one_ulp(SV * p, SV * round) {
     return newSViv(mpfr_sub_one_ulp(*p, (mp_rnd_t)SvUV(round)));
} */

SV * Rmpfr_can_round(pTHX_ mpfr_t * p, SV * err, SV * round1, SV * round2, SV * prec) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round1) > 3 || (mp_rnd_t)SvUV(round2) > 3)
      croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_can_round(*p, (mp_exp_t)SvIV(err), SvUV(round1), SvUV(round2), (mpfr_prec_t)SvIV(prec)));
}

SV * Rmpfr_get_emin(pTHX) {
     return newSViv(mpfr_get_emin());
}

SV * Rmpfr_get_emax(pTHX) {
     return newSViv(mpfr_get_emax());
}

int Rmpfr_set_emin(pTHX_ SV * e) {
     return mpfr_set_emin((mp_exp_t)SvIV(e));
}

int Rmpfr_set_emax(pTHX_ SV * e) {
     return mpfr_set_emax((mp_exp_t)SvIV(e));
}

SV * Rmpfr_check_range(pTHX_ mpfr_t * p, SV * t, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_check_range(*p, (int)SvIV(t), (mp_rnd_t)SvUV(round)));
}

void Rmpfr_clear_underflow(void) {
     mpfr_clear_underflow();
}

void Rmpfr_clear_overflow(void) {
     mpfr_clear_overflow();
}

void Rmpfr_clear_nanflag(void) {
     mpfr_clear_nanflag();
}

void Rmpfr_clear_inexflag(void) {
     mpfr_clear_inexflag();
}

void Rmpfr_clear_flags(void) {
     mpfr_clear_flags();
}

int Rmpfr_underflow_p(void) {
     return mpfr_underflow_p();
}

int Rmpfr_overflow_p(void) {
     return mpfr_overflow_p();
}

int Rmpfr_nanflag_p(void) {
     return mpfr_nanflag_p();
}

int Rmpfr_inexflag_p(void) {
     return mpfr_inexflag_p();
}

SV * Rmpfr_log(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_log(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_exp(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_exp(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_exp2(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_exp2(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_exp10(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_exp10(*a, *b, (mp_rnd_t)SvUV(round)));
}

void Rmpfr_urandomb(pTHX_ SV * x, ...) {
     dXSARGS;
     unsigned long i, t;

     t = items;
     --t;

     for(i = 0; i < t; ++i) {
        mpfr_urandomb(*(INT2PTR(mpfr_t *, SvIV(SvRV(ST(i))))), *(INT2PTR(gmp_randstate_t *, SvIV(SvRV(ST(t))))));
        }
     XSRETURN(0);
}

void Rmpfr_random2(pTHX_ mpfr_t * p, SV * s, SV * exp) {
#if MPFR_VERSION_MAJOR > 2
     croak("Rmpfr_random2 no longer implemented. Use Rmpfr_urandom or Rmpfr_urandomb");
#else
     mpfr_random2(*p, (int)SvIV(s), (mp_exp_t)SvIV(exp));
#endif
}

SV * _TRmpfr_out_str(pTHX_ FILE * stream, SV * base, SV * dig, mpfr_t * p, SV * round) {
     size_t ret;
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
        croak("2nd argument supplied to TRmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
        MAXIMUM_ALLOWABLE_BASE);
     ret = mpfr_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfr_out_str(pTHX_ mpfr_t * p, SV * base, SV * dig, SV * round) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
        croak("2nd argument supplied to Rmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
        MAXIMUM_ALLOWABLE_BASE);
     ret = mpfr_out_str(NULL, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     fflush(stdout);
     return newSVuv(ret);
}

SV * _TRmpfr_out_strS(pTHX_ FILE * stream, SV * base, SV * dig, mpfr_t * p, SV * round, SV * suff) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
       croak("2nd argument supplied to TRmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
       MAXIMUM_ALLOWABLE_BASE);
     ret = mpfr_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * _TRmpfr_out_strP(pTHX_ SV * pre, FILE * stream, SV * base, SV * dig, mpfr_t * p, SV * round) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
        croak("3rd argument supplied to TRmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
        MAXIMUM_ALLOWABLE_BASE);
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpfr_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     fflush(stream);
     return newSVuv(ret);
}

SV * _TRmpfr_out_strPS(pTHX_ SV * pre, FILE * stream, SV * base, SV * dig, mpfr_t * p, SV * round, SV * suff) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
        croak("3rd argument supplied to TRmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
        MAXIMUM_ALLOWABLE_BASE);
     fprintf(stream, "%s", SvPV_nolen(pre));
     fflush(stream);
     ret = mpfr_out_str(stream, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     fflush(stream);
     fprintf(stream, "%s", SvPV_nolen(suff));
     fflush(stream);
     return newSVuv(ret);
}

SV * _Rmpfr_out_strS(pTHX_ mpfr_t * p, SV * base, SV * dig, SV * round, SV * suff) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
       croak("2nd argument supplied to Rmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
       MAXIMUM_ALLOWABLE_BASE);
     ret = mpfr_out_str(NULL, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     printf("%s", SvPV_nolen(suff));
     fflush(stdout);
     return newSVuv(ret);
}

SV * _Rmpfr_out_strP(pTHX_ SV * pre, mpfr_t * p, SV * base, SV * dig, SV * round) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
        croak("3rd argument supplied to Rmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
        MAXIMUM_ALLOWABLE_BASE);
     printf("%s", SvPV_nolen(pre));
     ret = mpfr_out_str(NULL, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     fflush(stdout);
     return newSVuv(ret);
}

SV * _Rmpfr_out_strPS(pTHX_ SV * pre, mpfr_t * p, SV * base, SV * dig, SV * round, SV * suff) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
       croak("3rd argument supplied to Rmpfr_out_str is out of allowable range (must be between 2 and %d inclusive)",
       MAXIMUM_ALLOWABLE_BASE);
     printf("%s", SvPV_nolen(pre));
     ret = mpfr_out_str(NULL, (int)SvIV(base), (size_t)SvUV(dig), *p, (mp_rnd_t)SvUV(round));
     printf("%s", SvPV_nolen(suff));
     fflush(stdout);
     return newSVuv(ret);
}

SV * TRmpfr_inp_str(pTHX_ mpfr_t * p, FILE * stream, SV * base, SV * round) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
        croak("3rd argument supplied to TRmpfr_inp_str is out of allowable range (must be between 2 and %d inclusive)",
        MAXIMUM_ALLOWABLE_BASE);
     ret = mpfr_inp_str(*p, stream, (int)SvIV(base), (mp_rnd_t)SvUV(round));
     /* fflush(stream); */
     return newSVuv(ret);
}

SV * Rmpfr_inp_str(pTHX_ mpfr_t * p, SV * base, SV * round) {
     size_t ret;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(SvIV(base) < 2 || SvIV(base) > MAXIMUM_ALLOWABLE_BASE)
        croak("2nd argument supplied to Rmpfr_inp_str is out of allowable range (must be between 2 and %d inclusive)",
        MAXIMUM_ALLOWABLE_BASE);
     ret = mpfr_inp_str(*p, NULL, (int)SvIV(base), (mp_rnd_t)SvUV(round));
     /* fflush(stdin); */
     return newSVuv(ret);
}

SV * Rmpfr_gamma(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_gamma(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_zeta(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_zeta(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_zeta_ui(pTHX_ mpfr_t * a, SV * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_zeta_ui(*a, (unsigned long)SvUV(b), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_erf(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_erf(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_frac(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_frac(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_remainder(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_remainder(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_modf(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_modf(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fmod(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_fmod(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

void Rmpfr_remquo(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
     dXSARGS;
     long ret, q;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     ret = mpfr_remquo(*a, &q, *b, *c, (mp_rnd_t)SvUV(round));
     ST(0) = sv_2mortal(newSViv(q));
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

int Rmpfr_integer_p(mpfr_t * p) {
     return mpfr_integer_p(*p);
}

void Rmpfr_nexttoward(mpfr_t * a, mpfr_t * b) {
     mpfr_nexttoward(*a, *b);
}

void Rmpfr_nextabove(mpfr_t * p) {
     mpfr_nextabove(*p);
}

void Rmpfr_nextbelow(mpfr_t * p) {
     mpfr_nextbelow(*p);
}

SV * Rmpfr_min(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_min(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_max(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_max(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_get_exp(pTHX_ mpfr_t * p) {
     return newSViv(mpfr_get_exp(*p));
}

SV * Rmpfr_set_exp(pTHX_ mpfr_t * p, SV * exp) {
     return newSViv(mpfr_set_exp(*p, (mp_exp_t)SvIV(exp)));
}

int Rmpfr_signbit(mpfr_t * op) {
     return mpfr_signbit(*op);
}

SV * Rmpfr_setsign(pTHX_ mpfr_t * rop, mpfr_t * op, SV * sign, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_setsign(*rop, *op, SvIV(sign), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_copysign(pTHX_ mpfr_t * rop, mpfr_t * op1, mpfr_t * op2, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_copysign(*rop, *op1, *op2, (mp_rnd_t)SvUV(round)));
}

SV * get_refcnt(pTHX_ SV * s) {
     return newSVuv(SvREFCNT(s));
}

SV * get_package_name(pTHX_ SV * x) {
     if(sv_isobject(x)) return newSVpv(HvNAME(SvSTASH(SvRV(x))), 0);
     return newSViv(0);
}

void Rmpfr_dump(mpfr_t * a) { /* Once took a 'round' argument */
     mpfr_dump(*a);
}

SV * gmp_v(pTHX) {
#if __GNU_MP_VERSION >= 4
     return newSVpv(gmp_version, 0);
#else
     warn("From Math::MPFR::gmp_v(aTHX): 'gmp_version' is not implemented - returning '0'");
     return newSVpv("0", 0);
#endif
}

/* NEW in MPFR-2.1.0 */

SV * Rmpfr_set_ui_2exp(pTHX_ mpfr_t * a, SV * b, SV * c, SV * round) {
     return newSViv(mpfr_set_ui_2exp(*a, (unsigned long)SvUV(b), (mp_exp_t)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_si_2exp(pTHX_ mpfr_t * a, SV * b, SV * c, SV * round) {
     return newSViv(mpfr_set_si_2exp(*a, (long)SvIV(b), (mp_exp_t)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_set_uj_2exp(pTHX_ mpfr_t * a, SV * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     return newSViv(mpfr_set_uj_2exp(*a, SvUV(b), SvIV(c), (mp_rnd_t)SvUV(round)));
#else
     croak ("Rmpfr_set_uj_2exp not implemented on this build of perl");
#endif
#else
     croak ("Rmpfr_set_uj_2exp not implemented on this build of perl");
#endif
}

SV * Rmpfr_set_sj_2exp(pTHX_ mpfr_t * a, SV * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     return newSViv(mpfr_set_sj_2exp(*a, SvIV(b), SvIV(c), (mp_rnd_t)SvUV(round)));
#else
     croak ("Rmpfr_set_sj_2exp not implemented on this build of perl");
#endif
#else
     croak ("Rmpfr_set_sj_2exp not implemented on this build of perl");
#endif
}

SV * Rmpfr_get_z(pTHX_ mpz_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if MPFR_VERSION_MAJOR < 3
     mpfr_get_z(*a, *b, (mp_rnd_t)SvUV(round));
     return &PL_sv_undef;
#else
     return newSViv(mpfr_get_z(*a, *b, (mp_rnd_t)SvUV(round)));
#endif
}

SV * Rmpfr_si_sub(pTHX_ mpfr_t * a, SV * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_si_sub(*a, (long)SvIV(b), *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sub_si(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sub_si(*a, *b, (long)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_mul_si(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_mul_si(*a, *b, (long)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_si_div(pTHX_ mpfr_t * a, SV * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_si_div(*a, (long)SvIV(b), *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_div_si(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round){
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_div_si(*a, *b, (long)SvIV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sqr(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sqr(*a, *b, (mp_rnd_t)SvUV(round)));
}

int Rmpfr_cmp_z(mpfr_t * a, mpz_t * b) {
     return mpfr_cmp_z(*a, *b);
}

int Rmpfr_cmp_q(mpfr_t * a, mpq_t * b) {
     return mpfr_cmp_q(*a, *b);
}

int Rmpfr_cmp_f(mpfr_t * a, mpf_t * b) {
     return mpfr_cmp_f(*a, *b);
}

int Rmpfr_zero_p(mpfr_t * a) {
     return mpfr_zero_p(*a);
}

void Rmpfr_free_cache(void) {
     mpfr_free_cache();
}

SV * Rmpfr_get_version(pTHX) {
     return newSVpv(mpfr_get_version(), 0);
}

SV * Rmpfr_get_patches(pTHX) {
     return newSVpv(mpfr_get_patches(), 0);
}

SV * Rmpfr_get_emin_min(pTHX) {
     return newSViv(mpfr_get_emin_min());
}

SV * Rmpfr_get_emin_max(pTHX) {
     return newSViv(mpfr_get_emin_max());
}

SV * Rmpfr_get_emax_min(pTHX) {
     return newSViv(mpfr_get_emax_min());
}

SV * Rmpfr_get_emax_max(pTHX) {
     return newSViv(mpfr_get_emax_max());
}

void Rmpfr_clear_erangeflag(void) {
     mpfr_clear_erangeflag();
}

int Rmpfr_erangeflag_p(void) {
     return mpfr_erangeflag_p();
}

SV * Rmpfr_rint_round(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_rint_round(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_rint_trunc(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_rint_trunc(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_rint_ceil(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_rint_ceil(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_rint_floor(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_rint_floor(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_get_ui(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSVuv(mpfr_get_ui(*a, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_get_si(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_get_si(*a, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_get_uj(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef MATH_MPFR_NEED_LONG_LONG_INT
     return newSVuv(mpfr_get_uj(*a, (mp_rnd_t)SvUV(round)));
#else
     croak ("Rmpfr_get_uj not implemented on this build of perl");
#endif
}

SV * Rmpfr_get_sj(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#ifdef MATH_MPFR_NEED_LONG_LONG_INT
     return newSViv(mpfr_get_sj(*a, (mp_rnd_t)SvUV(round)));
#else
     croak ("Rmpfr_get_sj not implemented on this build of perl");
#endif
}

SV * Rmpfr_get_IV(pTHX_ mpfr_t * x, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(sizeof(IV) == sizeof(long)) return newSViv(mpfr_get_si(*x, (mp_rnd_t)SvUV(round)));
#if defined MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(sizeof(IV) == sizeof(intmax_t)) return newSViv(mpfr_get_sj(*x, (mp_rnd_t)SvUV(round)));
#else
     if(sizeof(IV) == sizeof(signed __int64)) return newSViv(mpfr_get_sj(*x, (mp_rnd_t)SvUV(round)));
#endif
#endif
     croak("Rmpfr_get_IV not implemented on this build of perl");
}

SV * Rmpfr_get_UV(pTHX_ mpfr_t * x, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     if(sizeof(UV) == sizeof(unsigned long)) return newSVuv(mpfr_get_ui(*x, (mp_rnd_t)SvUV(round)));
#if defined MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(sizeof(UV) == sizeof(uintmax_t)) return newSVuv(mpfr_get_uj(*x, (mp_rnd_t)SvUV(round)));
#else
     if(sizeof(UV) == sizeof(unsigned __int64)) return newSVuv(mpfr_get_uj(*x, (mp_rnd_t)SvUV(round)));
#endif
#endif
     croak("Rmpfr_get_UV not implemented on this build of perl");
}

SV * Rmpfr_get_NV(pTHX_ mpfr_t * x, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if defined(CAN_PASS_FLOAT128)
  return newSVnv(mpfr_get_float128(*x, (mp_rnd_t)SvUV(round)));
#elif defined(USE_LONG_DOUBLE)
  return newSVnv(mpfr_get_ld(*x, (mp_rnd_t)SvUV(round)));
#else
  return newSVnv(mpfr_get_d(*x, (mp_rnd_t)SvUV(round)));
#endif

}

SV * Rmpfr_fits_ulong_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
     return newSVuv(mpfr_fits_ulong_p(*a, (mp_rnd_t)SvUV(round)));
#else
     if((mp_rnd_t)SvUV(round) < 3) {
       if((mp_rnd_t)SvUV(round) == 0) {
         if((mpfr_cmp_d(*a, -0.5) >= 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
       else {
         if((mpfr_cmp_d(*a, -1.0) > 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
     }
     return newSVuv(mpfr_fits_ulong_p(*a, (mp_rnd_t)SvUV(round)));
#endif
}

SV * Rmpfr_fits_slong_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSVuv(mpfr_fits_slong_p(*a, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fits_ushort_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
     return newSVuv(mpfr_fits_ushort_p(*a, (mp_rnd_t)SvUV(round)));
#else
     if((mp_rnd_t)SvUV(round) < 3) {
       if((mp_rnd_t)SvUV(round) == 0) {
         if((mpfr_cmp_d(*a, -0.5) >= 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
       else {
         if((mpfr_cmp_d(*a, -1.0) > 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
     }
     return newSVuv(mpfr_fits_ushort_p(*a, (mp_rnd_t)SvUV(round)));
#endif
}

SV * Rmpfr_fits_sshort_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSVuv(mpfr_fits_sshort_p(*a, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fits_uint_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
     return newSVuv(mpfr_fits_uint_p(*a, (mp_rnd_t)SvUV(round)));
#else
     if((mp_rnd_t)SvUV(round) < 3) {
       if((mp_rnd_t)SvUV(round) == 0) {
         if((mpfr_cmp_d(*a, -0.5) >= 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
       else {
         if((mpfr_cmp_d(*a, -1.0) > 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
     }
     return newSVuv(mpfr_fits_uint_p(*a, (mp_rnd_t)SvUV(round)));
#endif
}

SV * Rmpfr_fits_sint_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSVuv(mpfr_fits_sint_p(*a, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fits_uintmax_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
     return newSVuv(mpfr_fits_uintmax_p(*a, (mp_rnd_t)SvUV(round)));
#else
     if((mp_rnd_t)SvUV(round) < 3) {
       if((mp_rnd_t)SvUV(round) == 0) {
         if((mpfr_cmp_d(*a, -0.5) >= 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
       else {
         if((mpfr_cmp_d(*a, -1.0) > 0) && (mpfr_cmp_d(*a, 0.0) <= 0)) return newSVuv(1);
       }
     }
     return newSVuv(mpfr_fits_uintmax_p(*a, (mp_rnd_t)SvUV(round)));
#endif
}

SV * Rmpfr_fits_intmax_p(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSVuv(mpfr_fits_intmax_p(*a, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_fits_IV_p(pTHX_ mpfr_t * x, SV * round) {
     unsigned long ret = 0, bits = sizeof(IV) * 8;
     mpfr_t high, low, copy;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     if(sizeof(IV) == sizeof(long)) {
       if(mpfr_fits_slong_p(*x, (mp_rnd_t)SvUV(round))) return newSVuv(1);
       return newSVuv(0);
     }

     if(sizeof(IV) == sizeof(int)) {
       if(mpfr_fits_sint_p(*x, (mp_rnd_t)SvUV(round))) return newSVuv(1);
       return newSVuv(0);
     }

#if defined MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(sizeof(IV) == sizeof(intmax_t)) {
       if(mpfr_fits_intmax_p(*x, (mp_rnd_t)SvUV(round))) return newSVuv(1);
       return newSVuv(0);
     }
#else
     if(sizeof(IV) == sizeof(signed __int64)) {
       if(mpfr_fits_intmax_p(*x, (mp_rnd_t)SvUV(round))) return newSVuv(1);
       return newSVuv(0);
     }
#endif
#endif

     mpfr_init2(high, bits);
     mpfr_init2(low, bits);
     mpfr_init2(copy, bits - 1);

     mpfr_set_ui(high, 1, GMP_RNDN);
     mpfr_mul_2exp(high, high, bits - 1, GMP_RNDN);
     mpfr_sub_ui(high, high, 1, GMP_RNDN);

     mpfr_setsign(low, high, 1, GMP_RNDN);
     mpfr_sub_ui(low, low, 1, GMP_RNDN);
     mpfr_set(copy, *x, (mp_rnd_t)SvUV(round));

     if(mpfr_lessequal_p(copy, high) && mpfr_greaterequal_p(copy, low)) ret = 1;

     mpfr_clear(high);
     mpfr_clear(low);
     mpfr_clear(copy);

     return newSVuv(ret);
}

SV * Rmpfr_fits_UV_p(pTHX_ mpfr_t * x, SV * round) {
     unsigned long ret = 0, bits = sizeof(UV) * 8;
     mpfr_t high, copy;

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     if(sizeof(UV) == sizeof(unsigned long)) {
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
       return newSVuv(mpfr_fits_ulong_p(*x, (mp_rnd_t)SvUV(round)));
#else /* MPFR_VERSION unsatisfied */
       if((mp_rnd_t)SvUV(round) < 3) {
         if((mp_rnd_t)SvUV(round) == 0) {
           if((mpfr_cmp_d(*x, -0.5) >= 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
         else {
           if((mpfr_cmp_d(*x, -1.0) > 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
       }
       return newSVuv(mpfr_fits_ulong_p(*x, (mp_rnd_t)SvUV(round)));
#endif /* MPFR_VERSION */
     }

     if(sizeof(UV) == sizeof(unsigned int)) {
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
       return newSVuv(mpfr_fits_uint_p(*x, (mp_rnd_t)SvUV(round)));
#else /* MPFR_VERSION unsatisfied */
       if((mp_rnd_t)SvUV(round) < 3) {
         if((mp_rnd_t)SvUV(round) == 0) {
           if((mpfr_cmp_d(*x, -0.5) >= 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
         else {
           if((mpfr_cmp_d(*x, -1.0) > 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
       }
       return newSVuv(mpfr_fits_uint_p(*x, (mp_rnd_t)SvUV(round)));
#endif /* MPFR_VERSION */
     }

#if defined MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(sizeof(UV) == sizeof(uintmax_t)) {
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
       return newSVuv(mpfr_fits_uintmax_p(*x, (mp_rnd_t)SvUV(round)));
#else /* MPFR_VERSION unsatisfied */
       if((mp_rnd_t)SvUV(round) < 3) {
         if((mp_rnd_t)SvUV(round) == 0) {
           if((mpfr_cmp_d(*x, -0.5) >= 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
         else {
           if((mpfr_cmp_d(*x, -1.0) > 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
       }
       return newSVuv(mpfr_fits_uintmax_p(*x, (mp_rnd_t)SvUV(round)));
#endif /* MPFR_VERSION */
     }
#else /* _MSC_VER defined */
     if(sizeof(UV) == sizeof(unsigned __int64)) {
#if defined(MPFR_VERSION) && MPFR_VERSION > NEG_ZERO_BUG
       return newSVuv(mpfr_fits_uintmax_p(*x, (mp_rnd_t)SvUV(round)));
#else /* MPFR_VERSION unsatisfied */
       if((mp_rnd_t)SvUV(round) < 3) {
         if((mp_rnd_t)SvUV(round) == 0) {
           if((mpfr_cmp_d(*x, -0.5) >= 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
         else {
           if((mpfr_cmp_d(*x, -1.0) > 0) && (mpfr_cmp_d(*x, 0.0) <= 0)) return newSVuv(1);
         }
       }
       return newSVuv(mpfr_fits_uintmax_p(*x, (mp_rnd_t)SvUV(round)));
#endif /* MPFR_VERSION */
     }
#endif /* MSC_VER */
#endif /* MATH_MPFR_NEED_LONG_LONG_INT */

     mpfr_init2(high, bits + 1);
     mpfr_init2(copy, bits);

     mpfr_set_ui(high, 1, GMP_RNDN);
     mpfr_mul_2exp(high, high, bits, GMP_RNDN);
     mpfr_sub_ui(high, high, 1, GMP_RNDN);

     mpfr_set(copy, *x, (mp_rnd_t)SvUV(round));

     if(mpfr_lessequal_p(copy, high) && mpfr_cmp_ui(copy, 0) >= 0) ret = 1;

     mpfr_clear(high);
     mpfr_clear(copy);

     return newSVuv(ret);
}

SV * Rmpfr_strtofr(pTHX_ mpfr_t * a, SV * str, SV * base, SV * round) {
     int b = (int)SvIV(base);
     /* char ** endptr; */
#if MPFR_VERSION_MAJOR < 3
     if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
     if(b < 0 || b > MAXIMUM_ALLOWABLE_BASE || b == 1)
        croak("3rd argument supplied to Rmpfr_strtofr is out of allowable range");
#else
     if(b < 0 || b > 62 || b == 1) croak("3rd argument supplied to Rmpfr_strtofr is out of allowable range");
#endif
     return newSViv(mpfr_strtofr(*a, SvPV_nolen(str), NULL, b, (mp_rnd_t)SvUV(round)));
}

void Rmpfr_set_erangeflag(void) {
     mpfr_set_erangeflag();
}

void Rmpfr_set_underflow(void) {
     mpfr_set_underflow();
}

void Rmpfr_set_overflow(void) {
     mpfr_set_overflow();
}

void Rmpfr_set_nanflag(void) {
     mpfr_set_nanflag();
}

void Rmpfr_set_inexflag(void) {
     mpfr_set_inexflag();
}

SV * Rmpfr_erfc(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_erfc(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_j0(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_j0(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_j1(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_j1(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_jn(pTHX_ mpfr_t * a, SV * n, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_jn(*a, (long)SvIV(n), *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_y0(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_y0(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_y1(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_y1(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_yn(pTHX_ mpfr_t * a, SV * n, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_yn(*a, (long)SvIV(n), *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_atan2(pTHX_ mpfr_t * a, mpfr_t * b, mpfr_t * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_atan2(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_pow_z(pTHX_ mpfr_t * a, mpfr_t * b, mpz_t * c,  SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_pow_z(*a, *b, *c, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_subnormalize(pTHX_ mpfr_t * a, SV * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_subnormalize(*a, (int)SvIV(b), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_const_catalan(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_const_catalan(*a, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sec(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sec(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_csc(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_csc(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_cot(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_cot(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_root(pTHX_ mpfr_t * a, mpfr_t * b, SV * c, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_root(*a, *b, (unsigned long)SvUV(c), (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_eint(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_eint(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_li2(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_li2(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_get_f(pTHX_ mpf_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_get_f(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_sech(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_sech(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_csch(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_csch(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_coth(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     return newSViv(mpfr_coth(*a, *b, (mp_rnd_t)SvUV(round)));
}

SV * Rmpfr_lngamma(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
#if !defined(MPFR_VERSION) || (defined(MPFR_VERSION) && MPFR_VERSION <= LNGAMMA_BUG)
     if(!mpfr_nan_p(*b) && mpfr_sgn(*b) <= 0) {
       mpfr_set_inf(*a, 1);
       return newSViv(0);
     }
#endif
     return newSViv(mpfr_lngamma(*a, *b, (mp_rnd_t)SvUV(round)));
}

void Rmpfr_lgamma(pTHX_ mpfr_t * a, mpfr_t * b, SV * round) {
     dXSARGS;
     int ret, signp;
#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif
     ret = mpfr_lgamma(*a, &signp, *b, (mp_rnd_t)SvUV(round));
     ST(0) = sv_2mortal(newSViv(signp));
     ST(1) = sv_2mortal(newSViv(ret));
     XSRETURN(2);
}

SV * _MPFR_VERSION(pTHX) {
#if defined(MPFR_VERSION)
     return newSVuv(MPFR_VERSION);
#else
     return &PL_sv_undef;
#endif
}

SV * _MPFR_VERSION_MAJOR(pTHX) {
     return newSVuv(MPFR_VERSION_MAJOR);
}

SV * _MPFR_VERSION_MINOR(pTHX) {
     return newSVuv(MPFR_VERSION_MINOR);
}

SV * _MPFR_VERSION_PATCHLEVEL(pTHX) {
     return newSVuv(MPFR_VERSION_PATCHLEVEL);
}

SV * _MPFR_VERSION_STRING(pTHX) {
     return newSVpv(MPFR_VERSION_STRING, 0);
}

SV * RMPFR_VERSION_NUM(pTHX_ SV * a, SV * b, SV * c) {
     return newSVuv(MPFR_VERSION_NUM((unsigned long)SvUV(a), (unsigned long)SvUV(b), (unsigned long)SvUV(c)));
}

SV * Rmpfr_sum(pTHX_ mpfr_t * rop, SV * avref, SV * len, SV * round) {
     mpfr_ptr *p;
     SV ** elem;
     int ret, i;
     unsigned long s = (unsigned long)SvUV(len);

#if MPFR_VERSION_MAJOR < 3
    if((mp_rnd_t)SvUV(round) > 3) croak("Illegal rounding value supplied for this version (%s) of the mpfr library", MPFR_VERSION_STRING);
#endif

     Newx(p, s, mpfr_ptr);
     if(p == NULL) croak("Unable to allocate memory in Rmpfr_sum");

     for(i = 0; i < s; ++i) {
        elem = av_fetch((AV*)SvRV(avref), i, 0);
        p[i] = (INT2PTR(mpfr_t *, SvIV(SvRV(*elem))))[0];
     }

     ret = mpfr_sum(*rop, p, s, (mp_rnd_t)SvUV(round));

     Safefree(p);
     return newSVuv(ret);
}

SV * overload_mul(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t * mpfr_t_obj, t;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_mul function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_mul");
       mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif
#else
     if(SvUOK(b)) {
       mpfr_mul_ui(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_mul_si(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {

#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);
       mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

#else
       mpfr_mul_d(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), (double)SvNV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

#endif

     if(SvPOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_mul");
       mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPz")) {

         mpfr_mul_z(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                 *(INT2PTR(mpz_t * , SvIV(SvRV(b)))),
                                 __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPq")) {

         mpfr_mul_q(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                 *(INT2PTR(mpq_t * , SvIV(SvRV(b)))),
                                 __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         mpfr_mul(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return obj_ref;
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_mul");
}

SV * overload_add(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t * mpfr_t_obj, t;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_add function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_add");
       mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif
#else
     if(SvUOK(b)) {
       mpfr_add_ui(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_add_si(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {
#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);
       mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

#else
       mpfr_add_d(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), (double)SvNV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

#endif

     if(SvPOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_add");
       mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                               *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))),
                               __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_add_z(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                 *(INT2PTR(mpz_t * , SvIV(SvRV(b)))),
                                 __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_add_q(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                 *(INT2PTR(mpq_t * , SvIV(SvRV(b)))),
                                 __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         mpfr_add(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return obj_ref;
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_add");
}

SV * overload_sub(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t * mpfr_t_obj, t;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_sub function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_sub(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_sub(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_sub");
       if(third == &PL_sv_yes) mpfr_sub(*mpfr_t_obj, *mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif
#else
     if(SvUOK(b)) {
       if(third == &PL_sv_yes) mpfr_ui_sub(*mpfr_t_obj, SvUV(b), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub_ui(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(SvIOK(b)) {
       if(third == &PL_sv_yes) mpfr_si_sub(*mpfr_t_obj, SvIV(b), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub_si(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {
#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_sub(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }
#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_sub(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

#else

       if(third == &PL_sv_yes) mpfr_d_sub(*mpfr_t_obj, SvNV(b), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub_d(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvNV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

#endif


     if(SvPOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_sub");
       if(third == &PL_sv_yes) mpfr_sub(*mpfr_t_obj, *mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_sub_z(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                      *(INT2PTR(mpz_t * , SvIV(SvRV(b)))),
                                      __gmpfr_default_rounding_mode);
         if(third == &PL_sv_yes) mpfr_neg(*mpfr_t_obj, *mpfr_t_obj, MPFR_RNDN);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_sub_q(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                      *(INT2PTR(mpq_t * , SvIV(SvRV(b)))),
                                      __gmpfr_default_rounding_mode);
         if(third == &PL_sv_yes) mpfr_neg(*mpfr_t_obj, *mpfr_t_obj, MPFR_RNDN);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         if(third == &PL_sv_yes) mpfr_sub(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
         else mpfr_sub(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return obj_ref;
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_sub function");
}

SV * overload_div(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t * mpfr_t_obj, t;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_div function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_div(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_div(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_div");
       if(third == &PL_sv_yes) mpfr_div(*mpfr_t_obj, *mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif
#else
     if(SvUOK(b)) {
       if(third == &PL_sv_yes) mpfr_ui_div(*mpfr_t_obj, SvUV(b), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div_ui(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(SvIOK(b)) {
       if(third == &PL_sv_yes) mpfr_si_div(*mpfr_t_obj, SvIV(b), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div_si(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {
#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_div(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       return obj_ref;
       mpfr_clear(t);
     }

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_div(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

#else

       if(third == &PL_sv_yes) mpfr_d_div(*mpfr_t_obj, SvNV(b), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div_d(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvNV(b), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

#endif

     if(SvPOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_div");
       if(third == &PL_sv_yes) mpfr_div(*mpfr_t_obj, *mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       else mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_div_z(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                      *(INT2PTR(mpz_t * , SvIV(SvRV(b)))),
                                      __gmpfr_default_rounding_mode);
         /* *mpfr_t_obj gets rounded a second time if third == &PL_sv_yes */
         if(third == &PL_sv_yes) mpfr_ui_div(*mpfr_t_obj, 1, *mpfr_t_obj, __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_div_q(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))),
                                      *(INT2PTR(mpq_t * , SvIV(SvRV(b)))),
                                      __gmpfr_default_rounding_mode);
         /* *mpfr_t_obj gets rounded a second time if third == &PL_sv_yes */
         if(third == &PL_sv_yes) mpfr_ui_div(*mpfr_t_obj, 1, *mpfr_t_obj, __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         if(third == &PL_sv_yes) mpfr_div(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
         else mpfr_div(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return obj_ref;
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_div function");
}

SV * overload_copy(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_copy function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");

     mpfr_init2(*mpfr_t_obj, mpfr_get_prec(*p));
     mpfr_set(*mpfr_t_obj, *p, __gmpfr_default_rounding_mode);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_abs(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_abs function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     mpfr_abs(*mpfr_t_obj, *p, __gmpfr_default_rounding_mode);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_gt(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfr_nan_p(*a)){
       mpfr_set_erangeflag();
       return newSVuv(0);
     }

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_gt");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#endif
#else
     if(SvUOK(b)) {
       ret = mpfr_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfr_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#endif

     if(SvNOK(b)) {

       if(SvNV(b) != SvNV(b)) { /* it's a NaN */
         mpfr_set_erangeflag();
         return newSVuv(0);
       }

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
#elif defined(USE_LONG_DOUBLE)
       ret = mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
       ret = mpfr_cmp_d(*a, (double)SvNV(b));
#endif
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_gt");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
          return newSVuv(mpfr_greater_p(*a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b))))));
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_gt");
}

SV * overload_gte(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfr_nan_p(*a)){
       mpfr_set_erangeflag();
       return newSVuv(0);
     }

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_gte");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#endif
#else
     if(SvUOK(b)) {
       ret = mpfr_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfr_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }
#endif

     if(SvNOK(b)) {

       if(SvNV(b) != SvNV(b)) { /* it's a NaN */
         mpfr_set_erangeflag();
         return newSVuv(0);
       }

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
#elif defined(USE_LONG_DOUBLE)
       ret = mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
       ret = mpfr_cmp_d(*a, (double)SvNV(b));
#endif

       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_gte");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret >= 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         return newSVuv(mpfr_greaterequal_p(*a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b))))));
         }
       }

     croak("Invalid argument supplied to Math::MPFR::overload_gte");
}

SV * overload_lt(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfr_nan_p(*a)){
       mpfr_set_erangeflag();
       return newSVuv(0);
     }

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_lt");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }
#endif
#else
     if(SvUOK(b)) {
       ret = mpfr_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpfr_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {

       if(SvNV(b) != SvNV(b)) { /* it's a NaN */
         mpfr_set_erangeflag();
         return newSVuv(0);
       }

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
#elif defined(USE_LONG_DOUBLE)
       ret = mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
       ret = mpfr_cmp_d(*a, (double)SvNV(b));
#endif

       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_lt");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         return newSVuv(mpfr_less_p(*a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b))))));
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_lt");
}

SV * overload_lte(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfr_nan_p(*a)){
       mpfr_set_erangeflag();
       return newSVuv(0);
     }

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_lte");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#endif
#else
     if(SvUOK(b)) {
       ret = mpfr_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfr_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
       }
#endif

     if(SvNOK(b)) {

       if(SvNV(b) != SvNV(b)) { /* it's a NaN */
         mpfr_set_erangeflag();
         return newSVuv(0);
       }

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
#elif defined(USE_LONG_DOUBLE)
       ret = mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
       ret = mpfr_cmp_d(*a, (double)SvNV(b));
#endif

       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_lte");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret <= 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR"))
         return newSVuv(mpfr_lessequal_p(*a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b))))));
     }

     croak("Invalid argument supplied to Math::MPFR::overload_lte");
}

SV * overload_spaceship(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfr_nan_p(*a)) {
       mpfr_set_erangeflag();
       return &PL_sv_undef;
     }

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(-1);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(-1);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_spaceship");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(-1);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#endif
#else
     if(SvUOK(b)) {
       ret = mpfr_cmp_ui(*a, SvUV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(-1);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }

     if(SvIOK(b)) {
       ret = mpfr_cmp_si(*a, SvIV(b));
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(-1);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
       }
#endif

     if(SvNOK(b)) {

       if(SvNV(b) != SvNV(b)) { /* it's a NaN */
       mpfr_set_erangeflag();
       return &PL_sv_undef;
     }

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
#elif defined(USE_LONG_DOUBLE)
       ret = mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
       ret = mpfr_cmp_d(*a, (double)SvNV(b));
#endif

       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(-1);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_spaceship");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(third == &PL_sv_yes) ret *= -1;
       if(ret < 0) return newSViv(-1);
       if(ret > 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         return newSViv(mpfr_cmp(*a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b))))));
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_spaceship");
}

SV * overload_equiv(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfr_nan_p(*a)){
       mpfr_set_erangeflag();
       return newSVuv(0);
     }

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_equiv");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }
#endif
#else
     if(SvUOK(b)) {
       ret = mpfr_cmp_ui(*a, SvUV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpfr_cmp_si(*a, SvIV(b));
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }
#endif

     if(SvNOK(b)) {

       if(SvNV(b) != SvNV(b)) { /* it's a NaN */
         mpfr_set_erangeflag();
         return newSVuv(0);
       }

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
#elif defined(USE_LONG_DOUBLE)
       ret = mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
       ret = mpfr_cmp_d(*a, (double)SvNV(b));
#endif

       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_equiv");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret == 0) return newSViv(1);
       return newSViv(0);
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         return newSVuv(mpfr_equal_p(*a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b))))));
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_equiv");
}

SV * overload_not_equiv(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t t;
     int ret;

     if(mpfr_nan_p(*a)){
       mpfr_set_erangeflag();
       return newSVuv(1);
     }

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret != 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret != 0) return newSViv(1);
       return newSViv(0);
     }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_not_equiv");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret != 0) return newSViv(1);
       return newSViv(0);
     }
#endif
#else
     if(SvUOK(b)) {
       ret = mpfr_cmp_ui(*a, SvUV(b));
       if(ret != 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvIOK(b)) {
       ret = mpfr_cmp_si(*a, SvIV(b));
       if(ret != 0) return newSViv(1);
       return newSViv(0);
   }
#endif

     if(SvNOK(b)) {

       if(SvNV(b) != SvNV(b)) { /* it's a NaN */
         mpfr_set_erangeflag();
         return newSVuv(1);
       }

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
#elif defined(USE_LONG_DOUBLE)
       ret = mpfr_cmp_ld(*a, (long double)SvNV(b));
#else
       ret = mpfr_cmp_d(*a, (double)SvNV(b));
#endif

       if(ret != 0) return newSViv(1);
       return newSViv(0);
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, (char *)SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_not_equiv");
       ret = mpfr_cmp(*a, t);
       mpfr_clear(t);
       if(ret != 0) return newSViv(1);
       return newSViv(0);
       }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         if(mpfr_equal_p(*a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))))) return newSViv(0);
         return newSViv(1);
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_not_equiv");
}

SV * overload_true(pTHX_ mpfr_t *a, SV *second, SV * third) {
     if(mpfr_nan_p(*a)) return newSVuv(0);
     if(mpfr_cmp_ui(*a, 0)) return newSVuv(1);
     return newSVuv(0);
}

SV * overload_not(pTHX_ mpfr_t * a, SV * second, SV * third) {
     if(mpfr_nan_p(*a)) return newSViv(1);
     if(mpfr_cmp_ui(*a, 0)) return newSViv(0);
     return newSViv(1);
}

SV * overload_sqrt(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_sqrt function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     /* No - this was wrong. If a negative value is supplied, a NaN should be returned instad */
     /* if(mpfr_cmp_ui(*p, 0) < 0) croak("Negative value supplied as argument to overload_sqrt"); */

     mpfr_sqrt(*mpfr_t_obj, *p, __gmpfr_default_rounding_mode);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_pow(pTHX_ SV * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj, t;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_pow function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(second)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(second), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_pow(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
       else mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

     if(SvIOK(second)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(second), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes) mpfr_pow(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
       else mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }
#else
     if(SvIOK(second)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(second), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_pow");
       if(third == &PL_sv_yes) mpfr_pow(*mpfr_t_obj, *mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
       else mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }
#endif
#else
     if(SvUOK(second)) {
       if(third == &PL_sv_yes) mpfr_ui_pow(*mpfr_t_obj, SvUV(second), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
       else mpfr_pow_ui(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), SvUV(second), __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(SvIOK(second)) {
       /* Need to do it this way as there's no mpfr_si_pow function */
       if(SvIV(second) >= 0) {
         if(third == &PL_sv_yes) mpfr_ui_pow(*mpfr_t_obj, SvUV(second), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
         else mpfr_pow_ui(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), SvUV(second), __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(third != &PL_sv_yes) {
         mpfr_pow_si(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), SvIV(second), __gmpfr_default_rounding_mode);
         return obj_ref;
       }
     }
#endif

     if(SvNOK(second)) {

#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(second), __gmpfr_default_rounding_mode);

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(second), __gmpfr_default_rounding_mode);

#else

       mpfr_init2(t, DBL_MANT_DIG);
       mpfr_set_d(t, (double)SvNV(second), __gmpfr_default_rounding_mode);

#endif

       if(third == &PL_sv_yes) mpfr_pow(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
       else mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return obj_ref;
     }

     if(SvPOK(second)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(second), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_pow");
       if(third == &PL_sv_yes) mpfr_pow(*mpfr_t_obj, *mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
       else mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
       return obj_ref;
     }

     if(sv_isobject(second)) {
       const char* h = HvNAME(SvSTASH(SvRV(second)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPz")) {
         if(third == &PL_sv_yes) {
           mpfr_init2(t, (mpfr_prec_t)mpz_sizeinbase(*(INT2PTR(mpz_t *, SvIV(SvRV(second)))), 2));
           mpfr_set_z(t, *(INT2PTR(mpz_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
           mpfr_pow(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
           mpfr_clear(t);
         }
         else mpfr_pow_z(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p     )))),
                                      *(INT2PTR(mpz_t * , SvIV(SvRV(second)))),
                                      __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_set_q(*mpfr_t_obj, *(INT2PTR(mpq_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
         if(third == &PL_sv_yes) mpfr_pow(*mpfr_t_obj, *mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
         else mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *mpfr_t_obj, __gmpfr_default_rounding_mode);
         return obj_ref;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(second))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
         if(third == &PL_sv_yes) mpfr_pow(*mpfr_t_obj, t, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), __gmpfr_default_rounding_mode);
         else mpfr_pow(*mpfr_t_obj, *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return obj_ref;
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_pow.");
}

SV * overload_log(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_log function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     mpfr_log(*mpfr_t_obj, *p, __gmpfr_default_rounding_mode);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_exp(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_exp function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     mpfr_exp(*mpfr_t_obj, *p, __gmpfr_default_rounding_mode);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_sin(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_sin function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     mpfr_sin(*mpfr_t_obj, *p, __gmpfr_default_rounding_mode);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_cos(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_cos function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     mpfr_cos(*mpfr_t_obj, *p, __gmpfr_default_rounding_mode);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_int(pTHX_ mpfr_t * p, SV * second, SV * third) {
     mpfr_t * mpfr_t_obj;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_int function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

     mpfr_trunc(*mpfr_t_obj, *p);
     sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * overload_atan2(pTHX_ mpfr_t * a, SV * b, SV * third) {
     mpfr_t * mpfr_t_obj, t;
     SV * obj_ref, * obj;

     Newx(mpfr_t_obj, 1, mpfr_t);
     if(mpfr_t_obj == NULL) croak("Failed to allocate memory in overload_atan2 function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::MPFR");
     mpfr_init(*mpfr_t_obj);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes){
         mpfr_atan2(*mpfr_t_obj, t, *a, __gmpfr_default_rounding_mode);
       }
       else {
         mpfr_atan2(*mpfr_t_obj, *a, t, __gmpfr_default_rounding_mode);
       }
       sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
       mpfr_clear(t);
       SvREADONLY_on(obj);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes){
         mpfr_atan2(*mpfr_t_obj, t, *a, __gmpfr_default_rounding_mode);
       }
       else {
         mpfr_atan2(*mpfr_t_obj, *a, t, __gmpfr_default_rounding_mode);
       }
       mpfr_clear(t);
       sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_atan2");
       if(third == &PL_sv_yes){
         mpfr_atan2(*mpfr_t_obj, *mpfr_t_obj, *a, __gmpfr_default_rounding_mode);
       }
       else {
         mpfr_atan2(*mpfr_t_obj, *a, *mpfr_t_obj, __gmpfr_default_rounding_mode);
       }
       sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
     }
#endif
#else
     if(SvUOK(b)) {
       mpfr_init2(t, 8 * sizeof(long));
       mpfr_set_ui(t, SvUV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes){
         mpfr_atan2(*mpfr_t_obj, t, *a, __gmpfr_default_rounding_mode);
       }
       else {
         mpfr_atan2(*mpfr_t_obj, *a, t, __gmpfr_default_rounding_mode);
       }
       mpfr_clear(t);
       sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, 8 * sizeof(long));
       mpfr_set_si(t, SvIV(b), __gmpfr_default_rounding_mode);
       if(third == &PL_sv_yes){
         mpfr_atan2(*mpfr_t_obj, t, *a, __gmpfr_default_rounding_mode);
       }
       else {
         mpfr_atan2(*mpfr_t_obj, *a, t, __gmpfr_default_rounding_mode);
       }
       mpfr_clear(t);
       sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
     }
#endif

     if(SvNOK(b)) {

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);
#elif defined(USE_LONG_DOUBLE)
       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);
#else
       mpfr_init2(t, DBL_MANT_DIG);
       mpfr_set_d(t, (double)SvNV(b), __gmpfr_default_rounding_mode);
#endif

       if(third == &PL_sv_yes){
         mpfr_atan2(*mpfr_t_obj, t, *a, __gmpfr_default_rounding_mode);
       }
       else {
         mpfr_atan2(*mpfr_t_obj, *a, t, __gmpfr_default_rounding_mode);
       }
       mpfr_clear(t);
       sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
     }

     if(SvPOK(b)) {
       if(mpfr_set_str(*mpfr_t_obj, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode))
         croak("Invalid string supplied to Math::MPFR::overload_atan2");
       if(third == &PL_sv_yes){
         mpfr_atan2(*mpfr_t_obj, *mpfr_t_obj, *a, __gmpfr_default_rounding_mode);
         }
       else {
         mpfr_atan2(*mpfr_t_obj, *a, *mpfr_t_obj, __gmpfr_default_rounding_mode);
         }
       sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
       SvREADONLY_on(obj);
       return obj_ref;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_atan2(*mpfr_t_obj, *a, *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         sv_setiv(obj, INT2PTR(IV,mpfr_t_obj));
         SvREADONLY_on(obj);
         return obj_ref;
       }
     }

     croak("Invalid argument supplied to Math::MPFR::overload_atan2 function");
}

/* Finish typemapping */

SV * Rgmp_randinit_default_nobless(pTHX) {
     gmp_randstate_t * state;
     SV * obj_ref, * obj;

     Newx(state, 1, gmp_randstate_t);
     if(state == NULL) croak("Failed to allocate memory in Rgmp_randinit_default function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     gmp_randinit_default(*state);

     sv_setiv(obj, INT2PTR(IV,state));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rgmp_randinit_mt_nobless(pTHX) {
     gmp_randstate_t * rand_obj;
     SV * obj_ref, * obj;

     Newx(rand_obj, 1, gmp_randstate_t);
     if(rand_obj == NULL) croak("Failed to allocate memory in Math::GMPz::Random::Rgmp_randinit_mt function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     gmp_randinit_mt(*rand_obj);

     sv_setiv(obj, INT2PTR(IV, rand_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rgmp_randinit_lc_2exp_nobless(pTHX_ SV * a, SV * c, SV * m2exp ) {
     gmp_randstate_t * state;
     mpz_t aa;
     SV * obj_ref, * obj;

     Newx(state, 1, gmp_randstate_t);
     if(state == NULL) croak("Failed to allocate memory in Rgmp_randinit_lc_2exp function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     if(sv_isobject(a)) {
       const char* h = HvNAME(SvSTASH(SvRV(a)));

       if(strEQ(h, "Math::GMP") ||
          strEQ(h, "GMP::Mpz")  ||
          strEQ(h, "Math::GMPz"))
            gmp_randinit_lc_2exp(*state, *(INT2PTR(mpz_t *, SvIV(SvRV(a)))), (unsigned long)SvUV(c), (unsigned long)SvUV(m2exp));
       else croak("First arg to Rgmp_randinit_lc_2exp is of invalid type");
     }

     else {
       if(!mpz_init_set_str(aa, SvPV_nolen(a), 0)) {
         gmp_randinit_lc_2exp(*state, aa, (unsigned long)SvUV(c), (unsigned long)SvUV(m2exp));
         mpz_clear(aa);
       }
       else croak("Seedstring supplied to Rgmp_randinit_lc_2exp is not a valid number");
     }

     sv_setiv(obj, INT2PTR(IV,state));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rgmp_randinit_lc_2exp_size_nobless(pTHX_ SV * size) {
     gmp_randstate_t * state;
     SV * obj_ref, * obj;

     if(SvUV(size) > 128) croak("The argument supplied to Rgmp_randinit_lc_2exp_size function (%u) needs to be in the range [1..128]", SvUV(size));

     Newx(state, 1, gmp_randstate_t);
     if(state == NULL) croak("Failed to allocate memory in Rgmp_randinit_lc_2exp_size function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);

     if(gmp_randinit_lc_2exp_size(*state, (unsigned long)SvUV(size))) {
       sv_setiv(obj, INT2PTR(IV,state));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     croak("Rgmp_randinit_lc_2exp_size function failed");
}

void Rgmp_randclear(pTHX_ SV * p) {
     gmp_randclear(*(INT2PTR(gmp_randstate_t *, SvIV(SvRV(p)))));
     Safefree(INT2PTR(gmp_randstate_t *, SvIV(SvRV(p))));
}

void Rgmp_randseed(pTHX_ SV * state, SV * seed) {
     mpz_t s;

     if(sv_isobject(seed)) {
       const char* h = HvNAME(SvSTASH(SvRV(seed)));

       if(strEQ(h, "Math::GMP") ||
          strEQ(h, "GMP::Mpz") ||
          strEQ(h, "Math::GMPz"))
            gmp_randseed(*(INT2PTR(gmp_randstate_t *, SvIV(SvRV(state)))), *(INT2PTR(mpz_t *, SvIV(SvRV(seed)))));
       else croak("2nd arg to Rgmp_randseed is of invalid type");
     }

     else {
       if(!mpz_init_set_str(s, SvPV_nolen(seed), 0)) {
         gmp_randseed(*(INT2PTR(gmp_randstate_t *, SvIV(SvRV(state)))), s);
         mpz_clear(s);
       }
       else croak("Seedstring supplied to Rgmp_randseed is not a valid number");
     }
}

void Rgmp_randseed_ui(pTHX_ SV * state, SV * seed) {
     gmp_randseed_ui(*(INT2PTR(gmp_randstate_t *, SvIV(SvRV(state)))), (unsigned long)SvUV(seed));
}

SV * overload_pow_eq(pTHX_ SV * p, SV * second, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(p);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(second)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(second), __gmpfr_default_rounding_mode);
       mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return p;
     }

     if(SvIOK(second)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(second), __gmpfr_default_rounding_mode);
       mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return p;
     }
#else
     if(SvIOK(second)) {
       if(mpfr_init_set_str(t, SvPV_nolen(second), 10, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(p);
         croak("Invalid string supplied to Math::MPFR::overload_pow_eq");
       }
       mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return p;
     }
#endif
#else
     if(SvUOK(second)) {
       mpfr_pow_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), SvUV(second), __gmpfr_default_rounding_mode);
       return p;
     }

     if(SvIOK(second)) {
       /*
       if(SvIV(second) >= 0) {
         mpfr_pow_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), SvUV(second), __gmpfr_default_rounding_mode);
         return p;
       }
       */
       mpfr_pow_si(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), SvIV(second), __gmpfr_default_rounding_mode);
       return p;
     }
#endif

     if(SvNOK(second)) {

#if defined(CAN_PASS_FLOAT128)
       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(second), __gmpfr_default_rounding_mode);
#elif defined(USE_LONG_DOUBLE)
       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(second), __gmpfr_default_rounding_mode);
#else
       mpfr_init2(t, DBL_MANT_DIG);
       mpfr_set_d(t, (double)SvNV(second), __gmpfr_default_rounding_mode);
#endif

       mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return p;
     }

     if(SvPOK(second)) {
       if(mpfr_init_set_str(t, SvPV_nolen(second), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(p);
         croak("Invalid string supplied to Math::MPFR::overload_pow_eq");
       }
       mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return p;
     }

     if(sv_isobject(second)) {
       const char* h = HvNAME(SvSTASH(SvRV(second)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
         return p;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_pow_z(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpz_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
         return p;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(second))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
         mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return p;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_init(t);
         mpfr_set_q(t, *(INT2PTR(mpq_t *, SvIV(SvRV(second)))), __gmpfr_default_rounding_mode);
         mpfr_pow(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return p;
       }
     }

     SvREFCNT_dec(p);
     croak("Invalid argument supplied to Math::MPFR::overload_pow_eq.");
}

SV * overload_div_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfr_div(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       mpfr_div(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_div_eq");
         }
       mpfr_div(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#endif
#else
     if(SvUOK(b)) {
       mpfr_div_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_div_si(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return a;
       /*
       if(SvIV(b) >= 0) {
         mpfr_div_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
         return a;
       }
       mpfr_div_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b) * -1, __gmpfr_default_rounding_mode);
       mpfr_neg(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       return a;
       */
     }
#endif

     if(SvNOK(b)) {

#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);

#else

       mpfr_init2(t, DBL_MANT_DIG);
       mpfr_set_d(t, (double)SvNV(b), __gmpfr_default_rounding_mode);
#endif

       mpfr_div(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_div_eq");
         }
       mpfr_div(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_div(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_div_z(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         mpfr_div(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return a;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_div_q(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
     }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::MPFR::overload_div_eq function");
}

SV * overload_sub_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfr_sub(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       mpfr_sub(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_sub_eq");
         }
       mpfr_sub(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#endif
#else
     if(SvUOK(b)) {
       mpfr_sub_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_sub_si(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return a;
       /*
       if(SvIV(b) >= 0) {
         mpfr_sub_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
         return a;
       }
       mpfr_add_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b) * -1, __gmpfr_default_rounding_mode);
       return a;
       */
     }
#endif

     if(SvNOK(b)) {

#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);

#else

       mpfr_init2(t, DBL_MANT_DIG);
       mpfr_init_set_d(t, (double)SvNV(b), __gmpfr_default_rounding_mode);

#endif

       mpfr_sub(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_sub_eq");
       }
       mpfr_sub(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_sub(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_sub_z(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         mpfr_sub(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return a;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_sub_q(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
     }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::MPFR::overload_sub_eq function");
}

SV * overload_add_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfr_add(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       mpfr_add(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_add_eq");
       }
       mpfr_add(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#endif
#else
     if(SvUOK(b)) {
       mpfr_add_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_add_si(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return a;
       /*
       if(SvIV(b) >= 0) {
         mpfr_add_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
         return a;
       }
       mpfr_sub_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b) * -1, __gmpfr_default_rounding_mode);
       return a;
       */
     }
#endif

     if(SvNOK(b)) {

#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);

#else

       mpfr_init2(t, DBL_MANT_DIG);
       mpfr_set_d(t, (double)SvNV(b), __gmpfr_default_rounding_mode);

#endif

       mpfr_add(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_add_eq");
       }
       mpfr_add(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_add(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_add_z(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         mpfr_add(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return a;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_add_q(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
     }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::MPFR::overload_add_eq");
}

SV * overload_mul_eq(pTHX_ SV * a, SV * b, SV * third) {
     mpfr_t t;

     SvREFCNT_inc(a);

#ifdef MATH_MPFR_NEED_LONG_LONG_INT
#ifndef _MSC_VER
     if(SvUOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_uj(t, SvUV(b), __gmpfr_default_rounding_mode);
       mpfr_mul(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_init2(t, (mpfr_prec_t)IVSIZE_BITS);
       mpfr_set_sj(t, SvIV(b), __gmpfr_default_rounding_mode);
       mpfr_mul(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#else
     if(SvIOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 10, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_mul_eq");
       }
       mpfr_mul(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }
#endif
#else
     if(SvUOK(b)) {
       mpfr_mul_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
       return a;
     }

     if(SvIOK(b)) {
       mpfr_mul_si(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b), __gmpfr_default_rounding_mode);
       return a;
       /*
       if(SvIV(b) >= 0) {
         mpfr_mul_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvUV(b), __gmpfr_default_rounding_mode);
         return a;
       }
       mpfr_mul_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), SvIV(b) * -1, __gmpfr_default_rounding_mode);
       mpfr_neg(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), __gmpfr_default_rounding_mode);
       return a;
       */
     }
#endif

     if(SvNOK(b)) {

#if defined(CAN_PASS_FLOAT128)

       mpfr_init2(t, FLT128_MANT_DIG);
       mpfr_set_float128(t, (float128)SvNV(b), __gmpfr_default_rounding_mode);

#elif defined(USE_LONG_DOUBLE)

       mpfr_init2(t, LDBL_MANT_DIG);
       mpfr_set_ld(t, (long double)SvNV(b), __gmpfr_default_rounding_mode);

#else

       mpfr_init2(t, DBL_MANT_DIG);
       mpfr_init_set_d(t, (double)SvNV(b), __gmpfr_default_rounding_mode);

#endif

       mpfr_mul(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(SvPOK(b)) {
       if(mpfr_init_set_str(t, SvPV_nolen(b), 0, __gmpfr_default_rounding_mode)) {
         SvREFCNT_dec(a);
         croak("Invalid string supplied to Math::MPFR::overload_mul_eq");
       }
       mpfr_mul(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
       mpfr_clear(t);
       return a;
     }

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         mpfr_mul(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPz")) {
         mpfr_mul_z(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpz_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
       if(strEQ(h, "Math::GMPf")) {
         mpfr_init2(t, (mpfr_prec_t)mpf_get_prec(*(INT2PTR(mpf_t *, SvIV(SvRV(b))))));
         mpfr_set_f(t, *(INT2PTR(mpf_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         mpfr_mul(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), t, __gmpfr_default_rounding_mode);
         mpfr_clear(t);
         return a;
       }
       if(strEQ(h, "Math::GMPq")) {
         mpfr_mul_q(*(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(a)))), *(INT2PTR(mpq_t *, SvIV(SvRV(b)))), __gmpfr_default_rounding_mode);
         return a;
       }
     }

     SvREFCNT_dec(a);
     croak("Invalid argument supplied to Math::MPFR::overload_mul_eq");
}

SV * _itsa(pTHX_ SV * a) {
     if(SvUOK(a)) return newSVuv(1);
     if(SvIOK(a)) return newSVuv(2);
     if(SvNOK(a)) return newSVuv(3);
     if(SvPOK(a)) return newSVuv(4);
     if(sv_isobject(a)) {
       const char* h = HvNAME(SvSTASH(SvRV(a)));

       if(strEQ(h, "Math::MPFR")) return newSVuv(5);
       if(strEQ(h, "Math::GMPf")) return newSVuv(6);
       if(strEQ(h, "Math::GMPq")) return newSVuv(7);
       if(strEQ(h, "Math::GMPz")) return newSVuv(8);
       if(strEQ(h, "Math::GMP")) return newSVuv(9);        }
     return newSVuv(0);
}

int _has_longlong(void) {
#ifdef MATH_MPFR_NEED_LONG_LONG_INT
    return 1;
#else
    return 0;
#endif
}

int _has_longdouble(void) {
#ifdef USE_LONG_DOUBLE
    return 1;
#else
    return 0;
#endif
}

int _ivsize_bits(void) {
   int ret = 0;
#ifdef IVSIZE_BITS
   ret = IVSIZE_BITS;
#endif
   return ret;
}

/*
int _mpfr_longsize(void) {
    mpfr_t x, y;

    mpfr_init2(x, 100);
    mpfr_init2(y, 100);

    mpfr_set_str(x, "18446744073709551615", 10, GMP_RNDN);
    mpfr_set_ui(y, 18446744073709551615, GMP_RNDN);

    if(!mpfr_cmp(x,y)) return 64;
    return 32;
}
*/

SV * RMPFR_PREC_MAX(pTHX) {
     return newSViv(MPFR_PREC_MAX);
}

SV * RMPFR_PREC_MIN(pTHX) {
     return newSViv(MPFR_PREC_MIN);
}

SV * wrap_mpfr_printf(pTHX_ SV * a, SV * b) {
     int ret;
     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")){
         ret = mpfr_printf(SvPV_nolen(a), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         fflush(stdout);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")){
         ret = mpfr_printf(SvPV_nolen(a), *(INT2PTR(mp_prec_t *, SvIV(SvRV(b)))));
         fflush(stdout);
         return newSViv(ret);
       }

       croak("Unrecognised object supplied as argument to Rmpfr_printf");
     }

     if(SvUOK(b)) {
       ret = mpfr_printf(SvPV_nolen(a), SvUV(b));
       fflush(stdout);
       return newSViv(ret);
     }
     if(SvIOK(b)) {
       ret = mpfr_printf(SvPV_nolen(a), SvIV(b));
       fflush(stdout);
       return newSViv(ret);
     }
     if(SvNOK(b)) {
       ret = mpfr_printf(SvPV_nolen(a), SvNV(b));
       fflush(stdout);
       return newSViv(ret);
     }
     if(SvPOK(b)) {
       ret = mpfr_printf(SvPV_nolen(a), SvPV_nolen(b));
       fflush(stdout);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpfr_printf");
}

SV * wrap_mpfr_fprintf(pTHX_ FILE * stream, SV * a, SV * b) {
     int ret;
     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         ret = mpfr_fprintf(stream, SvPV_nolen(a), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         fflush(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")) {
         ret = mpfr_fprintf(stream, SvPV_nolen(a), *(INT2PTR(mp_prec_t *, SvIV(SvRV(b)))));
         fflush(stream);
         return newSViv(ret);
       }

       croak("Unrecognised object supplied as argument to Rmpfr_fprintf");
     }

     if(SvUOK(b)) {
       ret = mpfr_fprintf(stream, SvPV_nolen(a), SvUV(b));
       fflush(stream);
       return newSViv(ret);
     }
     if(SvIOK(b)) {
       ret = mpfr_fprintf(stream, SvPV_nolen(a), SvIV(b));
       fflush(stream);
       return newSViv(ret);
     }
     if(SvNOK(b)) {
       ret = mpfr_fprintf(stream, SvPV_nolen(a), SvNV(b));
       fflush(stream);
       return newSViv(ret);
     }
     if(SvPOK(b)) {
       ret = mpfr_fprintf(stream, SvPV_nolen(a), SvPV_nolen(b));
       fflush(stream);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpfr_fprintf");
}

SV * wrap_mpfr_sprintf(pTHX_ SV * s, SV * a, SV * b, int buflen) {
     int ret;
     char * stream;

     Newx(stream, buflen, char);

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         ret = mpfr_sprintf(stream, SvPV_nolen(a), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")) {
         ret = mpfr_sprintf(stream, SvPV_nolen(a), *(INT2PTR(mp_prec_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       croak("Unrecognised object supplied as argument to Rmpfr_sprintf");
     }

     if(SvUOK(b)) {
       ret = mpfr_sprintf(stream, SvPV_nolen(a), SvUV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvIOK(b)) {
       ret = mpfr_sprintf(stream, SvPV_nolen(a), SvIV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvNOK(b)) {
       ret = mpfr_sprintf(stream, SvPV_nolen(a), SvNV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvPOK(b)) {
       ret = mpfr_sprintf(stream, SvPV_nolen(a), SvPV_nolen(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpfr_sprintf");
}

SV * wrap_mpfr_snprintf(pTHX_ SV * s, SV * bytes, SV * a, SV * b, int buflen) {
     int ret;
     char * stream;

     Newx(stream, buflen, char);

     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         ret = mpfr_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")) {
         ret = mpfr_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), *(INT2PTR(mp_prec_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       croak("Unrecognised object supplied as argument to Rmpfr_snprintf");
     }

     if(SvUOK(b)) {
       ret = mpfr_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvUV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvIOK(b)) {
       ret = mpfr_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvIV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvNOK(b)) {
       ret = mpfr_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvNV(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     if(SvPOK(b)) {
       ret = mpfr_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), SvPV_nolen(b));
       sv_setpv(s, stream);
       Safefree(stream);
       return newSViv(ret);
     }

     croak("Unrecognised type supplied as argument to Rmpfr_snprintf");
}

SV * wrap_mpfr_printf_rnd(pTHX_ SV * a, SV * round, SV * b) {
     int ret;
#if MPFR_VERSION_MAJOR >= 3
     if((mp_rnd_t)SvUV(round) > 4) croak("Invalid 2nd argument (rounding value) of %u passed to Rmpfr_printf", (mp_rnd_t)SvUV(round));
#else
     if((mp_rnd_t)SvUV(round) > 3) croak("Invalid 2nd argument (rounding value) of %u passed to Rmpfr_printf", (mp_rnd_t)SvUV(round));
#endif
     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")){
         ret = mpfr_printf(SvPV_nolen(a), (mp_rnd_t)SvUV(round), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         fflush(stdout);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")){
         croak("You've provided both a rounding arg and a Math::MPFR::Prec object to Rmpfr_printf");
       }

       croak("Unrecognised object supplied as argument to Rmpfr_printf");
     }

     croak("In Rmpfr_printf: The rounding argument is specific to Math::MPFR objects");
}

SV * wrap_mpfr_fprintf_rnd(pTHX_ FILE * stream, SV * a, SV * round, SV * b) {
     int ret;
#if MPFR_VERSION_MAJOR >= 3
     if((mp_rnd_t)SvUV(round) > 4) croak("Invalid 3rd argument (rounding value) of %u passed to Rmpfr_fprintf", (mp_rnd_t)SvUV(round));
#else
     if((mp_rnd_t)SvUV(round) > 3) croak("Invalid 3rd argument (rounding value) of %u passed to Rmpfr_fprintf", (mp_rnd_t)SvUV(round));
#endif
     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         ret = mpfr_fprintf(stream, SvPV_nolen(a), (mp_rnd_t)SvUV(round), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         fflush(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")) {
         croak("You've provided both a rounding arg and a Math::MPFR::Prec object to Rmpfr_fprintf");
       }

       croak("Unrecognised object supplied as argument to Rmpfr_fprintf");
     }

     croak("In Rmpfr_fprintf: The rounding argument is specific to Math::MPFR objects");
}

SV * wrap_mpfr_sprintf_rnd(pTHX_ SV * s, SV * a, SV * round, SV * b, int buflen) {
     int ret;
     char * stream;

     Newx(stream, buflen, char);

#if MPFR_VERSION_MAJOR >= 3
     if((mp_rnd_t)SvUV(round) > 4) croak("Invalid 3rd argument (rounding value) of %u passed to Rmpfr_sprintf", (mp_rnd_t)SvUV(round));
#else
     if((mp_rnd_t)SvUV(round) > 3) croak("Invalid 3rd argument (rounding value) of %u passed to Rmpfr_sprintf", (mp_rnd_t)SvUV(round));
#endif
     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         ret = mpfr_sprintf(stream, SvPV_nolen(a), (mp_rnd_t)SvUV(round), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")) {
         croak("You've provided both a rounding arg and a Math::MPFR::Prec object to Rmpfr_sprintf");
       }

       croak("Unrecognised object supplied as argument to Rmpfr_sprintf");
     }

     croak("In Rmpfr_sprintf: The rounding argument is specific to Math::MPFR objects");
}

SV * wrap_mpfr_snprintf_rnd(pTHX_ SV * s, SV * bytes, SV * a, SV * round, SV * b, int buflen) {
     int ret;
     char * stream;

     Newx(stream, buflen, char);

#if MPFR_VERSION_MAJOR >= 3
     if((mp_rnd_t)SvUV(round) > 4) croak("Invalid 3rd argument (rounding value) of %u passed to Rmpfr_snprintf", (mp_rnd_t)SvUV(round));
#else
     if((mp_rnd_t)SvUV(round) > 3) croak("Invalid 3rd argument (rounding value) of %u passed to Rmpfr_snprintf", (mp_rnd_t)SvUV(round));
#endif
     if(sv_isobject(b)) {
       const char* h = HvNAME(SvSTASH(SvRV(b)));

       if(strEQ(h, "Math::MPFR")) {
         ret = mpfr_snprintf(stream, (size_t)SvUV(bytes), SvPV_nolen(a), (mp_rnd_t)SvUV(round), *(INT2PTR(mpfr_t *, SvIV(SvRV(b)))));
         sv_setpv(s, stream);
         Safefree(stream);
         return newSViv(ret);
       }

       if(strEQ(h, "Math::MPFR::Prec")) {
         croak("You've provided both a rounding arg and a Math::MPFR::Prec object to Rmpfr_snprintf");
       }

       croak("Unrecognised object supplied as argument to Rmpfr_snprintf");
     }

     croak("In Rmpfr_snprintf: The rounding argument is specific to Math::MPFR objects");
}



SV * Rmpfr_buildopt_tls_p(pTHX) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_buildopt_tls_p());
#else
     croak("Rmpfr_buildopt_tls_p not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_buildopt_decimal_p(pTHX) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_buildopt_decimal_p());
#else
     croak("Rmpfr_buildopt_decimal_p not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_regular_p(pTHX_ mpfr_t * a) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_regular_p(*a));
#else
     croak("Rmpfr_regular_p not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

void Rmpfr_set_zero(pTHX_ mpfr_t * a, SV * sign) {
#if MPFR_VERSION_MAJOR >= 3
     mpfr_set_zero(*a, (int)SvIV(sign));
#else
     croak("Rmpfr_set_zero not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_digamma(pTHX_ mpfr_t * rop, mpfr_t * op, SV * round) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_digamma(*rop, *op, (mp_rnd_t)SvIV(round)));
#else
     croak("Rmpfr_digamma not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_ai(pTHX_ mpfr_t * rop, mpfr_t * op, SV * round) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_ai(*rop, *op, (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_ai not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_get_flt(pTHX_ mpfr_t * a, SV * round) {
#if MPFR_VERSION_MAJOR >= 3
     return newSVnv(mpfr_get_flt(*a, (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_get_flt not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_set_flt(pTHX_ mpfr_t * rop, SV * f, SV * round) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_set_flt(*rop, (float)SvNV(f), (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_set_flt not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_urandom(pTHX_ mpfr_t * rop, gmp_randstate_t* state, SV * round) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_urandom(*rop, *state, (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_urandom not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_set_z_2exp(pTHX_ mpfr_t * rop, mpz_t * op, SV * exp, SV * round) {
#if MPFR_VERSION_MAJOR >= 3
     return newSViv(mpfr_set_z_2exp(*rop, *op, (mpfr_exp_t)SvIV(exp), (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_set_z_2exp not implemented with this version of the mpfr library - we have %s but need at least 3.0.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_buildopt_tune_case(pTHX) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     return newSVpv(mpfr_buildopt_tune_case(), 0);
#else
     croak("Rmpfr_buildopt_tune_case not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_frexp(pTHX_ SV * exp, mpfr_t * rop, mpfr_t * op, SV * round) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     mpfr_exp_t _exp;
     int ret;

     ret = mpfr_frexp(&_exp, *rop, *op, (mp_rnd_t)SvUV(round));
     sv_setiv(exp, _exp);
     return newSViv(ret);
#else
     croak("Rmpfr_frexp not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_z_sub(pTHX_ mpfr_t * rop, mpz_t * op1, mpfr_t * op2, SV * round) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     return newSViv(mpfr_z_sub(*rop, *op1, *op2, (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_z_sub not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_grandom(pTHX_ mpfr_t * rop1, mpfr_t * rop2, gmp_randstate_t * state, SV * round) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     return newSViv(mpfr_grandom(*rop1, *rop2, *state, (mp_rnd_t)SvUV(round)));
#else
     croak("Rmpfr_grandom not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

void Rmpfr_clear_divby0(pTHX) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     mpfr_clear_divby0();
#else
     croak("Rmpfr_clear_divby0 not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

void Rmpfr_set_divby0(pTHX) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     mpfr_set_divby0();
#else
     croak("Rmpfr_set_divby0 not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_divby0_p(pTHX) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     return newSViv(mpfr_divby0_p());
#else
     croak("Rmpfr_divby0_p not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

SV * Rmpfr_buildopt_gmpinternals_p(pTHX) {
#if (MPFR_VERSION_MAJOR == 3 && MPFR_VERSION_MINOR >= 1) || MPFR_VERSION_MAJOR > 3
     return newSViv(mpfr_buildopt_gmpinternals_p());
#else
     croak("Rmpfr_buildopt_gmpinternals_p not implemented with this version of the mpfr library - we have %s but need at least 3.1.0", MPFR_VERSION_STRING);
#endif
}

SV * _get_xs_version(pTHX) {
     return newSVpv(XS_VERSION, 0);
}

SV * overload_inc(pTHX_ SV * p, SV * second, SV * third) {
     SvREFCNT_inc(p);
     mpfr_add_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), 1, __gmpfr_default_rounding_mode);
     return p;
}

SV * overload_dec(pTHX_ SV * p, SV * second, SV * third) {
     SvREFCNT_inc(p);
     mpfr_sub_ui(*(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), *(INT2PTR(mpfr_t *, SvIV(SvRV(p)))), 1, __gmpfr_default_rounding_mode);
     return p;
}

SV * _wrap_count(pTHX) {
     return newSVuv(PL_sv_count);
}

SV * Rmpfr_set_LD(pTHX_ mpfr_t * rop, SV * op, SV *rnd) {
     if(sv_isobject(op)) {
       const char* h = HvNAME(SvSTASH(SvRV(op)));

       if(strEQ(h, "Math::LongDouble")) {
         return newSViv(mpfr_set_ld(*rop, *(INT2PTR(long double *, SvIV(SvRV(op)))), (mp_rnd_t)SvUV(rnd)));
       }
       croak("2nd arg (a %s object) supplied to Rmpfr_set_LD needs to be a Math::LongDouble object",
              HvNAME(SvSTASH(SvRV(op))));
     }
     else croak("2nd arg (which needs to be a Math::LongDouble object) supplied to Rmpfr_set_LD is not an object");
}

/*
int mpfr_set_decimal64 (mpfr_t rop, _Decimal64 op, mpfr_rnd_t rnd)
*/

SV * Rmpfr_set_DECIMAL64(pTHX_ mpfr_t * rop, SV * op, SV * rnd) {
#if (!defined(MPFR_VERSION) || (MPFR_VERSION<MPFR_VERSION_NUM(3,1,0)))
     croak("Perl interface to Rmpfr_set_DECIMAL64 not available for this version (%s) of the mpfr library. We need at least version 3.1.0",
            MPFR_VERSION_STRING);
#endif

/*
 MPFR_WANT_DECIMAL_FLOATS needs to have been defined prior to inclusion of mpfr.h - this is done by
 defining it at the 'Makefile.PL' step - see the Makefile.PL
*/

#ifdef MPFR_WANT_DECIMAL_FLOATS
    if(sv_isobject(op)) {
      const char* h = HvNAME(SvSTASH(SvRV(op)));

      if(strEQ(h, "Math::Decimal64"))
        return newSViv(mpfr_set_decimal64(*rop, *(INT2PTR(_Decimal64 *, SvIV(SvRV(op)))), (mp_rnd_t)SvUV(rnd)));
       croak("2nd arg (a %s object) supplied to Rmpfr_set_DECIMAL64 needs to be a Math::Decimal64 object",
               HvNAME(SvSTASH(SvRV(op))));
    }
    else croak("2nd arg (which needs to be a Math::Decimal64 object) supplied to Rmpfr_set_DECIMAL64 is not an object");

#else

    croak("MPFR_WANT_DECIMAL_FLOATS needs to have been defined when building Math::MPFR - see the Makefile.PL");

#endif
}

void Rmpfr_get_LD(pTHX_ SV * rop, mpfr_t * op, SV * rnd) {
     if(sv_isobject(rop)) {
       const char* h = HvNAME(SvSTASH(SvRV(rop)));

       if(strEQ(h, "Math::LongDouble")) {
         *(INT2PTR(long double *, SvIV(SvRV(rop)))) = mpfr_get_ld(*op, (mp_rnd_t)SvUV(rnd));
       }
       else croak("1st arg (a %s object) supplied to Rmpfr_get_LD needs to be a Math::LongDouble object",
                  HvNAME(SvSTASH(SvRV(rop))));
     }
     else croak("1st arg (which needs to be a Math::LongDouble object) supplied to Rmpfr_get_LD is not an object");
}

void Rmpfr_get_DECIMAL64(pTHX_ SV * rop, mpfr_t * op, SV * rnd) {
#if (!defined(MPFR_VERSION) || (MPFR_VERSION<MPFR_VERSION_NUM(3,1,0)))
     croak("Perl interface to Rmpfr_get_DECIMAL64 not available for this version (%s) of the mpfr library. We need at least version 3.1.0",
              MPFR_VERSION_STRING);
#endif

/*
 MPFR_WANT_DECIMAL_FLOATS needs to have been defined prior to inclusion of mpfr.h - this is done by
 defining it at the 'Makefile.PL' step - see the Makefile.PL
*/

#ifdef MPFR_WANT_DECIMAL_FLOATS
    if(sv_isobject(rop)) {
      const char* h = HvNAME(SvSTASH(SvRV(rop)));

      if(strEQ(h, "Math::Decimal64"))
        *(INT2PTR(_Decimal64 *, SvIV(SvRV(rop)))) = mpfr_get_decimal64(*op, (mp_rnd_t)SvUV(rnd));

       else croak("1st arg (a %s object) supplied to Rmpfr_get_DECIMAL64 needs to be a Math::Decimal64 object",
                      HvNAME(SvSTASH(SvRV(rop))));
    }
    else croak("1st arg (which needs to be a Math::Decimal64 object) supplied to Rmpfr_get_DECIMAL64 is not an object");

#else

    croak("MPFR_WANT_DECIMAL_FLOATS needs to have been defined when building Math::MPFR - see the Makefile.PL");

#endif
}

int _MPFR_WANT_DECIMAL_FLOATS(void) {
#ifdef MPFR_WANT_DECIMAL_FLOATS
 return 1;
#else
 return 0;
#endif
}

int _MPFR_WANT_FLOAT128(void) {
#ifdef MPFR_WANT_FLOAT128
 return 1;
#else
 return 0;
#endif
}

SV * _max_base(pTHX) {
     return newSViv(MAXIMUM_ALLOWABLE_BASE);
}

SV * _isobject(pTHX_ SV * x) {
    if(sv_isobject(x))return newSVuv(1);
    return newSVuv(0);
}

void _mp_sizes(void) {
     dTHX;
     dXSARGS;

     XPUSHs(sv_2mortal(newSVuv(sizeof(mpfr_exp_t))));
     XPUSHs(sv_2mortal(newSVuv(sizeof(mpfr_prec_t))));
     XPUSHs(sv_2mortal(newSVuv(sizeof(mpfr_rnd_t))));

     XSRETURN(3);
}

SV * _ivsize(pTHX) {
     return newSVuv(sizeof(IV));
}

SV * _nvsize(pTHX) {
     return newSVuv(sizeof(NV));
}

SV * _FLT128_DIG(pTHX) {
#ifdef FLT128_DIG
     return newSViv(FLT128_DIG);
#else
     return &PL_sv_undef;
#endif
}

SV * _LDBL_DIG(pTHX) {
#ifdef LDBL_DIG
     return newSViv(LDBL_DIG);
#else
     return &PL_sv_undef;
#endif
}

SV * _DBL_DIG(pTHX) {
#ifdef DBL_DIG
     return newSViv(DBL_DIG);
#else
     return &PL_sv_undef;
#endif
}

SV * _FLT128_MANT_DIG(pTHX) {
#ifdef FLT128_MANT_DIG
     return newSViv(FLT128_MANT_DIG);
#else
     return &PL_sv_undef;
#endif
}

SV * _LDBL_MANT_DIG(pTHX) {
#ifdef LDBL_MANT_DIG
     return newSViv(LDBL_MANT_DIG);
#else
     return &PL_sv_undef;
#endif
}

SV * _DBL_MANT_DIG(pTHX) {
#ifdef DBL_MANT_DIG
     return newSViv(DBL_MANT_DIG);
#else
     return &PL_sv_undef;
#endif
}


/*///////////////////////////////////////////
////////////////////////////////////////////*/
SV * Rgmp_randinit_default(pTHX) {
     gmp_randstate_t * state;
     SV * obj_ref, * obj;

     Newx(state, 1, gmp_randstate_t);
     if(state == NULL) croak("Failed to allocate memory in Rgmp_randinit_default function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     gmp_randinit_default(*state);

     sv_setiv(obj, INT2PTR(IV,state));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rgmp_randinit_mt(pTHX) {
     gmp_randstate_t * rand_obj;
     SV * obj_ref, * obj;

     Newx(rand_obj, 1, gmp_randstate_t);
     if(rand_obj == NULL) croak("Failed to allocate memory in Math::GMPz::Random::Rgmp_randinit_mt function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, "Math::GMPz::Random");
     gmp_randinit_mt(*rand_obj);

     sv_setiv(obj, INT2PTR(IV, rand_obj));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rgmp_randinit_lc_2exp(pTHX_ SV * a, SV * c, SV * m2exp ) {
     gmp_randstate_t * state;
     mpz_t aa;
     SV * obj_ref, * obj;

     Newx(state, 1, gmp_randstate_t);
     if(state == NULL) croak("Failed to allocate memory in Rgmp_randinit_lc_2exp function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);
     if(sv_isobject(a)) {
       const char* h = HvNAME(SvSTASH(SvRV(a)));

       if(strEQ(h, "Math::GMP") ||
          strEQ(h, "GMP::Mpz")  ||
          strEQ(h, "Math::GMPz"))
            gmp_randinit_lc_2exp(*state, *(INT2PTR(mpz_t *, SvIV(SvRV(a)))), (unsigned long)SvUV(c), (unsigned long)SvUV(m2exp));
       else croak("First arg to Rgmp_randinit_lc_2exp is of invalid type");
     }

     else {
       if(!mpz_init_set_str(aa, SvPV_nolen(a), 0)) {
         gmp_randinit_lc_2exp(*state, aa, (unsigned long)SvUV(c), (unsigned long)SvUV(m2exp));
         mpz_clear(aa);
       }
       else croak("Seedstring supplied to Rgmp_randinit_lc_2exp is not a valid number");
     }

     sv_setiv(obj, INT2PTR(IV,state));
     SvREADONLY_on(obj);
     return obj_ref;
}

SV * Rgmp_randinit_lc_2exp_size(pTHX_ SV * size) {
     gmp_randstate_t * state;
     SV * obj_ref, * obj;

     if(SvUV(size) > 128) croak("The argument supplied to Rgmp_randinit_lc_2exp_size function (%u) needs to be in the range [1..128]", SvUV(size));

     Newx(state, 1, gmp_randstate_t);
     if(state == NULL) croak("Failed to allocate memory in Rgmp_randinit_lc_2exp_size function");
     obj_ref = newSV(0);
     obj = newSVrv(obj_ref, NULL);

     if(gmp_randinit_lc_2exp_size(*state, (unsigned long)SvUV(size))) {
       sv_setiv(obj, INT2PTR(IV,state));
       SvREADONLY_on(obj);
       return obj_ref;
       }

     croak("Rgmp_randinit_lc_2exp_size function failed");
}

/***********************************************
************************************************/

SV * Rmpfr_get_float128(pTHX_ mpfr_t * op, SV * rnd) {

#ifdef CAN_PASS_FLOAT128
     return newSVnv(mpfr_get_float128(*op, (mp_rnd_t)SvUV(rnd)));
#else
     croak("Cannot use Rmpfr_get_float128 to return an NV");
#endif
}

void Rmpfr_get_FLOAT128(pTHX_ SV * rop, mpfr_t * op, SV * rnd) {
#if (!defined(MPFR_VERSION) || (MPFR_VERSION < MPFR_VERSION_NUM(3,2,0)))
     croak("Perl interface to Rmpfr_get_FLOAT128 not available for this version (%s) of the mpfr library. We need at least version 3.2.0",
              MPFR_VERSION_STRING);
#endif

/*
 MPFR_WANT_FLOAT128 needs to have been defined prior to inclusion of mpfr.h - this is done by
 defining it at the 'Makefile.PL' step - see the Makefile.PL
*/

#ifdef MPFR_WANT_FLOAT128
    if(sv_isobject(rop)) {
      const char* h = HvNAME(SvSTASH(SvRV(rop)));

      if(strEQ(h, "Math::Float128"))
        *(INT2PTR(float128 *, SvIV(SvRV(rop)))) = mpfr_get_float128(*op, (mp_rnd_t)SvUV(rnd));

       else croak("1st arg (a %s object) supplied to Rmpfr_get_FLOAT128 needs to be a Math::Float128 object",
                      HvNAME(SvSTASH(SvRV(rop))));
    }
    else croak("1st arg (which needs to be a Math::Float128 object) supplied to Rmpfr_get_FLOAT128 is not an object");

#else

    croak("MPFR_WANT_FLOAT128 needs to have been defined when building Math::MPFR - see the Makefile.PL");

#endif
}

SV * Rmpfr_set_FLOAT128(pTHX_ mpfr_t * rop, SV * op, SV * rnd) {
#if (!defined(MPFR_VERSION) || (MPFR_VERSION < MPFR_VERSION_NUM(3,2,0)))
     croak("Perl interface to Rmpfr_set_FLOAT128 not available for this version (%s) of the mpfr library. We need at least version 3.2.0",
            MPFR_VERSION_STRING);
#endif

/*
 MPFR_WANT_FLOAT128 needs to have been defined prior to inclusion of mpfr.h - this is done by
 defining it at the 'Makefile.PL' step - see the Makefile.PL
*/

#ifdef MPFR_WANT_FLOAT128
    if(sv_isobject(op)) {
      const char* h = HvNAME(SvSTASH(SvRV(op)));

      if(strEQ(h, "Math::Float128"))
        return newSViv(mpfr_set_float128(*rop, *(INT2PTR(float128 *, SvIV(SvRV(op)))), (mp_rnd_t)SvUV(rnd)));
       croak("2nd arg (a %s object) supplied to Rmpfr_set_FLOAT128 needs to be a Math::Float128 object",
               HvNAME(SvSTASH(SvRV(op))));
    }
    else croak("2nd arg (which needs to be a Math::Float128 object) supplied to Rmpfr_set_FLOAT128 is not an object");

#else

    croak("MPFR_WANT_FLOAT128 needs to have been defined when building Math::MPFR - see the Makefile.PL");

#endif
}

SV * Rmpfr_set_float128(pTHX_ mpfr_t * rop, SV * q, SV * rnd) {

#ifdef CAN_PASS_FLOAT128
     return newSViv(mpfr_set_float128(*rop, (float128)SvNV(q), (mp_rnd_t)SvUV(rnd)));
#else
     croak("Cannot use Rmpfr_set_float128 to set an NV");
#endif

}

SV * _is_readonly(pTHX_ SV * sv) {
     if SvREADONLY(sv) return newSVuv(1);
     return newSVuv(0);
}

void _readonly_on(pTHX_ SV * sv) {
     SvREADONLY_on(sv);
}

void _readonly_off(pTHX_ SV * sv) {
     SvREADONLY_off(sv);
}

int _can_pass_float128(void) {

#ifdef CAN_PASS_FLOAT128
   return 1;
#else
   return 0;
#endif

}

int _mpfr_want_float128(void) {

#ifdef MPFR_WANT_FLOAT128
   return 1;
#else
   return 0;
#endif

}


MODULE = Math::MPFR  PACKAGE = Math::MPFR

PROTOTYPES: DISABLE


int
_has_inttypes ()


void
Rmpfr_set_default_rounding_mode (round)
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_default_rounding_mode(aTHX_ round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

unsigned long
Rmpfr_get_default_rounding_mode ()


SV *
Rmpfr_prec_round (p, prec, round)
	mpfr_t *	p
	SV *	prec
	SV *	round
CODE:
  RETVAL = Rmpfr_prec_round (aTHX_ p, prec, round);
OUTPUT:  RETVAL

void
DESTROY (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        DESTROY(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clear (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clear_mpfr (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_mpfr(p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clear_ptr (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_ptr(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clears (p, ...)
	SV *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clears(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_init ()
CODE:
  RETVAL = Rmpfr_init (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_init2 (prec)
	SV *	prec
CODE:
  RETVAL = Rmpfr_init2 (aTHX_ prec);
OUTPUT:  RETVAL

SV *
Rmpfr_init_nobless ()
CODE:
  RETVAL = Rmpfr_init_nobless (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_init2_nobless (prec)
	SV *	prec
CODE:
  RETVAL = Rmpfr_init2_nobless (aTHX_ prec);
OUTPUT:  RETVAL

void
Rmpfr_init_set (q, round)
	mpfr_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_ui (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_ui(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_si (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_si(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_d (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_d(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_ld (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_ld(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_f (q, round)
	mpf_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_f(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_z (q, round)
	mpz_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_z(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_q (q, round)
	mpq_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_q(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_str (q, base, round)
	SV *	q
	SV *	base
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_str(aTHX_ q, base, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_nobless (q, round)
	mpfr_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_ui_nobless (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_ui_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_si_nobless (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_si_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_d_nobless (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_d_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_ld_nobless (q, round)
	SV *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_ld_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_f_nobless (q, round)
	mpf_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_f_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_z_nobless (q, round)
	mpz_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_z_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_q_nobless (q, round)
	mpq_t *	q
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_q_nobless(aTHX_ q, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_init_set_str_nobless (q, base, round)
	SV *	q
	SV *	base
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_init_set_str_nobless(aTHX_ q, base, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_deref2 (p, base, n_digits, round)
	mpfr_t *	p
	SV *	base
	SV *	n_digits
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_deref2(aTHX_ p, base, n_digits, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_default_prec (prec)
	SV *	prec
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_default_prec(aTHX_ prec);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_get_default_prec ()
CODE:
  RETVAL = Rmpfr_get_default_prec (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_min_prec (x)
	mpfr_t *	x
CODE:
  RETVAL = Rmpfr_min_prec (aTHX_ x);
OUTPUT:  RETVAL

void
Rmpfr_set_prec (p, prec)
	mpfr_t *	p
	SV *	prec
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_prec(aTHX_ p, prec);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_prec_raw (p, prec)
	mpfr_t *	p
	SV *	prec
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_prec_raw(aTHX_ p, prec);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_get_prec (p)
	mpfr_t *	p
CODE:
  RETVAL = Rmpfr_get_prec (aTHX_ p);
OUTPUT:  RETVAL

SV *
Rmpfr_set (p, q, round)
	mpfr_t *	p
	mpfr_t *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_ui (p, q, round)
	mpfr_t *	p
	SV *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_ui (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_si (p, q, round)
	mpfr_t *	p
	SV *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_si (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_uj (p, q, round)
	mpfr_t *	p
	SV *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_uj (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_sj (p, q, round)
	mpfr_t *	p
	SV *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_sj (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_NV (p, q, round)
	mpfr_t *	p
	SV *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_NV (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_ld (p, q, round)
	mpfr_t *	p
	SV *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_ld (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_d (p, q, round)
	mpfr_t *	p
	SV *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_d (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_z (p, q, round)
	mpfr_t *	p
	mpz_t *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_z (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_q (p, q, round)
	mpfr_t *	p
	mpq_t *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_q (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_f (p, q, round)
	mpfr_t *	p
	mpf_t *	q
	SV *	round
CODE:
  RETVAL = Rmpfr_set_f (aTHX_ p, q, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_str (p, num, base, round)
	mpfr_t *	p
	SV *	num
	SV *	base
	SV *	round
CODE:
  RETVAL = Rmpfr_set_str (aTHX_ p, num, base, round);
OUTPUT:  RETVAL

void
Rmpfr_set_str_binary (p, str)
	mpfr_t *	p
	SV *	str
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_str_binary(aTHX_ p, str);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_inf (p, sign)
	mpfr_t *	p
	int	sign
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_inf(p, sign);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_nan (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_nan(p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_swap (p, q)
	mpfr_t *	p
	mpfr_t *	q
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_swap(p, q);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_get_d (p, round)
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = Rmpfr_get_d (aTHX_ p, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_d_2exp (exp, p, round)
	SV *	exp
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = Rmpfr_get_d_2exp (aTHX_ exp, p, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_ld_2exp (exp, p, round)
	SV *	exp
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = Rmpfr_get_ld_2exp (aTHX_ exp, p, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_ld (p, round)
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = Rmpfr_get_ld (aTHX_ p, round);
OUTPUT:  RETVAL

double
Rmpfr_get_d1 (p)
	mpfr_t *	p

SV *
Rmpfr_get_z_2exp (z, p)
	mpz_t *	z
	mpfr_t *	p
CODE:
  RETVAL = Rmpfr_get_z_2exp (aTHX_ z, p);
OUTPUT:  RETVAL

SV *
Rmpfr_add (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_add (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_add_ui (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_add_ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_add_d (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_add_d (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_add_si (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_add_si (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_add_z (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpz_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_add_z (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_add_q (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpq_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_add_q (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sub (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sub (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sub_ui (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sub_ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sub_d (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sub_d (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sub_z (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpz_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sub_z (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sub_q (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpq_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sub_q (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_ui_sub (a, b, c, round)
	mpfr_t *	a
	SV *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_ui_sub (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_d_sub (a, b, c, round)
	mpfr_t *	a
	SV *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_d_sub (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_ui (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_d (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_d (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_z (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpz_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_z (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_q (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpq_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_q (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_dim (rop, op1, op2, round)
	mpfr_t *	rop
	mpfr_t *	op1
	mpfr_t *	op2
	SV *	round
CODE:
  RETVAL = Rmpfr_dim (aTHX_ rop, op1, op2, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_ui (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_d (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_d (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_z (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpz_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_z (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_q (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpq_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_q (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_ui_div (a, b, c, round)
	mpfr_t *	a
	SV *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_ui_div (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_d_div (a, b, c, round)
	mpfr_t *	a
	SV *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_d_div (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sqrt (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_sqrt (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_rec_sqrt (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_rec_sqrt (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_cbrt (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_cbrt (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sqrt_ui (a, b, round)
	mpfr_t *	a
	SV *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_sqrt_ui (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_pow_ui (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_pow_ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_ui_pow_ui (a, b, c, round)
	mpfr_t *	a
	SV *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_ui_pow_ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_ui_pow (a, b, c, round)
	mpfr_t *	a
	SV *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_ui_pow (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_pow_si (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_pow_si (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_pow (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_pow (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_neg (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_neg (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_abs (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_abs (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_2exp (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_2exp (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_2ui (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_2ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_2si (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_2si (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_2exp (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_2exp (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_2ui (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_2ui (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_2si (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_2si (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

int
Rmpfr_cmp (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_cmpabs (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_cmp_ui (a, b)
	mpfr_t *	a
	unsigned long	b

int
Rmpfr_cmp_d (a, b)
	mpfr_t *	a
	double	b

int
Rmpfr_cmp_ld (a, b)
	mpfr_t *	a
	SV *	b
CODE:
  RETVAL = Rmpfr_cmp_ld (aTHX_ a, b);
OUTPUT:  RETVAL

int
Rmpfr_cmp_si (a, b)
	mpfr_t *	a
	long	b

int
Rmpfr_cmp_ui_2exp (a, b, c)
	mpfr_t *	a
	SV *	b
	SV *	c
CODE:
  RETVAL = Rmpfr_cmp_ui_2exp (aTHX_ a, b, c);
OUTPUT:  RETVAL

int
Rmpfr_cmp_si_2exp (a, b, c)
	mpfr_t *	a
	SV *	b
	SV *	c
CODE:
  RETVAL = Rmpfr_cmp_si_2exp (aTHX_ a, b, c);
OUTPUT:  RETVAL

int
Rmpfr_eq (a, b, c)
	mpfr_t *	a
	mpfr_t *	b
	unsigned long	c

int
Rmpfr_nan_p (p)
	mpfr_t *	p

int
Rmpfr_inf_p (p)
	mpfr_t *	p

int
Rmpfr_number_p (p)
	mpfr_t *	p

void
Rmpfr_reldiff (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_reldiff(aTHX_ a, b, c, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

int
Rmpfr_sgn (p)
	mpfr_t *	p

int
Rmpfr_greater_p (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_greaterequal_p (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_less_p (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_lessequal_p (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_lessgreater_p (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_equal_p (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_unordered_p (a, b)
	mpfr_t *	a
	mpfr_t *	b

SV *
Rmpfr_sin_cos (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sin_cos (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sinh_cosh (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sinh_cosh (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sin (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_sin (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_cos (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_cos (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_tan (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_tan (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_asin (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_asin (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_acos (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_acos (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_atan (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_atan (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sinh (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_sinh (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_cosh (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_cosh (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_tanh (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_tanh (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_asinh (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_asinh (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_acosh (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_acosh (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_atanh (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_atanh (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fac_ui (a, b, round)
	mpfr_t *	a
	SV *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_fac_ui (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_log1p (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_log1p (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_expm1 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_expm1 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_log2 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_log2 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_log10 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_log10 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fma (a, b, c, d, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	mpfr_t *	d
	SV *	round
CODE:
  RETVAL = Rmpfr_fma (aTHX_ a, b, c, d, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fms (a, b, c, d, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	mpfr_t *	d
	SV *	round
CODE:
  RETVAL = Rmpfr_fms (aTHX_ a, b, c, d, round);
OUTPUT:  RETVAL

SV *
Rmpfr_agm (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_agm (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_hypot (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_hypot (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_const_log2 (p, round)
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = Rmpfr_const_log2 (aTHX_ p, round);
OUTPUT:  RETVAL

SV *
Rmpfr_const_pi (p, round)
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = Rmpfr_const_pi (aTHX_ p, round);
OUTPUT:  RETVAL

SV *
Rmpfr_const_euler (p, round)
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = Rmpfr_const_euler (aTHX_ p, round);
OUTPUT:  RETVAL

void
Rmpfr_print_binary (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_print_binary(p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_rint (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_rint (aTHX_ a, b, round);
OUTPUT:  RETVAL

int
Rmpfr_ceil (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_floor (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_round (a, b)
	mpfr_t *	a
	mpfr_t *	b

int
Rmpfr_trunc (a, b)
	mpfr_t *	a
	mpfr_t *	b

SV *
Rmpfr_can_round (p, err, round1, round2, prec)
	mpfr_t *	p
	SV *	err
	SV *	round1
	SV *	round2
	SV *	prec
CODE:
  RETVAL = Rmpfr_can_round (aTHX_ p, err, round1, round2, prec);
OUTPUT:  RETVAL

SV *
Rmpfr_get_emin ()
CODE:
  RETVAL = Rmpfr_get_emin (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_get_emax ()
CODE:
  RETVAL = Rmpfr_get_emax (aTHX);
OUTPUT:  RETVAL


int
Rmpfr_set_emin (e)
	SV *	e
CODE:
  RETVAL = Rmpfr_set_emin (aTHX_ e);
OUTPUT:  RETVAL

int
Rmpfr_set_emax (e)
	SV *	e
CODE:
  RETVAL = Rmpfr_set_emax (aTHX_ e);
OUTPUT:  RETVAL

SV *
Rmpfr_check_range (p, t, round)
	mpfr_t *	p
	SV *	t
	SV *	round
CODE:
  RETVAL = Rmpfr_check_range (aTHX_ p, t, round);
OUTPUT:  RETVAL

void
Rmpfr_clear_underflow ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_underflow();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clear_overflow ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_overflow();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clear_nanflag ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_nanflag();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clear_inexflag ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_inexflag();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_clear_flags ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_flags();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

int
Rmpfr_underflow_p ()


int
Rmpfr_overflow_p ()


int
Rmpfr_nanflag_p ()


int
Rmpfr_inexflag_p ()


SV *
Rmpfr_log (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_log (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_exp (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_exp (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_exp2 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_exp2 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_exp10 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_exp10 (aTHX_ a, b, round);
OUTPUT:  RETVAL

void
Rmpfr_urandomb (x, ...)
	SV *	x
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_urandomb(aTHX_ x);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_random2 (p, s, exp)
	mpfr_t *	p
	SV *	s
	SV *	exp
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_random2(aTHX_ p, s, exp);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
_TRmpfr_out_str (stream, base, dig, p, round)
	FILE *	stream
	SV *	base
	SV *	dig
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = _TRmpfr_out_str (aTHX_ stream, base, dig, p, round);
OUTPUT:  RETVAL

SV *
_Rmpfr_out_str (p, base, dig, round)
	mpfr_t *	p
	SV *	base
	SV *	dig
	SV *	round
CODE:
  RETVAL = _Rmpfr_out_str (aTHX_ p, base, dig, round);
OUTPUT:  RETVAL

SV *
_TRmpfr_out_strS (stream, base, dig, p, round, suff)
	FILE *	stream
	SV *	base
	SV *	dig
	mpfr_t *	p
	SV *	round
	SV *	suff
CODE:
  RETVAL = _TRmpfr_out_strS (aTHX_ stream, base, dig, p, round, suff);
OUTPUT:  RETVAL

SV *
_TRmpfr_out_strP (pre, stream, base, dig, p, round)
	SV *	pre
	FILE *	stream
	SV *	base
	SV *	dig
	mpfr_t *	p
	SV *	round
CODE:
  RETVAL = _TRmpfr_out_strP (aTHX_ pre, stream, base, dig, p, round);
OUTPUT:  RETVAL

SV *
_TRmpfr_out_strPS (pre, stream, base, dig, p, round, suff)
	SV *	pre
	FILE *	stream
	SV *	base
	SV *	dig
	mpfr_t *	p
	SV *	round
	SV *	suff
CODE:
  RETVAL = _TRmpfr_out_strPS (aTHX_ pre, stream, base, dig, p, round, suff);
OUTPUT:  RETVAL

SV *
_Rmpfr_out_strS (p, base, dig, round, suff)
	mpfr_t *	p
	SV *	base
	SV *	dig
	SV *	round
	SV *	suff
CODE:
  RETVAL = _Rmpfr_out_strS (aTHX_ p, base, dig, round, suff);
OUTPUT:  RETVAL

SV *
_Rmpfr_out_strP (pre, p, base, dig, round)
	SV *	pre
	mpfr_t *	p
	SV *	base
	SV *	dig
	SV *	round
CODE:
  RETVAL = _Rmpfr_out_strP (aTHX_ pre, p, base, dig, round);
OUTPUT:  RETVAL

SV *
_Rmpfr_out_strPS (pre, p, base, dig, round, suff)
	SV *	pre
	mpfr_t *	p
	SV *	base
	SV *	dig
	SV *	round
	SV *	suff
CODE:
  RETVAL = _Rmpfr_out_strPS (aTHX_ pre, p, base, dig, round, suff);
OUTPUT:  RETVAL

SV *
TRmpfr_inp_str (p, stream, base, round)
	mpfr_t *	p
	FILE *	stream
	SV *	base
	SV *	round
CODE:
  RETVAL = TRmpfr_inp_str (aTHX_ p, stream, base, round);
OUTPUT:  RETVAL

SV *
Rmpfr_inp_str (p, base, round)
	mpfr_t *	p
	SV *	base
	SV *	round
CODE:
  RETVAL = Rmpfr_inp_str (aTHX_ p, base, round);
OUTPUT:  RETVAL

SV *
Rmpfr_gamma (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_gamma (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_zeta (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_zeta (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_zeta_ui (a, b, round)
	mpfr_t *	a
	SV *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_zeta_ui (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_erf (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_erf (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_frac (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_frac (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_remainder (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_remainder (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_modf (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_modf (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fmod (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_fmod (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

void
Rmpfr_remquo (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_remquo(aTHX_ a, b, c, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

int
Rmpfr_integer_p (p)
	mpfr_t *	p

void
Rmpfr_nexttoward (a, b)
	mpfr_t *	a
	mpfr_t *	b
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_nexttoward(a, b);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_nextabove (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_nextabove(p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_nextbelow (p)
	mpfr_t *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_nextbelow(p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_min (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_min (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_max (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_max (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_exp (p)
	mpfr_t *	p
CODE:
  RETVAL = Rmpfr_get_exp (aTHX_ p);
OUTPUT:  RETVAL

SV *
Rmpfr_set_exp (p, exp)
	mpfr_t *	p
	SV *	exp
CODE:
  RETVAL = Rmpfr_set_exp (aTHX_ p, exp);
OUTPUT:  RETVAL

int
Rmpfr_signbit (op)
	mpfr_t *	op

SV *
Rmpfr_setsign (rop, op, sign, round)
	mpfr_t *	rop
	mpfr_t *	op
	SV *	sign
	SV *	round
CODE:
  RETVAL = Rmpfr_setsign (aTHX_ rop, op, sign, round);
OUTPUT:  RETVAL

SV *
Rmpfr_copysign (rop, op1, op2, round)
	mpfr_t *	rop
	mpfr_t *	op1
	mpfr_t *	op2
	SV *	round
CODE:
  RETVAL = Rmpfr_copysign (aTHX_ rop, op1, op2, round);
OUTPUT:  RETVAL

SV *
get_refcnt (s)
	SV *	s
CODE:
  RETVAL = get_refcnt (aTHX_ s);
OUTPUT:  RETVAL

SV *
get_package_name (x)
	SV *	x
CODE:
  RETVAL = get_package_name (aTHX_ x);
OUTPUT:  RETVAL

void
Rmpfr_dump (a)
	mpfr_t *	a
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_dump(a);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
gmp_v ()
CODE:
  RETVAL = gmp_v (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_set_ui_2exp (a, b, c, round)
	mpfr_t *	a
	SV *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_set_ui_2exp (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_si_2exp (a, b, c, round)
	mpfr_t *	a
	SV *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_set_si_2exp (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_uj_2exp (a, b, c, round)
	mpfr_t *	a
	SV *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_set_uj_2exp (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_sj_2exp (a, b, c, round)
	mpfr_t *	a
	SV *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_set_sj_2exp (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_z (a, b, round)
	mpz_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_get_z (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_si_sub (a, b, c, round)
	mpfr_t *	a
	SV *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_si_sub (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sub_si (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_sub_si (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_mul_si (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_mul_si (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_si_div (a, b, c, round)
	mpfr_t *	a
	SV *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_si_div (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_div_si (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_div_si (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sqr (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_sqr (aTHX_ a, b, round);
OUTPUT:  RETVAL

int
Rmpfr_cmp_z (a, b)
	mpfr_t *	a
	mpz_t *	b

int
Rmpfr_cmp_q (a, b)
	mpfr_t *	a
	mpq_t *	b

int
Rmpfr_cmp_f (a, b)
	mpfr_t *	a
	mpf_t *	b

int
Rmpfr_zero_p (a)
	mpfr_t *	a

void
Rmpfr_free_cache ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_free_cache();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_get_version ()
CODE:
  RETVAL = Rmpfr_get_version (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_get_patches ()
CODE:
  RETVAL = Rmpfr_get_patches (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_get_emin_min ()
CODE:
  RETVAL = Rmpfr_get_emin_min (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_get_emin_max ()
CODE:
  RETVAL = Rmpfr_get_emin_max (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_get_emax_min ()
CODE:
  RETVAL = Rmpfr_get_emax_min (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_get_emax_max ()
CODE:
  RETVAL = Rmpfr_get_emax_max (aTHX);
OUTPUT:  RETVAL


void
Rmpfr_clear_erangeflag ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_erangeflag();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

int
Rmpfr_erangeflag_p ()


SV *
Rmpfr_rint_round (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_rint_round (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_rint_trunc (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_rint_trunc (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_rint_ceil (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_rint_ceil (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_rint_floor (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_rint_floor (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_ui (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_get_ui (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_si (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_get_si (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_uj (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_get_uj (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_sj (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_get_sj (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_IV (x, round)
	mpfr_t *	x
	SV *	round
CODE:
  RETVAL = Rmpfr_get_IV (aTHX_ x, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_UV (x, round)
	mpfr_t *	x
	SV *	round
CODE:
  RETVAL = Rmpfr_get_UV (aTHX_ x, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_NV (x, round)
	mpfr_t *	x
	SV *	round
CODE:
  RETVAL = Rmpfr_get_NV (aTHX_ x, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_ulong_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_ulong_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_slong_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_slong_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_ushort_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_ushort_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_sshort_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_sshort_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_uint_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_uint_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_sint_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_sint_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_uintmax_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_uintmax_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_intmax_p (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_intmax_p (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_IV_p (x, round)
	mpfr_t *	x
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_IV_p (aTHX_ x, round);
OUTPUT:  RETVAL

SV *
Rmpfr_fits_UV_p (x, round)
	mpfr_t *	x
	SV *	round
CODE:
  RETVAL = Rmpfr_fits_UV_p (aTHX_ x, round);
OUTPUT:  RETVAL

SV *
Rmpfr_strtofr (a, str, base, round)
	mpfr_t *	a
	SV *	str
	SV *	base
	SV *	round
CODE:
  RETVAL = Rmpfr_strtofr (aTHX_ a, str, base, round);
OUTPUT:  RETVAL

void
Rmpfr_set_erangeflag ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_erangeflag();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_underflow ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_underflow();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_overflow ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_overflow();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_nanflag ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_nanflag();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_inexflag ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_inexflag();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_erfc (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_erfc (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_j0 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_j0 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_j1 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_j1 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_jn (a, n, b, round)
	mpfr_t *	a
	SV *	n
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_jn (aTHX_ a, n, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_y0 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_y0 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_y1 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_y1 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_yn (a, n, b, round)
	mpfr_t *	a
	SV *	n
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_yn (aTHX_ a, n, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_atan2 (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpfr_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_atan2 (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_pow_z (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	mpz_t *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_pow_z (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_subnormalize (a, b, round)
	mpfr_t *	a
	SV *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_subnormalize (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_const_catalan (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_const_catalan (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sec (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_sec (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_csc (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_csc (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_cot (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_cot (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_root (a, b, c, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	c
	SV *	round
CODE:
  RETVAL = Rmpfr_root (aTHX_ a, b, c, round);
OUTPUT:  RETVAL

SV *
Rmpfr_eint (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_eint (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_li2 (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_li2 (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_f (a, b, round)
	mpf_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_get_f (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_sech (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_sech (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_csch (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_csch (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_coth (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_coth (aTHX_ a, b, round);
OUTPUT:  RETVAL

SV *
Rmpfr_lngamma (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
CODE:
  RETVAL = Rmpfr_lngamma (aTHX_ a, b, round);
OUTPUT:  RETVAL

void
Rmpfr_lgamma (a, b, round)
	mpfr_t *	a
	mpfr_t *	b
	SV *	round
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_lgamma(aTHX_ a, b, round);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
_MPFR_VERSION ()
CODE:
  RETVAL = _MPFR_VERSION (aTHX);
OUTPUT:  RETVAL


SV *
_MPFR_VERSION_MAJOR ()
CODE:
  RETVAL = _MPFR_VERSION_MAJOR (aTHX);
OUTPUT:  RETVAL


SV *
_MPFR_VERSION_MINOR ()
CODE:
  RETVAL = _MPFR_VERSION_MINOR (aTHX);
OUTPUT:  RETVAL


SV *
_MPFR_VERSION_PATCHLEVEL ()
CODE:
  RETVAL = _MPFR_VERSION_PATCHLEVEL (aTHX);
OUTPUT:  RETVAL


SV *
_MPFR_VERSION_STRING ()
CODE:
  RETVAL = _MPFR_VERSION_STRING (aTHX);
OUTPUT:  RETVAL


SV *
RMPFR_VERSION_NUM (a, b, c)
	SV *	a
	SV *	b
	SV *	c
CODE:
  RETVAL = RMPFR_VERSION_NUM (aTHX_ a, b, c);
OUTPUT:  RETVAL

SV *
Rmpfr_sum (rop, avref, len, round)
	mpfr_t *	rop
	SV *	avref
	SV *	len
	SV *	round
CODE:
  RETVAL = Rmpfr_sum (aTHX_ rop, avref, len, round);
OUTPUT:  RETVAL

SV *
overload_mul (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_mul (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_add (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_add (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_sub (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_sub (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_div (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_div (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_copy (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_copy (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_abs (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_abs (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_gt (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_gt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_gte (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_gte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_lt (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_lt (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_lte (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_lte (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_spaceship (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_spaceship (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_equiv (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_not_equiv (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_not_equiv (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_true (a, second, third)
	mpfr_t *	a
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_true (aTHX_ a, second, third);
OUTPUT:  RETVAL

SV *
overload_not (a, second, third)
	mpfr_t *	a
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_not (aTHX_ a, second, third);
OUTPUT:  RETVAL

SV *
overload_sqrt (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_sqrt (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_pow (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_pow (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_log (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_log (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_exp (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_exp (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_sin (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_sin (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_cos (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_cos (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_int (p, second, third)
	mpfr_t *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_int (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_atan2 (a, b, third)
	mpfr_t *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_atan2 (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
Rgmp_randinit_default_nobless ()
CODE:
  RETVAL = Rgmp_randinit_default_nobless (aTHX);
OUTPUT:  RETVAL


SV *
Rgmp_randinit_mt_nobless ()
CODE:
  RETVAL = Rgmp_randinit_mt_nobless (aTHX);
OUTPUT:  RETVAL


SV *
Rgmp_randinit_lc_2exp_nobless (a, c, m2exp)
	SV *	a
	SV *	c
	SV *	m2exp
CODE:
  RETVAL = Rgmp_randinit_lc_2exp_nobless (aTHX_ a, c, m2exp);
OUTPUT:  RETVAL

SV *
Rgmp_randinit_lc_2exp_size_nobless (size)
	SV *	size
CODE:
  RETVAL = Rgmp_randinit_lc_2exp_size_nobless (aTHX_ size);
OUTPUT:  RETVAL

void
Rgmp_randclear (p)
	SV *	p
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rgmp_randclear(aTHX_ p);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rgmp_randseed (state, seed)
	SV *	state
	SV *	seed
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rgmp_randseed(aTHX_ state, seed);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rgmp_randseed_ui (state, seed)
	SV *	state
	SV *	seed
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rgmp_randseed_ui(aTHX_ state, seed);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
overload_pow_eq (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_pow_eq (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_div_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_div_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_sub_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_sub_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_add_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_add_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
overload_mul_eq (a, b, third)
	SV *	a
	SV *	b
	SV *	third
CODE:
  RETVAL = overload_mul_eq (aTHX_ a, b, third);
OUTPUT:  RETVAL

SV *
_itsa (a)
	SV *	a
CODE:
  RETVAL = _itsa (aTHX_ a);
OUTPUT:  RETVAL

int
_has_longlong ()


int
_has_longdouble ()


int
_ivsize_bits ()


SV *
RMPFR_PREC_MAX ()
CODE:
  RETVAL = RMPFR_PREC_MAX (aTHX);
OUTPUT:  RETVAL


SV *
RMPFR_PREC_MIN ()
CODE:
  RETVAL = RMPFR_PREC_MIN (aTHX);
OUTPUT:  RETVAL


SV *
wrap_mpfr_printf (a, b)
	SV *	a
	SV *	b
CODE:
  RETVAL = wrap_mpfr_printf (aTHX_ a, b);
OUTPUT:  RETVAL

SV *
wrap_mpfr_fprintf (stream, a, b)
	FILE *	stream
	SV *	a
	SV *	b
CODE:
  RETVAL = wrap_mpfr_fprintf (aTHX_ stream, a, b);
OUTPUT:  RETVAL

SV *
wrap_mpfr_sprintf (s, a, b, buflen)
	SV *	s
	SV *	a
	SV *	b
	int	buflen
CODE:
  RETVAL = wrap_mpfr_sprintf (aTHX_ s, a, b, buflen);
OUTPUT:  RETVAL

SV *
wrap_mpfr_snprintf (s, bytes, a, b, buflen)
	SV *	s
	SV *	bytes
	SV *	a
	SV *	b
	int	buflen
CODE:
  RETVAL = wrap_mpfr_snprintf (aTHX_ s, bytes, a, b, buflen);
OUTPUT:  RETVAL

SV *
wrap_mpfr_printf_rnd (a, round, b)
	SV *	a
	SV *	round
	SV *	b
CODE:
  RETVAL = wrap_mpfr_printf_rnd (aTHX_ a, round, b);
OUTPUT:  RETVAL

SV *
wrap_mpfr_fprintf_rnd (stream, a, round, b)
	FILE *	stream
	SV *	a
	SV *	round
	SV *	b
CODE:
  RETVAL = wrap_mpfr_fprintf_rnd (aTHX_ stream, a, round, b);
OUTPUT:  RETVAL

SV *
wrap_mpfr_sprintf_rnd (s, a, round, b, buflen)
	SV *	s
	SV *	a
	SV *	round
	SV *	b
	int	buflen
CODE:
  RETVAL = wrap_mpfr_sprintf_rnd (aTHX_ s, a, round, b, buflen);
OUTPUT:  RETVAL

SV *
wrap_mpfr_snprintf_rnd (s, bytes, a, round, b, buflen)
	SV *	s
	SV *	bytes
	SV *	a
	SV *	round
	SV *	b
	int	buflen
CODE:
  RETVAL = wrap_mpfr_snprintf_rnd (aTHX_ s, bytes, a, round, b, buflen);
OUTPUT:  RETVAL

SV *
Rmpfr_buildopt_tls_p ()
CODE:
  RETVAL = Rmpfr_buildopt_tls_p (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_buildopt_decimal_p ()
CODE:
  RETVAL = Rmpfr_buildopt_decimal_p (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_regular_p (a)
	mpfr_t *	a
CODE:
  RETVAL = Rmpfr_regular_p (aTHX_ a);
OUTPUT:  RETVAL

void
Rmpfr_set_zero (a, sign)
	mpfr_t *	a
	SV *	sign
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_zero(aTHX_ a, sign);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_digamma (rop, op, round)
	mpfr_t *	rop
	mpfr_t *	op
	SV *	round
CODE:
  RETVAL = Rmpfr_digamma (aTHX_ rop, op, round);
OUTPUT:  RETVAL

SV *
Rmpfr_ai (rop, op, round)
	mpfr_t *	rop
	mpfr_t *	op
	SV *	round
CODE:
  RETVAL = Rmpfr_ai (aTHX_ rop, op, round);
OUTPUT:  RETVAL

SV *
Rmpfr_get_flt (a, round)
	mpfr_t *	a
	SV *	round
CODE:
  RETVAL = Rmpfr_get_flt (aTHX_ a, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_flt (rop, f, round)
	mpfr_t *	rop
	SV *	f
	SV *	round
CODE:
  RETVAL = Rmpfr_set_flt (aTHX_ rop, f, round);
OUTPUT:  RETVAL

SV *
Rmpfr_urandom (rop, state, round)
	mpfr_t *	rop
	gmp_randstate_t *	state
	SV *	round
CODE:
  RETVAL = Rmpfr_urandom (aTHX_ rop, state, round);
OUTPUT:  RETVAL

SV *
Rmpfr_set_z_2exp (rop, op, exp, round)
	mpfr_t *	rop
	mpz_t *	op
	SV *	exp
	SV *	round
CODE:
  RETVAL = Rmpfr_set_z_2exp (aTHX_ rop, op, exp, round);
OUTPUT:  RETVAL

SV *
Rmpfr_buildopt_tune_case ()
CODE:
  RETVAL = Rmpfr_buildopt_tune_case (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_frexp (exp, rop, op, round)
	SV *	exp
	mpfr_t *	rop
	mpfr_t *	op
	SV *	round
CODE:
  RETVAL = Rmpfr_frexp (aTHX_ exp, rop, op, round);
OUTPUT:  RETVAL

SV *
Rmpfr_z_sub (rop, op1, op2, round)
	mpfr_t *	rop
	mpz_t *	op1
	mpfr_t *	op2
	SV *	round
CODE:
  RETVAL = Rmpfr_z_sub (aTHX_ rop, op1, op2, round);
OUTPUT:  RETVAL

SV *
Rmpfr_grandom (rop1, rop2, state, round)
	mpfr_t *	rop1
	mpfr_t *	rop2
	gmp_randstate_t *	state
	SV *	round
CODE:
  RETVAL = Rmpfr_grandom (aTHX_ rop1, rop2, state, round);
OUTPUT:  RETVAL

void
Rmpfr_clear_divby0 ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_clear_divby0(aTHX);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_set_divby0 ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_set_divby0(aTHX);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_divby0_p ()
CODE:
  RETVAL = Rmpfr_divby0_p (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_buildopt_gmpinternals_p ()
CODE:
  RETVAL = Rmpfr_buildopt_gmpinternals_p (aTHX);
OUTPUT:  RETVAL


SV *
_get_xs_version ()
CODE:
  RETVAL = _get_xs_version (aTHX);
OUTPUT:  RETVAL


SV *
overload_inc (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_inc (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
overload_dec (p, second, third)
	SV *	p
	SV *	second
	SV *	third
CODE:
  RETVAL = overload_dec (aTHX_ p, second, third);
OUTPUT:  RETVAL

SV *
_wrap_count ()
CODE:
  RETVAL = _wrap_count (aTHX);
OUTPUT:  RETVAL


SV *
Rmpfr_set_LD (rop, op, rnd)
	mpfr_t *	rop
	SV *	op
	SV *	rnd
CODE:
  RETVAL = Rmpfr_set_LD (aTHX_ rop, op, rnd);
OUTPUT:  RETVAL

SV *
Rmpfr_set_DECIMAL64 (rop, op, rnd)
	mpfr_t *	rop
	SV *	op
	SV *	rnd
CODE:
  RETVAL = Rmpfr_set_DECIMAL64 (aTHX_ rop, op, rnd);
OUTPUT:  RETVAL

void
Rmpfr_get_LD (rop, op, rnd)
	SV *	rop
	mpfr_t *	op
	SV *	rnd
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_get_LD(aTHX_ rop, op, rnd);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
Rmpfr_get_DECIMAL64 (rop, op, rnd)
	SV *	rop
	mpfr_t *	op
	SV *	rnd
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_get_DECIMAL64(aTHX_ rop, op, rnd);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

int
_MPFR_WANT_DECIMAL_FLOATS ()


int
_MPFR_WANT_FLOAT128 ()


SV *
_max_base ()
CODE:
  RETVAL = _max_base (aTHX);
OUTPUT:  RETVAL


SV *
_isobject (x)
	SV *	x
CODE:
  RETVAL = _isobject (aTHX_ x);
OUTPUT:  RETVAL

void
_mp_sizes ()

        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _mp_sizes();
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
_ivsize ()
CODE:
  RETVAL = _ivsize (aTHX);
OUTPUT:  RETVAL


SV *
_nvsize ()
CODE:
  RETVAL = _nvsize (aTHX);
OUTPUT:  RETVAL


SV *
_FLT128_DIG ()
CODE:
  RETVAL = _FLT128_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_LDBL_DIG ()
CODE:
  RETVAL = _LDBL_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_DBL_DIG ()
CODE:
  RETVAL = _DBL_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_FLT128_MANT_DIG ()
CODE:
  RETVAL = _FLT128_MANT_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_LDBL_MANT_DIG ()
CODE:
  RETVAL = _LDBL_MANT_DIG (aTHX);
OUTPUT:  RETVAL


SV *
_DBL_MANT_DIG ()
CODE:
  RETVAL = _DBL_MANT_DIG (aTHX);
OUTPUT:  RETVAL


SV *
Rgmp_randinit_default ()
CODE:
  RETVAL = Rgmp_randinit_default (aTHX);
OUTPUT:  RETVAL


SV *
Rgmp_randinit_mt ()
CODE:
  RETVAL = Rgmp_randinit_mt (aTHX);
OUTPUT:  RETVAL


SV *
Rgmp_randinit_lc_2exp (a, c, m2exp)
	SV *	a
	SV *	c
	SV *	m2exp
CODE:
  RETVAL = Rgmp_randinit_lc_2exp (aTHX_ a, c, m2exp);
OUTPUT:  RETVAL

SV *
Rgmp_randinit_lc_2exp_size (size)
	SV *	size
CODE:
  RETVAL = Rgmp_randinit_lc_2exp_size (aTHX_ size);
OUTPUT:  RETVAL

SV *
Rmpfr_get_float128 (op, rnd)
	mpfr_t *	op
	SV *	rnd
CODE:
  RETVAL = Rmpfr_get_float128 (aTHX_ op, rnd);
OUTPUT:  RETVAL

void
Rmpfr_get_FLOAT128 (rop, op, rnd)
	SV *	rop
	mpfr_t *	op
	SV *	rnd
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        Rmpfr_get_FLOAT128(aTHX_ rop, op, rnd);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

SV *
Rmpfr_set_FLOAT128 (rop, op, rnd)
	mpfr_t *	rop
	SV *	op
	SV *	rnd
CODE:
  RETVAL = Rmpfr_set_FLOAT128 (aTHX_ rop, op, rnd);
OUTPUT:  RETVAL

SV *
Rmpfr_set_float128 (rop, q, rnd)
	mpfr_t *	rop
	SV *	q
	SV *	rnd
CODE:
  RETVAL = Rmpfr_set_float128 (aTHX_ rop, q, rnd);
OUTPUT:  RETVAL

SV *
_is_readonly (sv)
	SV *	sv
CODE:
  RETVAL = _is_readonly (aTHX_ sv);
OUTPUT:  RETVAL

void
_readonly_on (sv)
	SV *	sv
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _readonly_on(aTHX_ sv);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

void
_readonly_off (sv)
	SV *	sv
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        _readonly_off(aTHX_ sv);
        if (PL_markstack_ptr != temp) {
          /* truly void, because dXSARGS not invoked */
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY; /* return empty stack */
        }
        /* must have used dXSARGS; list context implied */
        return; /* assume stack size is correct */

int
_can_pass_float128 ()


int
_mpfr_want_float128 ()


