# common depends on all the $(LIBS) at the end
.PHONY: common
common:

# bb Module
bb_MEMGEN:=bb/mem_bb.h
bb_SOURCES:=arena.c averager.c bb_asprintf.c bbhrtime.c bb_oscompat.c	\
          cheapstub.c comdb2file.c comdb2_pthread_create.c ctrace.c	    \
          debug_switches.c flibc.c fsnapf.c intern_strings.c list.c	    \
          lockassert.c mem.c misc.c nodemap.c object_pool.c passfd.c	\
          plhash.c pool.c portmuxusr.c queue.c roll_file.c rtcpu.c	    \
          safestrerror.c sbuf2.c segstring.c sltpck.c str0.c strbuf.c	\
          switches.c tcputil.c thdpool.c thread_malloc.c		        \
          thread_util.c timers.c utilmisc.c walkback.c xstring.c        \
          ssl_support.c logmsg.c
bb_abs_SOURCES:=$(foreach src,$(bb_SOURCES),bb/$(src))
bb_OBJS=$(patsubst %.c,%.o,$(bb_abs_SOURCES))

ARS+=bb/libbb.a
OBJS+=$(bb_OBJS)
GENH+=$(bb_MEMGEN)

# Standalone mem_int generated by no argument mem_codegen.sh
GENH+=bb/mem_int.h

bb/libbb.a: $(bb_OBJS)
	$(AR) $(ARFLAGS) $@ $^

$(bb_OBJS): $(bb_MEMGEN)

# One object file depends on cdb2api
bb/rtcpu.o: CPPFLAGS:=-I$(SRCHOME)/cdb2api $(CPPFLAGS)

# tz Module
tz_MEMGEN:=datetime/mem_datetime.h
tz_SOURCES:=localtimedb.c asctime.c difftime.c
tz_abs_SOURCES:=$(foreach src,$(tz_SOURCES),datetime/$(src))
tz_OBJS:=$(patsubst %.c,%.o,$(tz_abs_SOURCES))

ARS+=datetime/libtz.a
OBJS+=$(tz_OBJS)
GENH+=$(tz_MEMGEN)

datetime/libtz.a: $(tz_OBJS)
	$(AR) $(ARFLAGS) $@ $^

$(tz_OBJS): $(tz_MEMGEN)
$(tz_OBJS): CFLAGS+=-DSTD_INSPIRED

# protobuf Module
pbuf_MEMGEN:=protobuf/mem_protobuf.h
pbuf_SOURCES:=sqlquery.pb-c.c sqlresponse.pb-c.c bpfunc.pb-c.c
pbuf_abs_SOURCES:=$(foreach src,$(pbuf_SOURCES),protobuf/$(src))
pbuf_OBJS:=$(patsubst %.c,%.o,$(pbuf_abs_SOURCES))

protobuf/libcdb2protobuf.a: $(pbuf_OBJS)
	$(AR) $(ARFLAGS) $@ $^

$(pbuf_OBJS): $(pbuf_MEMGEN)

.PRECIOUS: %.pb-c.c
%.pb-c.c: %.proto
	protoc-c  $(<) --c_out=.

ARS+=protobuf/libcdb2protobuf.a
OBJS+=$(pbuf_OBJS)
# Everything in protobuf is generated
GENC+=$(pbuf_abs_SOURCES)
GENH+=$(pbuf_MEMGEN)

# dfp Module
dfp_MEMGEN:=dfp/decNumber/mem_dfp_decNumber.h
dfp_SOURCES:=decNumber/decNumber.c decNumber/decContext.c		\
decNumber/decimal32.c decNumber/decimal64.c decNumber/decimal128.c	\
decNumber/decPacked.c decNumber/decSingle.c decNumber/decDouble.c	\
decNumber/decQuad.c dfpal/dfpal.c
dfp_abs_SOURCES:=$(foreach src,$(dfp_SOURCES),dfp/$(src))
dfp_OBJS:=$(patsubst %.c,%.o,$(dfp_abs_SOURCES))

dfp_CFLAGS:=-DDFPAL_NO_HW_DFP
ifeq ($(arch),Linux)
dfp_CFLAGS+=-DDECLITEND=1
endif
ifeq ($(arch),AIX)
dfp_CFLAGS+=-qcpluscmt
dfp_CFLAGS+=-DDECLITEND=0
endif
dfp_CFLAGS+=-I$(SRCHOME)/dfp/decNumber

dfp/decNumber/libdfpal.a: $(dfp_OBJS)
	$(AR) $(ARFLAGS) $@ $^

$(dfp_OBJS): $(dfp_MEMGEN)
$(dfp_OBJS): CFLAGS+=$(dfp_CFLAGS)


ARS+=dfp/decNumber/libdfpal.a
OBJS+=$(dfp_OBJS)
GENH+=$(dfp_MEMGEN)

# cson Module
cson_SOURCES:=cson/cson_amalgamation_core.c
cson_OBJS:=$(patsubst %.c,%.o,$(cson_SOURCES))

cson/libcson.a: $(cson_OBJS)
	$(AR) $(ARFLAGS) $@ $^

ARS+=cson/libcson.a
OBJS+=$(cson_OBJS)

# dlmalloc Module
dlmalloc_SOURCES:=dlmalloc/dlmalloc.c
dlmalloc_OBJS:=$(patsubst %.c,%.o,$(dlmalloc_SOURCES))

dlmalloc/libdlmalloc.a: $(dlmalloc_OBJS)
	$(AR) $(ARFLAGS) $@ $^

ARS+=dlmalloc/libdlmalloc.a
OBJS+=$(dlmalloc_OBJS)

# crc32c Module
crc32c_SOURCES:=crc32c/crc32c.c
crc32c_OBJS:=$(patsubst %.c,%.o,$(crc32c_SOURCES))
ifeq ($(arch),Linux)
	crc32c_CFLAGS:=-msse4.2 -mpclmul
endif

crc32c/libcrc32c.a: $(crc32c_OBJS)
	$(AR) $(ARFLAGS) $@ $^

crc32c/libcrc32c.a: CFLAGS+=$(crc32c_CFLAGS)

ARS+=crc32c/libcrc32c.a
OBJS+=$(crc32c_OBJS)

# Memory Modules (every .c has a corresponding .h)
GENH+=$(patsubst %.c,%.h,$(GENC))