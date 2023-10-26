target_include_directories(GKlib_GKlib PUBLIC
		"$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
		"$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
# TODO: These headers should be moved to a folder structure
set(public_header_files
		gk_arch.h
		gk_defs.h
		gk_externs.h
		gk_getopt.h
		gk_macros.h
		gk_mkblas.h
		gk_mkmemory.h
		gk_mkpqueue.h
		gk_mkpqueue2.h
		gk_mkrandom.h
		gk_mksort.h
		gk_mkutils.h
		gk_ms_inttypes.h
		gk_ms_stat.h
		gk_ms_stdint.h
		gk_proto.h
		gk_struct.h
		gk_types.h
		GKlib.h
		gkregex.h
)
if (WIN32)
	# TODO: This does not work because it would strip the path. Need to move to FILE_SET
#	list(APPEND public_header_files
#			win32/adapt.h
#	)
	if (GKLIB_INSTALL)
		install(FILES win32/adapt.h ${CMAKE_INSTALL_INCLUDEDIR}/win32)
	endif ()
endif ()
# Prepend ${CMAKE_CURRENT_SOURCE_DIR} to all the header paths to be use in `PUBLIC_HEADER` property
set(public_headers)
foreach (header IN LISTS public_header_files)
	list(APPEND public_headers ${CMAKE_CURRENT_SOURCE_DIR}/${header})
endforeach ()

set_target_properties(GKlib_GKlib PROPERTIES
		# TODO: Move to FILE_SET to properly install with paths
		PUBLIC_HEADER "${public_headers}"
)
