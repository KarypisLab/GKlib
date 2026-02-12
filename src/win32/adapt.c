/*
\file  win32/adapt.c
\brief Implementation of Win32 adaptation of libc functions
*/

#ifdef _WIN32
#include "win32/adapt.h"
#else
#include "adapt.h"
#endif 

pid_t getpid(void)
{
  return GetCurrentProcessId();
}
