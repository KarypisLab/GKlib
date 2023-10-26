cmake_minimum_required(VERSION 3.15)

#[==============================================================================================[
#                                   Basic project definition                                   #
]==============================================================================================]

list(APPEND CMAKE_MESSAGE_CONTEXT GKlib)
project(GKlib
		VERSION 5.3.0
		DESCRIPTION "A library of various helper routines and frameworks used by many of the KarypisLab's software"
		HOMEPAGE_URL https://github.com/KarypisLab/GKlib
		LANGUAGES C
)

# Back-porting to PROJECT_IS_TOP_LEVEL to older cmake
# TODO: Remove when requiring cmake >= 3.21
if (NOT DEFINED Spglib_IS_TOP_LEVEL)
	if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
		set(PROJECT_IS_TOP_LEVEL ON)
	else ()
		set(PROJECT_IS_TOP_LEVEL OFF)
	endif ()
endif ()

# Specify C standard
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS ON)

if (NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE Release)
endif ()

#[==============================================================================================[
#                                            Options                                            #
]==============================================================================================]

set(GKLIB_NAME "GKlib" CACHE INTERNAL "")
option(GKLIB_BUILD_SHARED_LIBS "Build shared libraries (.dll/.so) instead of static ones (.lib/.a)" OFF)
option(GKLIB_BUILD_TEST "Build test projects" ON)

#[==============================================================================================[
#                                     Project configuration                                     #
]==============================================================================================]


get_filename_component(abs "." ABSOLUTE)
set(GKLIB_PATH ${abs})
unset(abs)
include(GKlibSystem.cmake)

#[==============================================================================================[
#                                       External packages                                       #
]==============================================================================================]

#[==============================================================================================[
#                                        Main definition                                        #
]==============================================================================================]

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
if(MSVC)
  include_directories("win32")
  file(GLOB win32_sources "include/win32/*.h" "src/win32/*.c")
else(MSVC)
  set(win32_sources, "")
endif(MSVC)

if(GKLIB_BUILD_SHARED_LIBS)
	add_library(${GKLIB_NAME} SHARED ${GKlib_includes} ${GKlib_sources} ${win32_sources})
else()
	add_library(${GKLIB_NAME} STATIC ${GKlib_includes} ${GKlib_sources} ${win32_sources})
endif()

if(UNIX)
  target_link_libraries(GKlib m)
endif(UNIX)

if(${GKLIB_BUILD_TEST})
	include_directories("test")
	add_subdirectory("test")
endif()

#[==============================================================================================[
#                                       Install or Export                                       #
]==============================================================================================]

install(TARGETS GKlib
  ARCHIVE DESTINATION lib/${LINSTALL_PATH}
  LIBRARY DESTINATION lib/${LINSTALL_PATH})
install(FILES ${GKlib_includes} DESTINATION include/${HINSTALL_PATH})
