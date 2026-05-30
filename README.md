# GKlib
A library of various helper routines and frameworks used by many of the lab's 
software

## Build requirements
 - CMake 3.10, found at http://www.cmake.org/, as well as GNU make. 

Assuming that the above are available, two commands should suffice to 
build the software:
```
make config 
make
```

## Configuring the build
It is primarily configured by passing options to make config. For example:
```
make config cc=icc
```

would configure it to be built using icc.

Configuration options are:
```
cc=[compiler]     - The C compiler to use [default: gcc]
prefix=[PATH]     - Set the installation prefix [default: ~/local]
openmp=set        - To build a version with OpenMP support
```


## Building and installing
To build and install, run the following
```
make
make install
```

By default, the library file, header file, and binaries will be installed in
```
~/local/lib
~/local/include
~/local/bin
```

## Building on Windows

The `make` targets are a thin convenience wrapper that relies on Unix shell
tools (`uname`, `rm`, `mkdir -p`, ...), so `make config` does not work from a
native Windows command prompt. On native Windows, invoke CMake directly:
```
cmake -B build -S .
cmake --build build --config Release
cmake --install build
```

The configuration options above map to CMake `-D` flags, for example
`-DOPENMP=ON`, `-DSHARED=ON`, or `-DCMAKE_INSTALL_PREFIX=<path>`. Under MSYS2,
Cygwin, or WSL the `make` wrapper works the same as on Unix.

## Other make commands
    make uninstall 
         Removes all files installed by 'make install'.
   
    make clean 
         Removes all object files but retains the configuration options.
   
    make distclean 
         Performs clean and completely removes the build directory.

## License

GKlib is licensed under the Apache License, Version 2.0 (see `LICENSE.txt`).
It also bundles a few files derived from third parties that retain their
original licenses, so the effective license of the combined work is
`Apache-2.0 AND LGPL-2.1-or-later AND BSD-3-Clause`. See `LICENSES.md` for the
per-file inventory and the `LICENSES/` directory for the full license texts.


