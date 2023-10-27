cmake_minimum_required(VERSION 3.15)

project(m2mnbrs
		LANGUAGES C
)

include(FetchContent)
FetchContent_Declare(GKlib
		GIT_REPOSITORY https://github.com/KarypisLab/GKlib
		GIT_TAG master
		FIND_PACKAGE_ARGS CONFIG
)
FetchContent_MakeAvailable(GKlib)

add_executable(m2mnbrs m2mnbrs.c)
target_link_libraries(m2mnbrs PRIVATE GKlib::GKlib)

# TODO: Add ctest calling for each internal project
enable_testing()
