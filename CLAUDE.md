# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is GKlib

GKlib is a C utility library providing data structures, sorting, memory management, I/O, string operations, and numerical routines. It is used as a foundation by METIS and other software from the Karypis Lab. Licensed under Apache 2.0.

## Build Commands

```bash
make config                    # Configure (creates build/$(uname -s)-$(uname -m)/)
make                           # Build
make install                   # Install to ~/local/{lib,include,bin}
make clean                     # Remove object files, keep config
make distclean                 # Full clean including build directory
make config prefix=/path cc=clang  # Custom prefix and compiler
make config debug=set assert=set   # Debug build with assertions
```

Requires CMake 3.10+ and GNU make. The Makefile wraps CMake.

Key config flags: `openmp=set`, `shared=set`, `gdb=set`, `gprof=set`, `valgrind=set`, `pcre=set`, `assert=set`, `assert2=set`.

There is no test suite in this repository.

## Architecture

### Code Generation via Macros

GKlib uses C preprocessor macros extensively for type-generic programming (C's alternative to templates). The `include/gk_mk*.h` headers define macro "generators" that are instantiated for multiple data types:

| Header | Macro | Generates |
|---|---|---|
| `gk_mkblas.h` | `GK_MKBLAS` | BLAS-like ops (max, min, argmax, argmin, set, sum, scale, norm2, dot, axpy) |
| `gk_mkmemory.h` | `GK_MKALLOC` | Type-specific malloc, realloc, smalloc, set |
| `gk_mksort.h` | `GK_MKSORT` | Inline quicksort with custom comparators |
| `gk_mkpqueue.h` | `GK_MKPQUEUE` | Priority queue (Create, Insert, Delete, GetTop, SeeTop, etc.) |
| `gk_mkpqueue2.h` | `GK_MKPQUEUE2` | Priority queue variant with separate key/value arrays |
| `gk_mkrandom.h` | `GK_MKRANDOM` | Type-specific random operations |
| `gk_mkutils.h` | `GK_MKUTILS` | Utility operations per type |

Instantiations happen in `src/` files (e.g., `src/sort.c`, `src/blas.c`, `src/memory.c`) and in `include/gk_proto.h` for prototypes.

### Naming Conventions

- **All public symbols** use `gk_` prefix
- **Type abbreviations** in function names: `c` (char), `i` (int32), `i8/i16/i32/i64`, `z` (ssize_t), `zu` (size_t), `f` (float), `d` (double), `idx` (gk_idx_t)
- **Generated functions** follow pattern: `gk_<type><op>` (e.g., `gk_fmax`, `gk_iargmin`, `gk_dscale`)
- **Struct lifecycle**: `gk_<struct>_Create`, `gk_<struct>_Init`, `gk_<struct>_Free`, `gk_<struct>_Destroy`
- **Key-value types**: `gk_<type>kv_t` (e.g., `gk_ikv_t`, `gk_fkv_t`)
- **Types**: `gk_<name>_t` (e.g., `gk_csr_t`, `gk_graph_t`, `gk_idx_t`)

### Key Data Structures

- **`gk_csr_t`** (`src/csr.c`, ~3K lines) — Compressed Sparse Row matrix with extensive operations (read, write, normalize, transform, similarity, submatrix extraction)
- **`gk_graph_t`** (`src/graph.c`) — Graph representation with adjacency structure, vertex/edge weights
- **Key-value pairs** — 12 typed variants generated via `GK_MKKEYVALUE_T` in `gk_struct.h`
- **Priority queues** — 6 typed variants generated via `GK_MKPQUEUE`

### Header Organization

`include/GKlib.h` is the single umbrella header. It includes, in order:
1. `gk_arch.h` — Platform detection and system headers
2. `gk_types.h` — Typedefs (`gk_idx_t`, `gk_real_t`, etc.)
3. `gk_struct.h` — Structure definitions
4. `gk_externs.h` — External variable declarations
5. `gk_defs.h` — Constants and enums (CSR operations, file formats, etc.)
6. `gk_macros.h` — Utility macros (min/max, timers, assertions, CSR helpers)
7. `gk_getopt.h` — Command-line parsing
8. `gk_mk*.h` — Code generation macro headers
9. `gk_proto.h` — All function prototypes

### Assertions

- `ASSERT(expr)` / `ASSERTP(expr, msg)` — disabled when `NDEBUG` defined (default unless `assert=set`)
- `ASSERT2(expr)` — disabled when `NDEBUG2` defined (default unless `assert2=set`)
- `GKASSERT(expr)` — always-on, calls `abort()`

### Error Handling

Uses `setjmp`/`longjmp` for error recovery with thread-local jump buffers (`gk_jbufs`, `gk_cur_jbufs`). The `gk_sigcatch()` macro sets the jump point.

### Thread Safety

Thread-local storage via `__thread` (detected at CMake configure time, falls back to `__declspec(thread)` on MSVC). Used for error handling state and memory tracking.

### Platform Support

Linux, macOS, Windows (MSVC/MinGW), Cygwin. Compiler support: GCC, Clang, MSVC, Intel ICC. Default compiler flags include `-Wall -pedantic -Werror`.

## When Used as a Subproject

When included via CMake `add_subdirectory()`, apps are not built (`GKLIB_BUILD_APPS` defaults to OFF). The library exports as `GKlib::GKlib` for `target_link_libraries`.
