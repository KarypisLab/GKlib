cmake_minimum_required(VERSION 3.10)

# ...
project(GKlib
  VERSION   0.0.1
  LANGUAGES C)

# include required CMake modules
include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckSymbolExists)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

#-------------------------------------------------------------------------------
# OPTIONS
#-------------------------------------------------------------------------------
# When the build options below are not set explicitly, derive their defaults
# from CMAKE_BUILD_TYPE so that a plain `cmake -DCMAKE_BUILD_TYPE=Debug` yields
# an unoptimized, assertion-enabled build instead of GKlib's forced -O3/NDEBUG.
# Explicitly-set options always win (option() leaves cached values untouched),
# so the `make config debug=set assert=set` workflow -- which sets DEBUG/ASSERT
# in the cache -- is unchanged. Like any option() default, this is applied only
# on the first configure of a build tree; changing CMAKE_BUILD_TYPE afterwards
# requires clearing the CMake cache.
string(TOUPPER "${CMAKE_BUILD_TYPE}" GKLIB_BUILD_TYPE)
if(GKLIB_BUILD_TYPE STREQUAL "DEBUG")
  set(GKLIB_DEFAULT_DEBUG  ON)
  set(GKLIB_DEFAULT_ASSERT ON)
else()
  set(GKLIB_DEFAULT_DEBUG  OFF)
  set(GKLIB_DEFAULT_ASSERT OFF)
endif()

option(ASSERT "turn asserts on" ${GKLIB_DEFAULT_ASSERT})
option(ASSERT2 "additional assertions" OFF)
option(DEBUG "add debugging support" ${GKLIB_DEFAULT_DEBUG})
option(GPROF "add gprof support" OFF)
option(GDB "add gdb support" OFF)
option(GKRAND "enable GKRAND support" OFF)
option(GKREGEX "enable GKREGEX support" OFF)
option(OPENMP "enable OpenMP support" OFF)
option(PCRE "enable PCRE support" OFF)
option(VALGRID "enable valgrind support" OFF)
option(NO_X86 "enable no-x86 support" OFF)
option(SHARED "enable shared support" OFF)

if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  option(GKLIB_BUILD_APPS "build the GKlib applications" ON)
else()
  option(GKLIB_BUILD_APPS "build the GKlib applications" OFF)
endif()

# Configure libmetis library.
if(SHARED)
  set(GKLIB_LIBRARY_TYPE SHARED)
else()
  set(GKLIB_LIBRARY_TYPE STATIC)
endif(SHARED)

#-------------------------------------------------------------------------------
# LIBRARY configuration
#-------------------------------------------------------------------------------
add_library(${PROJECT_NAME} ${GKLIB_LIBRARY_TYPE})

target_sources(${PROJECT_NAME}
  PRIVATE src/b64.c src/blas.c src/cache.c src/csr.c src/error.c src/evaluate.c
          src/fkvkselect.c src/fs.c src/getopt.c src/gk_util.c src/gkregex.c
          src/graph.c src/htable.c src/io.c src/itemsets.c src/mcore.c
          src/memory.c src/pqueue.c src/random.c src/rw.c src/seq.c src/sort.c
          src/string.c src/timers.c src/tokenizer.c
          # these are only included below so that they appear when using IDEs
          include/GKlib.h include/gk_arch.h include/gk_defs.h
          include/gk_externs.h include/gk_getopt.h include/gk_macros.h 
          include/gk_mkblas.h include/gk_mkmemory.h include/gk_mkpqueue.h
          include/gk_mkpqueue2.h include/gk_mkrandom.h include/gk_mksort.h 
          include/gk_mkutils.h include/gk_proto.h include/gk_struct.h
          include/gk_types.h include/gkregex.h include/gk_ms_inttypes.h 
          include/gk_ms_stat.h include/gk_ms_stdint.h)

target_compile_definitions(${PROJECT_NAME}
  PUBLIC $<$<PLATFORM_ID:Linux>:LINUX>
         $<$<PLATFORM_ID:Linux>:_POSIX_C_SOURCE=200809L>)

target_include_directories(${PROJECT_NAME}
  PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include>)

target_link_libraries(${PROJECT_NAME}
  PUBLIC $<$<NOT:$<BOOL:${WIN32}>>:m>)

set_target_properties(${PROJECT_NAME} PROPERTIES
  POSITION_INDEPENDENT_CODE ON
  SOVERSION ${PROJECT_VERSION_MAJOR}
  VERSION   ${PROJECT_VERSION})

add_library(GKlib::GKlib ALIAS ${PROJECT_NAME})

#-------------------------------------------------------------------------------
# OPTIONS configuration
#-------------------------------------------------------------------------------
target_compile_definitions(${PROJECT_NAME}
  PUBLIC $<$<NOT:$<BOOL:${ASSERT}>>:NDEBUG>
         $<$<NOT:$<BOOL:${ASSERT2}>>:NDEBUG2>
         $<$<BOOL:${DEBUG}>:DEBUG>
         $<$<BOOL:${GKRAND}>:USE_GKRAND>
         $<$<BOOL:${NO_X86}>:NO_X86>
         )

#-------------------------------------------------------------------------------
# FEATURE AVAILABILITY checks
#-------------------------------------------------------------------------------
check_include_file(execinfo.h HAVE_EXECINFO_H)
# backtrace()/backtrace_symbols() are in libc on glibc and macOS, but in a
# separate libexecinfo on FreeBSD, NetBSD, and musl-based systems. The header
# alone is not enough to link, so confirm the symbols are linkable and record
# the extra library when one is required; otherwise disable the feature rather
# than emit code that compiles but fails to link.
set(EXECINFO_LIBRARY "")
if(HAVE_EXECINFO_H)
  check_symbol_exists(backtrace execinfo.h GKLIB_BACKTRACE_IN_LIBC)
  if(NOT GKLIB_BACKTRACE_IN_LIBC)
    set(CMAKE_REQUIRED_LIBRARIES execinfo)
    check_symbol_exists(backtrace execinfo.h GKLIB_BACKTRACE_IN_LIBEXECINFO)
    unset(CMAKE_REQUIRED_LIBRARIES)
    if(GKLIB_BACKTRACE_IN_LIBEXECINFO)
      set(EXECINFO_LIBRARY execinfo)
    else()
      set(HAVE_EXECINFO_H FALSE)
    endif()
  endif()
endif()
check_function_exists(getline HAVE_GETLINE)

# regular expressions
if(PCRE)
  check_include_file(pcreposix.h HAVE_PCREPOSIX_H)
  if(NOT HAVE_PCREPOSIX_H)
    message(WARNING "PCRE was requested, but is not available")
  endif()
endif()
if(NOT HAVE_PCREPOSIX_H)
  check_include_file(regex.h HAVE_REGEX_H)
  if(NOT HAVE_REGEX_H)
    set(USE_GKREGEX ON)
  endif()
endif()

# profiling support
if(GPROF)
  check_c_compiler_flag("-pg" HAVE_GPROF_SUPPORT)
  if(NOT HAVE_GPROF_SUPPORT)
    message(WARNING "GPROF support was requested, but is not available")
  endif()
endif()

# debug symbol support
if(GDB OR DEBUG)
  check_c_compiler_flag("-g" HAVE_GDB_SUPPORT)
  if(NOT HAVE_GDB_SUPPORT)
    message(WARNING "GDB support was requested, but is not available")
  endif()
endif()

# openmp support
if(OPENMP)
  find_package(OpenMP)
  if(NOT OpenMP_C_FOUND)
    message(WARNING "OpenMP was requested, but is not available")
  endif()
endif()

# thread local storage
if(NOT DEFINED HAVE_TLS)
  set(TLS_NAME "" CACHE INTERNAL "Thread local keyword")
  foreach(tls_name "__thread" "__declspec(thread)")
    unset(HAVE_TLS CACHE)
    check_c_source_compiles("${tls_name} int x; int main(void) { return 0; }"
      HAVE_TLS)
    if (HAVE_TLS)
      set(TLS_NAME ${tls_name} CACHE INTERNAL "Thread local keyword")
      break()
    else()
    endif()
  endforeach()
endif()

target_compile_definitions(${PROJECT_NAME}
  PUBLIC $<$<BOOL:${HAVE_EXECINFO_H}>:HAVE_EXECINFO_H>
         $<$<BOOL:${PCRE}>:USE_PCRE>
         $<$<AND:$<BOOL:${PCRE}>,$<BOOL:${HAVE_PCREPOSIX_H}>>:HAVE_PCREPOSIX_H>
         $<$<BOOL:${HAVE_REGEX_H}>:HAVE_REGEX_H>
         $<$<BOOL:${USE_GKREGEX}>:USE_GKREGEX>
         $<$<BOOL:${HAVE_GETLINE}>:HAVE_GETLINE>
         __thread=${TLS_NAME})

target_compile_options(${PROJECT_NAME}
  PUBLIC $<$<AND:$<BOOL:${GPROF}>,$<BOOL:${HAVE_GPROF_SUPPORT}>>:-pg>)

target_compile_options(${PROJECT_NAME}
  PUBLIC $<$<AND:$<OR:$<BOOL:${DEBUG}>,$<BOOL:${GDB}>>,$<BOOL:${HAVE_GDB_SUPPORT}>>:-g>)

target_compile_options(${PROJECT_NAME}
  PUBLIC $<$<NOT:$<OR:$<BOOL:${DEBUG}>,$<BOOL:${GDB}>>>:-O3>)

target_link_libraries(${PROJECT_NAME}
  PUBLIC $<$<BOOL:${OpenMP_C_FOUND}>:OpenMP::OpenMP_C>
         ${EXECINFO_LIBRARY})

#-------------------------------------------------------------------------------
# APPS configuration
#-------------------------------------------------------------------------------
if(GKLIB_BUILD_APPS)
  add_subdirectory("apps")
endif()

#-------------------------------------------------------------------------------
# PACKAGE configuration
#-------------------------------------------------------------------------------
# generate files
configure_package_config_file(GKlibConfig.cmake.in cmake/GKlibConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GKlib)

write_basic_package_version_file(cmake/GKlibConfigVersion.cmake
  VERSION       ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)

# install library
install(TARGETS ${PROJECT_NAME} EXPORT GKlibTargets
  RUNTIME  DESTINATION   ${CMAKE_INSTALL_BINDIR}
           COMPONENT     GKlib_Runtime
  LIBRARY  DESTINATION   ${CMAKE_INSTALL_LIBDIR}
           COMPONENT     GKlib_Runtime
           NAMELINK_SKIP
  ARCHIVE  DESTINATION   ${CMAKE_INSTALL_LIBDIR}
           COMPONENT     GKlib_Development
  INCLUDES DESTINATION   ${CMAKE_INSTALL_INCLUDEDIR})

# The previous install() command is repeated here to distinguish installations
# that include a namelink versus those that do not. Unfortunately, prior to
# CMake 3.12, when the NAMELINK_COMPONENT property was introduced, this was
# necessary to get the desired behavior.
if(SHARED)
  install(TARGETS ${PROJECT_NAME}
    LIBRARY  DESTINATION   ${CMAKE_INSTALL_LIBDIR}
             COMPONENT     GKlib_Development
             NAMELINK_ONLY)
endif()

# install header files
install(DIRECTORY "${CMAKE_SOURCE_DIR}/include/"
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
  COMPONENT   GKlib_Development)

# install files necessary to use find_package() with GKlib
install(EXPORT GKlibTargets
  FILE        GKlibTargets.cmake
  NAMESPACE   GKlib::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GKlib
  COMPONENT   GKlib_Development)

install(
  FILES       ${CMAKE_CURRENT_BINARY_DIR}/cmake/GKlibConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/cmake/GKlibConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GKlib
  COMPONENT   GKlib_Development)
