# Configuration options.
cc       = $(CC)
prefix   = ~/local
openmp   = not-set
assert   = not-set
assert2  = not-set
debug    = not-set
gprof    = not-set
pcre     = not-set
gkregex  = not-set
gkrand   = not-set

# Basically proxies everything to the builddir cmake.
cputype = $(shell uname -m | sed "s/\\ /_/g")
systype = $(shell uname -s)

BUILDDIR = build/$(systype)-$(cputype)

# Process configuration options.
CONFIG_FLAGS =
BUILD_FLAGS =
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
# Include GKlibSystem.cmake by default
CONFIG_FLAGS += -DGKLIB_SYSTEM=./cmake/GKlibSystem.cmake

define run-config
mkdir -p $(BUILDDIR)
cd $(BUILDDIR) && CC=$(cc) cmake $(CURDIR) $(CONFIG_FLAGS)
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
