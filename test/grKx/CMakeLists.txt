cmake_minimum_required(VERSION 3.15)

project(grKx
		LANGUAGES C
)

include(FetchContent)
FetchContent_Declare(GKlib
		GIT_REPOSITORY https://github.com/KarypisLab/GKlib
		GIT_TAG master
		FIND_PACKAGE_ARGS CONFIG
)
FetchContent_MakeAvailable(GKlib)

add_executable(grKx grKx.c)
target_link_libraries(grKx PRIVATE GKlib::GKlib)

# TODO: Add ctest calling for each internal project
enable_testing()
