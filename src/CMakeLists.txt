target_sources(GKlib_GKlib PRIVATE
		b64.c
		blas.c
		cache.c
		CMakeLists.txt
		csr.c
		error.c
		evaluate.c
		fkvkselect.c
		fs.c
		getopt.c
		gk_util.c
		gkregex.c
		graph.c
		htable.c
		io.c
		itemsets.c
		mcore.c
		memory.c
		pqueue.c
		random.c
		rw.c
		seq.c
		sort.c
		string.c
		timers.c
		tokenizer.c
)

include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckIncludeFile)
check_include_file(execinfo.h HAVE_EXECINFO_H)
check_symbol_exists(getline stdio.h HAVE_GETLINE)

target_compile_definitions(GKlib_GKlib PUBLIC
		# TODO: Use PCRE2 instead
		# TODO: Missing link library to pcre anyway
		$<$<BOOL:${GKLIB_PCRE}>:__WITHPCRE__>
		$<$<BOOL:${GKLIB_GKREGEX}>:USE_GKREGEX>
		$<$<BOOL:${GKLIB_GKRAND}>:USE_GKRAND>
		PRIVATE
		$<$<BOOL:${HAVE_EXECINFO_H}>:HAVE_EXECINFO_H>
		$<$<BOOL:${HAVE_GETLINE}>:HAVE_GETLINE>
		# TODO: Remove as non-standard
		$<$<NOT:$<BOOL:${GKLIB_NO_X86}>>:NO_X86>
		$<$<BOOL:${GKLIB_ASSERT}>:NDEBUG>
		$<$<BOOL:${GKLIB_ASSERT2}>:NDEBUG2>
)
target_compile_options(GKlib_GKlib PRIVATE
		$<$<BOOL:${GKLIB_GPROF}>:-pg>
)

check_function_exists(getline HAVE_GETLINE)
if (HAVE_GETLINE)
	set(GKlib_COPTIONS "${GKlib_COPTIONS} -DHAVE_GETLINE")
endif (HAVE_GETLINE)

if (WIN32)
	add_subdirectory(win32)
endif ()
find_library(MATH_LIBRARY m)
if (MATH_LIBRARY)
	target_link_libraries(GKlib_GKlib PUBLIC ${MATH_LIBRARY})
endif ()
if (GKLIB_OpenMP)
	target_link_libraries(GKlib_GKlib PUBLIC OpenMP::OpenMP_C)
endif ()

# Install
if (GKLIB_INSTALL)
	install(TARGETS GKlib_GKlib
			EXPORT GKlibTargets
			LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT GKlib_Runtime NAMELINK_COMPONENT GKlib_Development
			ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT GKlib_Development
			PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT GKlib_Development
			RUNTIME DESTINATION ${CMAKE_INSTALL_RUNTIMEDIR} COMPONENT GKlib_Runtime
	)
endif ()
