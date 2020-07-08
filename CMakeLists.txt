cmake_minimum_required(VERSION 2.8)
project(GKlib C)

get_filename_component(abs "." ABSOLUTE)
set(GKLIB_PATH ${abs})
unset(abs)
include(GKlibSystem.cmake)

include_directories(".")
if(MSVC)
  include_directories("win32")
  file(GLOB win32_sources RELATIVE "win32" "*.c")
  add_library(GKlib STATIC ${GKlib_sources} ${win32_sources})
else(MSVC)
  add_library(GKlib STATIC ${GKlib_sources})
endif(MSVC)
if(UNIX)
  target_link_libraries(GKlib m)
endif(UNIX)

include_directories("test")
add_subdirectory("test")

install(TARGETS GKlib
  ARCHIVE DESTINATION lib/${LINSTALL_PATH}
  LIBRARY DESTINATION lib/${LINSTALL_PATH})
install(FILES ${GKlib_includes} DESTINATION include/${HINSTALL_PATH})
