# Build programs.
set(GKLIB_PROGRAMS strings gksort fis gkrw gkgraph csrcnv grKx m2mnbrs cmpnbrs
                   splatt2svd gkuniq)

foreach(prog ${GKLIB_PROGRAMS})
  add_executable(${prog} ${prog}.c)
  target_link_libraries(${prog} GKlib::GKlib)
  set_target_properties(${prog} PROPERTIES
    C_STANDARD 11
    C_STANDARD_REQUIRED ON)
endforeach()

# install executables
install(TARGETS csrcnv
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
          COMPONENT   GKlib_Applications)
