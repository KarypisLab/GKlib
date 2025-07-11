# Configuration options.
cc       = gcc
prefix   = ~/local
openmp   = not-set
gdb      = not-set
assert   = not-set
assert2  = not-set
debug    = not-set
gprof    = not-set
valgrind = not-set
pcre     = not-set
gkregex  = not-set
gkrand   = not-set
shared   = not-set


# Basically proxies everything to the builddir cmake.
cputype = $(shell uname -m | sed "s/\\ /_/g")
systype = $(shell uname -s)

BUILDDIR = build/$(systype)-$(cputype)

# Process configuration options.
CONFIG_FLAGS = -DCMAKE_VERBOSE_MAKEFILE=1
ifneq ($(gdb), not-set)
    CONFIG_FLAGS += -DGDB=$(gdb)
endif
ifneq ($(assert), not-set)
    CONFIG_FLAGS += -DASSERT=$(assert)
endif
ifneq ($(assert2), not-set)
    CONFIG_FLAGS += -DASSERT2=$(assert2)
endif
ifneq ($(debug), not-set)
    CONFIG_FLAGS += -DDEBUG=$(debug)
endif
ifneq ($(gprof), not-set)
    CONFIG_FLAGS += -DGPROF=$(gprof)
endif
ifneq ($(valgrind), not-set)
    CONFIG_FLAGS += -DVALGRIND=$(valgrind)
endif
ifneq ($(openmp), not-set)
    CONFIG_FLAGS += -DOPENMP=$(openmp)
endif
ifneq ($(pcre), not-set)
    CONFIG_FLAGS += -DPCRE=$(pcre)
endif
ifneq ($(gkregex), not-set)
    CONFIG_FLAGS += -DGKREGEX=$(gkregex)
endif
ifneq ($(gkrand), not-set)
    CONFIG_FLAGS += -DGKRAND=$(gkrand)
endif
ifneq ($(prefix), not-set)
    CONFIG_FLAGS += -DCMAKE_INSTALL_PREFIX=$(prefix)
endif
ifneq ($(cc), not-set)
    CONFIG_FLAGS += -DCMAKE_C_COMPILER=$(cc)
endif
ifneq ($(cputype), x86_64)
    CONFIG_FLAGS += -DNO_X86=$(cputype)
endif
ifeq ($(systype), Darwin)
    sysroot = $(shell $(cc) -print-sysroot || echo not-set)
    ifneq ($(sysroot), not-set)
	CONFIG_FLAGS += -DCMAKE_OSX_SYSROOT=$(sysroot)
    endif
endif
ifneq ($(shared), not-set)
    CONFIG_FLAGS += -DSHARED=1
endif

define run-config
mkdir -p $(BUILDDIR)
cd $(BUILDDIR) && cmake $(CURDIR) $(CONFIG_FLAGS)
endef

all clean install: $(BUILDDIR)
	make -C $(BUILDDIR) $@

uninstall:
	 xargs rm < $(BUILDDIR)/install_manifest.txt

$(BUILDDIR):
	$(run-config)

config: distclean
	$(run-config)

distclean:
	rm -rf $(BUILDDIR)

remake:
	find . -name CMakeLists.txt -exec touch {} ';'

.PHONY: config distclean all clean install uninstall remake
