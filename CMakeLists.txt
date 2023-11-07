cmake_minimum_required(VERSION 3.15)
# CMake version compatibility
# TODO: Remove when cmake 3.25 is commonly distributed
if (POLICY CMP0140)
	cmake_policy(SET CMP0140 NEW)
endif ()

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

include(CMakeDependentOption)
include(FeatureSummary)
option(GKLIB_TESTS "GKlib: Build unit tests" ${PROJECT_IS_TOP_LEVEL})
option(GKLIB_SHARED_LIBS "GKlib: Build as a shared library" ${PROJECT_IS_TOP_LEVEL})
option(GKLIB_INSTALL "GKlib: Install project" ${PROJECT_IS_TOP_LEVEL})

# TODO: Discuss these options. Non-standard and easily conflicting
option(GKLIB_ASSERT "GKlib: Turn asserts on" OFF)
option(GKLIB_ASSERT2 "GKlib: Additional assertions" OFF)
option(GKLIB_NO_X86 "GKlib: Enable NO_X86 support" ON)
option(GKLIB_GPROF "GKlib: Add gprof support" OFF)

option(GKLIB_OpenMP "GKlib: Enable OpenMP support" OFF)
add_feature_info(GKLIB_OpenMP GKLIB_OpenMP "OpenMP support")
option(GKLIB_PCRE "GKlib: Enable PCRE support" OFF)
add_feature_info(GKLIB_PCRE GKLIB_PCRE "PCRE support")
cmake_dependent_option(GKLIB_GKREGEX "GKlib: Enable GKREGEX support" OFF "NOT GKLIB_PCRE" OFF)
add_feature_info(GKLIB_GKREGEX GKLIB_GKREGEX "GKREGEX support")
option(GKLIB_GKRAND "GKlib: Enable GKRAND support" OFF)
add_feature_info(GKLIB_GKRAND GKLIB_GKRAND "GKRAND support")

#[==============================================================================================[
#                                     Project configuration                                     #
]==============================================================================================]

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# Include basic tools
include(FetchContent)
if (GKLIB_INSTALL)
	include(CMakePackageConfigHelpers)
	if (UNIX)
		include(GNUInstallDirs)
	endif ()
endif ()

# Define basic parameters
set(BUILD_SHARED_LIBS ${GKLIB_SHARED_LIBS})

#[==============================================================================================[
#                                       External packages                                       #
]==============================================================================================]

if (GKLIB_OpenMP)
	# Normally these packages are pulled outside of if statements to allow to be added optionally.
	# Making an exception for basic packages like OpenMP, MPI, etc. that drastically change a
	# library's implementation and expected behaviour
	find_package(OpenMP COMPONENTS C)
	set_package_properties(OpenMP PROPERTIES TYPE REQUIRED)
endif ()
if (GKLIB_PCRE)
	# TODO: This option should be obsolete and moved to optional find_package control
	# TODO: Move to PCRE2, since PCRE1 is dead
#	find_package(pcre2 COMPONENTS POSIX)
#	set_package_properties(pcre2 PROPERTIES TYPE REQUIRED)
endif ()
include(GKlib_PackagesInfo)

feature_summary(
		FILENAME ${CMAKE_CURRENT_BINARY_DIR}/GKlib.info
		VAR GKlib_Info
		DESCRIPTION "GKlib supported libraries"
		FATAL_ON_MISSING_REQUIRED_PACKAGES
		WHAT ALL
)
message(STATUS ${GKlib_Info})

#[==============================================================================================[
#                                        Main definition                                        #
]==============================================================================================]

# Main project
add_library(GKlib_GKlib)
set_target_properties(GKlib_GKlib PROPERTIES
		VERSION ${PROJECT_VERSION}
		SOVERSION ${PROJECT_VERSION_MAJOR}
		EXPORT_NAME GKlib
		OUTPUT_NAME gk
)
add_library(GKlib::GKlib ALIAS GKlib_GKlib)
add_subdirectory(include)
add_subdirectory(src)


if (GKLIB_TESTS)
	enable_testing()
	add_subdirectory(test)
endif ()

#[==============================================================================================[
#                                       Install or Export                                       #
]==============================================================================================]

# Installation
if (GKLIB_INSTALL)
	# pkg-config files
	# TODO: Figure how to make this work
#	file(GENERATE OUTPUT gklib.pc
#			INPUT cmake/gklib.pc.in
#	)
#	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/gklib.pc
#			DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
#			COMPONENT GKlib_Development
#	)

	# cmake export files
	write_basic_package_version_file(
			${CMAKE_CURRENT_BINARY_DIR}/GKlibConfigVersion.cmake
			VERSION ${PROJECT_VERSION}
			COMPATIBILITY SameMajorVersion
	)
	configure_package_config_file(
			cmake/GKlibConfig.cmake.in
			${CMAKE_CURRENT_BINARY_DIR}/GKlibConfig.cmake
			INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GKlib
	)
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/GKlibConfigVersion.cmake
			${CMAKE_CURRENT_BINARY_DIR}/GKlibConfig.cmake
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GKlib
			COMPONENT GKlib_Development
	)
	export(EXPORT GKlibTargets
			FILE GKlibTargets.cmake
			NAMESPACE GKlib::
	)
	install(EXPORT GKlibTargets
			FILE GKlibTargets.cmake
			NAMESPACE GKlib::
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/GKlib
			COMPONENT GKlib_Development
	)
endif ()

# Make project available for FetchContent
if (NOT PROJECT_IS_TOP_LEVEL)
	# Set variables for FetchContent
	# All variables have to be consistent with GKlibConfig.cmake
	set(GKlib_OpenMP GKLIB_OpenMP)
	set(GKlib_PCRE GKLIB_PCRE)
	set(GKlib_GKREGEX GKLIB_GKREGEX)
	set(GKlib_GKRAND GKLIB_GKRAND)
	# Propagate variables
	if (CMAKE_VERSION VERSION_LESS 3.25)
		# TODO: Remove when cmake 3.25 is commonly distributed
		set(GKlib_VERSION ${GKlib_VERSION} PARENT_SCOPE)
		set(GKlib_VERSION_MAJOR ${GKlib_VERSION_MAJOR} PARENT_SCOPE)
		set(GKlib_VERSION_MINOR ${GKlib_VERSION_MINOR} PARENT_SCOPE)
		set(GKlib_VERSION_PATCH ${GKlib_VERSION_PATCH} PARENT_SCOPE)
		set(GKlib_VERSION_TWEAK ${GKlib_VERSION_TWEAK} PARENT_SCOPE)
		set(GKlib_OpenMP ${GKlib_OpenMP} PARENT_SCOPE)
		set(GKlib_PCRE ${GKlib_PCRE} PARENT_SCOPE)
		set(GKlib_GKREGEX ${GKlib_GKREGEX} PARENT_SCOPE)
		set(GKlib_GKRAND ${GKlib_GKRAND} PARENT_SCOPE)
	else ()
		return(PROPAGATE
				GKlib_VERSION
				GKlib_VERSION_MAJOR
				GKlib_VERSION_MINOR
				GKlib_VERSION_PATCH
				GKlib_VERSION_TWEAK
				GKlib_OpenMP
				GKlib_PCRE
				GKlib_GKREGEX
				GKlib_GKRAND
		)
	endif ()
endif ()
