# Helper modules.
include(CheckFunctionExists)
include(CheckIncludeFile)

# Setup options.
option(GKLIB_GDB "enable use of GDB" OFF)
option(GKLIB_ASSERT "turn asserts on" OFF)
option(GKLIB_ASSERT2 "additional assertions" OFF)
option(GKLIB_DEBUG "add debugging support" OFF)
option(GKLIB_GPROF "add gprof support" OFF)
option(GKLIB_VALGRIND "add valgrind support" OFF)
option(GKLIB_OPENMP "enable OpenMP support" OFF)
option(GKLIB_PCRE "enable PCRE support" OFF)
option(GKLIB_GKREGEX "enable GKREGEX support" OFF)
option(GKLIB_GKRAND "enable GKRAND support" OFF)
option(GKLIB_NO_X86 "enable NO_X86 support" OFF)


# Add compiler flags.
if(MSVC)
  set(GKlib_COPTS "/Ox")
  set(GKlib_COPTIONS "-DWIN32 -DMSC -D_CRT_SECURE_NO_DEPRECATE -DUSE_GKREGEX")
elseif(MINGW)
  set(GKlib_COPTS "-DUSE_GKREGEX")
else()
  set(GKlib_COPTIONS "-DLINUX -D_FILE_OFFSET_BITS=64")
endif(MSVC)
if(CYGWIN)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DCYGWIN")
endif(CYGWIN)
if(CMAKE_COMPILER_IS_GNUCC)
# GCC opts.
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -std=c99 -fno-strict-aliasing")
if(GKLIB_VALGRIND)
  set(GKlib_COPTIONS "${GK_COPTIONS} -march=x86-64 -mtune=generic")
else()
# -march=native is not a valid flag on PPC:
if(CMAKE_SYSTEM_PROCESSOR MATCHES "power|ppc|powerpc|ppc64|powerpc64" OR (APPLE AND CMAKE_OSX_ARCHITECTURES MATCHES "ppc|ppc64"))
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -mtune=native")
else()
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -march=native")
endif()
endif(GKLIB_VALGRIND)
  if(NOT MINGW)
      set(GKlib_COPTIONS "${GKlib_COPTIONS} -fPIC")
  endif(NOT MINGW)
# GCC warnings.
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -Werror -Wall -pedantic -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-variable -Wno-unknown-pragmas -Wno-unused-label")
elseif(${CMAKE_C_COMPILER_ID} MATCHES "Sun")
# Sun insists on -xc99.
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -xc99")
endif(CMAKE_COMPILER_IS_GNUCC)

# Intel compiler
if(${CMAKE_C_COMPILER_ID} MATCHES "Intel")
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -xHost -std=c99")
endif()

# Find OpenMP if it is requested.
if(GKLIB_OPENMP)
  include(FindOpenMP)
  if(OPENMP_FOUND)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -D__OPENMP__ ${OpenMP_C_FLAGS}")
  else()
    message(WARNING "OpenMP was requested but support was not found")
  endif(OPENMP_FOUND)
endif(GKLIB_OPENMP)

# Set the CPU type 
if(GKLIB_NO_X86)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DNO_X86=${GKLIB_NO_X86}")
endif(GKLIB_NO_X86)

# Add various definitions.
if(GKLIB_GDB)
  set(GKlib_COPTS "${GKlib_COPTS} -g")
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -Werror")
else()
  set(GKlib_COPTS "-O3")
endif(GKLIB_GDB)


if(GKLIB_DEBUG)
  set(GKlib_COPTS "-g")
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DDEBUG")
endif(GKLIB_DEBUG)

if(GKLIB_GPROF)
  set(GKlib_COPTS "-pg")
endif(GKLIB_GPROF)

if(NOT GKLIB_ASSERT)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DNDEBUG")
endif(NOT GKLIB_ASSERT)

if(NOT GKLIB_ASSERT2)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DNDEBUG2")
endif(NOT GKLIB_ASSERT2)


# Add various options
if(GKLIB_PCRE)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -D__WITHPCRE__")
endif(GKLIB_PCRE)

if(GKLIB_GKREGEX)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DUSE_GKREGEX")
endif(GKLIB_GKREGEX)

if(GKLIB_GKRAND)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DUSE_GKRAND")
endif(GKLIB_GKRAND)


# Check for features.
check_include_file(execinfo.h HAVE_EXECINFO_H)
if(HAVE_EXECINFO_H)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DHAVE_EXECINFO_H")
endif(HAVE_EXECINFO_H)

check_function_exists(getline HAVE_GETLINE)
if(HAVE_GETLINE)
  set(GKlib_COPTIONS "${GKlib_COPTIONS} -DHAVE_GETLINE")
endif(HAVE_GETLINE)


# Custom check for TLS.
if(MSVC)
   set(GKlib_COPTIONS "${GKlib_COPTIONS} -D__thread=__declspec(thread)")

  # This if checks if that value is cached or not.
  if("${HAVE_THREADLOCALSTORAGE}" MATCHES "^${HAVE_THREADLOCALSTORAGE}$")
    try_compile(HAVE_THREADLOCALSTORAGE
      ${CMAKE_BINARY_DIR}
      ${GKLIB_PATH}/conf/check_thread_storage.c)
    if(HAVE_THREADLOCALSTORAGE)
      message(STATUS "checking for thread-local storage - found")
    else()
      message(STATUS "checking for thread-local storage - not found")
    endif()
  endif()
  if(NOT HAVE_THREADLOCALSTORAGE)
    set(GKlib_COPTIONS "${GKlib_COPTIONS} -D__thread=")
  endif()
endif()

# Finally set the official C flags.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${GKlib_COPTIONS} ${GKlib_COPTS}")

# Find GKlib sources.
file(GLOB GKlib_sources ${GKLIB_PATH}/src/*.c)
file(GLOB GKlib_includes ${GKLIB_PATH}/include/*.h)
