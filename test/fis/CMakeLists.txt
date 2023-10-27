cmake_minimum_required(VERSION 3.15)

project(fis
		LANGUAGES C
)

include(FetchContent)
FetchContent_Declare(GKlib
		GIT_REPOSITORY https://github.com/KarypisLab/GKlib
		GIT_TAG master
		FIND_PACKAGE_ARGS CONFIG
)
FetchContent_MakeAvailable(GKlib)

add_executable(fis fis.c)
target_link_libraries(fis PRIVATE GKlib::GKlib)

# TODO: Add ctest calling for each internal project
enable_testing()
