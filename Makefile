# makefile for libpng.a and libpng16.so on Linux ELF with gcc
# Copyright (C) 2020-2022 Cosmin Truta
# Copyright (C) 1998, 1999, 2002, 2006, 2008, 2010-2014 Greg Roelofs and
# Glenn Randers-Pehrson
# Copyright (C) 1996, 1997 Andreas Dilger
#
# This code is released under the libpng license.
# For conditions of distribution and use, see the disclaimer
# and license in png.h

# Library name:
LIBNAME=libpng16
PNGMAJ=16

# Shared library names:
LIBSO=$(LIBNAME).so
LIBSOMAJ=$(LIBNAME).so.$(PNGMAJ)

# Utilities:
CC=${WASM_CC}
AR_RC=${WASM_AR} rc
RANLIB=${WASM_RANLIB}
MKDIR_P=mkdir -p
LN_SF=ln -sf
CP=cp
RM_F=rm -f

ZLIBLIB=${WASM_SYSROOT}/lib/wasm32-wasi
ZLIBINC=${WASM_SYSROOT}/include

# Compiler and linker flags
# NOHWOPT=-DPNG_ARM_NEON_OPT=0 -DPNG_MIPS_MSA_OPT=0 \
# 	-DPNG_POWERPC_VSX_OPT=0 -DPNG_INTEL_SSE_OPT=0
# WARNMORE=-Wwrite-strings -Wpointer-arith -Wshadow \
# 	-Wmissing-declarations -Wtraditional -Wcast-align \
# 	-Wstrict-prototypes -Wmissing-prototypes # -Wconversion
DEFS=$(NOHWOPT)
# CPPFLAGS=-I$(ZLIBINC) $(DEFS) # -DPNG_DEBUG=5
# CFLAGS=-O3 -funroll-loops -Wall -Wextra -Wundef # $(WARNMORE) -g
# LDFLAGS_A=-L$(ZLIBLIB) -Wl,-rpath,$(ZLIBLIB) libpng.a -lz -lm # -g
CFLAGS=${WASM_CFLAGS} -DPNG_NO_SETJMP
LDFLAGS_BASE=-L. -Wl,-rpath,. -L$(ZLIBLIB) -Wl,-rpath,$(ZLIBLIB) -lpng16 -lz -lm # -g
LDFLAGS=${LDFLAGS_BASE} ${WASM_LDFLAGS}

# Pre-built configuration
# See scripts/pnglibconf.mak for more options
PNGLIBCONF_H_PREBUILT = scripts/pnglibconf.h.prebuilt

# File lists
OBJS = png.o pngerror.o pngget.o pngmem.o pngpread.o \
       pngread.o pngrio.o pngrtran.o pngrutil.o pngset.o \
       pngtrans.o pngwio.o pngwrite.o pngwtran.o pngwutil.o

OBJSDLL = $(OBJS:.o=.pic.o)

.SUFFIXES:      .c .o .pic.o

.c.o:
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -o $@ $<

.c.pic.o:
	$(CC) -c $(CPPFLAGS) $(CFLAGS) -fPIC -o $@ $*.c

all: libpng.a # $(LIBSO) pngtest pngtest-static

pnglibconf.h: $(PNGLIBCONF_H_PREBUILT)
	$(CP) $(PNGLIBCONF_H_PREBUILT) $@

libpng.a: $(OBJS)
	$(AR_RC) $@ $(OBJS)
	$(RANLIB) $@

$(LIBSO): $(LIBSOMAJ)
	$(LN_SF) $(LIBSOMAJ) $(LIBSO)

$(LIBSOMAJ): $(OBJSDLL)
	$(CC) -shared -Wl,-soname,$(LIBSOMAJ) -o $(LIBSOMAJ) $(OBJSDLL)

pngtest: pngtest.o $(LIBSO)
	$(CC) -o pngtest $(CFLAGS) pngtest.o $(LDFLAGS)

pngtest-static: pngtest.o libpng.a
	$(CC) -o pngtest-static $(CFLAGS) pngtest.o $(LDFLAGS_A)

test: pngtest pngtest-static
	@echo ""
	@echo "   Running pngtest dynamically linked with $(LIBSO):"
	@echo ""
	./pngtest
	@echo ""
	@echo "   Running pngtest statically linked with libpng.a:"
	@echo ""
	./pngtest-static

install:
	@echo "The $@ target is no longer supported by this makefile."
	@false

install-static:
	@echo "The $@ target is no longer supported by this makefile."
	@false

install-shared:
	@echo "The $@ target is no longer supported by this makefile."
	@false

clean:
	$(RM_F) $(OBJS) $(OBJSDLL) libpng.a
	$(RM_F) $(LIBSO) $(LIBSOMAJ)* pnglibconf.h
	$(RM_F) pngtest*.o pngtest pngtest-static pngout.png

# DO NOT DELETE THIS LINE -- make depend depends on it.

png.o      png.pic.o:      png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngerror.o pngerror.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngget.o   pngget.pic.o:   png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngmem.o   pngmem.pic.o:   png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngpread.o pngpread.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngread.o  pngread.pic.o:  png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngrio.o   pngrio.pic.o:   png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngrtran.o pngrtran.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngrutil.o pngrutil.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngset.o   pngset.pic.o:   png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngtrans.o pngtrans.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngwio.o   pngwio.pic.o:   png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngwrite.o pngwrite.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngwtran.o pngwtran.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h
pngwutil.o pngwutil.pic.o: png.h pngconf.h pnglibconf.h pngpriv.h pngstruct.h pnginfo.h pngdebug.h

pngtest.o: png.h pngconf.h pnglibconf.h
