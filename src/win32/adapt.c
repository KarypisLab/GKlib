/*
\file  win32/adapt.c
\brief Implementation of Win32 adaptation of libc functions
*/

#include "win32/adapt.h"

pid_t getpid(void)
{
  return GetCurrentProcessId();
}
