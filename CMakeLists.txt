cmake_minimum_required(VERSION 2.8)

#[==============================================================================================[
#                                   Basic project definition                                   #
]==============================================================================================]

project(GKlib C)

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
