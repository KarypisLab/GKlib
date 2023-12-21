cmake_minimum_required(VERSION 3.14...3.28)

project(GKlib LANGUAGES C
VERSION 1.0.0
)

enable_testing()

option(BUILD_TESTING "Build tests" ON)

option(BUILD_SHARED_LIBS "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)" OFF)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT AND GKlib_IS_TOP_LEVEL)
  set(CMAKE_INSTALL_PREFIX "${PROJECT_BINARY_DIR}/local" CACHE PATH "install prefix" FORCE)
endif()

set(CMAKE_C_STANDARD 99)

message(STATUS "${PROJECT_NAME} ${PROJECT_VERSION} CMake ${CMAKE_VERSION} Arch: ${CMAKE_SYSTEM_PROCESSOR} install prefix: ${CMAKE_INSTALL_PREFIX}")

set(GKLIB_PATH ${PROJECT_SOURCE_DIR})

include(GKlibSystem.cmake)

set(win32_inc $<$<BOOL:${MSVC}>:${PROJECT_SOURCE_DIR}/win32>)
set(win32_sources $<$<BOOL:${MSVC}>:win32/adapt.c>)

set(GKlib_sources b64.c		evaluate.c	gkregex.c	mcore.c		seq.c
blas.c		fkvkselect.c	graph.c		memory.c	sort.c
cache.c		fs.c		htable.c	pqueue.c	string.c
csr.c		getopt.c	io.c		random.c	timers.c
error.c		gk_util.c	itemsets.c	rw.c		tokenizer.c)

add_library(GKlib ${GKlib_sources} ${win32_sources})
target_include_directories(GKlib PUBLIC
$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
$<INSTALL_INTERFACE:include>
)
target_link_libraries(GKlib PRIVATE
$<$<BOOL:${UNIX}>:m>
$<$<BOOL:${OPENMP}>:OpenMP::OpenMP_C>
)

add_library(GKlib::GKlib INTERFACE IMPORTED GLOBAL)
target_link_libraries(GKlib::GKlib INTERFACE GKlib)

if(BUILD_TESTING)
add_subdirectory(test)
endif()

install(TARGETS GKlib EXPORT ${PROJECT_NAME}-targets)

install(FILES GKlib.h TYPE INCLUDE)
# must have trailing slash or it makes a vestigial subdir
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/ TYPE INCLUDE
FILES_MATCHING PATTERN "gk_*.h")

include(cmake/install.cmake)
