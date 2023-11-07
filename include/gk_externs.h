/*!
\file gk_externs.h
\brief This file contains definitions of external variables created by GKlib

\date   Started 3/27/2007
\author George
\version\verbatim $Id: gk_externs.h 10711 2011-08-31 22:23:04Z karypis $ \endverbatim
*/

#ifndef _GK_EXTERNS_H_
#define _GK_EXTERNS_H_

// Windows does not support _Thread_local. Use appropriate aliases
// Reference: https://stackoverflow.com/a/18298965
#ifndef thread_local
#if __STDC_VERSION__ >= 201112 && !defined __STDC_NO_THREADS__
#define thread_local _Thread_local
#elif defined _MSC_VER
#define thread_local __declspec(thread)
#elif defined __GNUC__
#define thread_local __thread
#else
#error "Cannot define thread_local"
#endif
#endif

#ifndef _GK_ERROR_C_
/* declared in error.c */
extern thread_local int gk_cur_jbufs;
extern thread_local jmp_buf gk_jbufs[];
extern thread_local jmp_buf gk_jbuf;

#endif

#endif
