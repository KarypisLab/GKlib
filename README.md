# GKlib
A library of various helper routines and frameworks used by many of the lab's
software

## Build requirements
 - CMake 3.1, found at http://www.cmake.org/, as well as GNU make or some other
   build system supported by CMake.

Assuming that the above are available, the following sequence of commands should
suffice to build the software on a Unix-like system:
```
mkdir build && cd build
cmake ..
cmake --build .
```

## Configuring the build
The build is primarily configured by passing options to CMake or setting
environment variables prior to invoking CMake. For example:
```
CC=icc cmake ..
```

would configure it to be built using icc. While

```
cmake -DOPENMP=ON -DCMAKE_BUILD_TYPE=Release ..
```

would configure it to be build using the default compiler, with OpenMP if
available, and in release mode (aggressive optimizations enabled).

To see a list of options that can be set using the `-D...` syntax, run

```
cmake -L .
```

from the build directory. To see relevant environment variables, visit
https://cmake.org/cmake/help/latest/manual/cmake-env-variables.7.html.

## Customizing the build
In addition to the standard CMake configurations, there is also the CMake
variable, `CMAKE_PROJECT_GKlib_INCLUDE`. When this variable is defined, it
should give the path to a CMake script where compiler options and the like can
be specified. This allows the user of the build system to have a file where
common CMake settings can be managed without modifying the core CMake logic. For
example, CMake could be configured using the script, `GKlibSystem.cmake`
provided in the `cmake` directory like so:

```
-DCMAKE_PROJECT_GKlib_INCLUDE=cmake/GKlibSystem.cmake
```

The path to the file should be relative to the directory containing the
top-level `CMakeLists.txt` file.

## Installing
Installing will depend on the generator used by CMake. For builds using the
Makefile generator, the following command will suffice:
```
make install
```

By default, the library file, header files, and some useful applications will be
installed in standard GNU install directories. This too however can be
configured via options. For example:
```
cmake -DCMAKE_INSTALL_PREFIX=~/local ..
```

during configuration will install said files to the following directories
respectively:

```
~/local/lib
~/local/include/GKlib
```
