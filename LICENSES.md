# GKlib licensing

GKlib as a whole is distributed under the **Apache License, Version 2.0** (see
[`LICENSE.txt`](LICENSE.txt)). However, the source tree also bundles a small
number of files derived from third parties that are kept under their original
licenses. The effective license of the combined work is therefore:

```
Apache-2.0 AND LGPL-2.1-or-later AND BSD-3-Clause
```

This file inventories the non–Apache-2.0 components so that downstream packagers
can record the correct license metadata. The full text of each non–Apache-2.0
license is in the [`LICENSES/`](LICENSES/) directory.

## Apache-2.0 (default)

All files not listed below are original GKlib code, copyright the Regents of the
University of Minnesota, licensed under Apache-2.0.

## LGPL-2.1-or-later (GNU C Library derivatives)

The following files are derived from the GNU C Library and carry its
`LGPL-2.1-or-later` header (each states "version 2.1 of the License, or (at your
option) any later version"). Full text: [`LICENSES/LGPL-2.1.txt`](LICENSES/LGPL-2.1.txt).

| File | Origin | Copyright |
|------|--------|-----------|
| `include/gk_mksort.h` | glibc `qsort`/sort templates (Douglas C. Schmidt) | Free Software Foundation, Inc. |
| `include/gkregex.h`   | glibc regex public header | Free Software Foundation, Inc. |
| `src/getopt.c`        | glibc `getopt` | Free Software Foundation, Inc. |
| `src/gkregex.c`       | glibc regex implementation (Isamu Hasegawa) | Free Software Foundation, Inc. |

Note: `src/gkregex.c` is only compiled when the platform lacks a system
`<regex.h>` (CMake sets `USE_GKREGEX`); `include/gkregex.h` is its companion
header. The sort templates in `include/gk_mksort.h` and `src/getopt.c` are
always built.

## BSD-3-Clause (Mersenne Twister)

`src/random.c` contains the MT19937-64 generator by Makoto Matsumoto and Takuji
Nishimura (Copyright (C) 2004), distributed under the 3-clause BSD license. This
code is compiled **only** when GKlib is built with the `GKRAND` option (which
defines `USE_GKRAND`); the default build uses the C library's `rand()` instead.
Full text: [`LICENSES/BSD-3-Clause-MT.txt`](LICENSES/BSD-3-Clause-MT.txt).

The copy bundled in `src/random.c` reproduces the upstream copyright notice and
warranty disclaimer; the canonical three redistribution conditions are recorded
in `LICENSES/BSD-3-Clause-MT.txt`.
