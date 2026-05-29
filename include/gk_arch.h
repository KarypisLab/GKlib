/*!
\file gk_arch.h
\brief This file contains various architecture-specific declerations

\date   Started 3/27/2007
\author George
\version\verbatim $Id: gk_arch.h 21637 2018-01-03 22:37:24Z karypis $ \endverbatim
*/

#ifndef _GK_ARCH_H_
#define _GK_ARCH_H_

/*************************************************************************
* Architecture-specific differences in header files
**************************************************************************/
#ifdef LINUX
#if !defined(__USE_XOPEN)
#define __USE_XOPEN
#endif
#if !defined(_XOPEN_SOURCE)
#define _XOPEN_SOURCE 600
#endif
#if !defined(__USE_XOPEN2K)
#define __USE_XOPEN2K
#endif
#endif


#ifdef HAVE_EXECINFO_H
#include <execinfo.h>
#endif


#ifdef __MSC__ 
  /* VS2010+ ships <stdint.h>/<inttypes.h>; the bundled polyfills are for older MSVC. */
  #if _MSC_VER >= 1600
    #include <stdint.h>
    #include <inttypes.h>
  #else
    #include "gk_ms_stdint.h"
    #include "gk_ms_inttypes.h"
  #endif
  #include "gk_ms_stat.h"
  #include "win32/adapt.h"
#else
#ifndef SUNOS
  #include <stdint.h>
#endif
  #include <inttypes.h>
  #include <sys/types.h>
#ifndef __MINGW32__
  #include <sys/resource.h>
#endif
  #include <sys/time.h>
  #include <unistd.h>
#endif


/*************************************************************************
* Architecture-specific modifications
**************************************************************************/
#ifdef WIN32
typedef ptrdiff_t ssize_t;
#endif


#ifdef SUNOS
#define PTRDIFF_MAX  INT64_MAX
#endif

/* Ensure INFINITY is available. C99 and later (including MSVC's UCRT) define
   it in <math.h>; pull that in first so the guard below sees the system
   definition instead of shadowing it (which triggers MSVC warning C4005).
   The FLT_MAX fallback only applies to toolchains that genuinely lack it. */
#include <math.h>
#ifndef INFINITY
#include <float.h>
#define INFINITY FLT_MAX
#endif

#endif
