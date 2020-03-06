# Where the header files reside
#include_directories(../)

# Build program.
add_executable(strings strings.c)
add_executable(gksort gksort.c)
add_executable(fis fis.c)
add_executable(gkrw rw.c)
add_executable(gkgraph gkgraph.c)
add_executable(csrcnv csrcnv.c)
add_executable(grKx grKx.c)
add_executable(m2mnbrs m2mnbrs.c)
add_executable(cmpnbrs cmpnbrs.c)
add_executable(splatt2svd splatt2svd.c)
foreach(prog strings gksort fis gkrw gkgraph csrcnv grKx m2mnbrs cmpnbrs splatt2svd)
  target_link_libraries(${prog} GKlib)
endforeach(prog)

# Install
install(TARGETS fis csrcnv m2mnbrs gkrw cmpnbrs gkgraph RUNTIME DESTINATION bin)
