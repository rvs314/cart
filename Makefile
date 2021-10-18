CC=clang-13
CFLAGS=-g `llvm-config-13 --cflags`
LD=clang++-13
LDFLAGS=`llvm-config-13 --cxxflags --ldflags --libs core executionengine interpreter analysis native bitwriter --system-libs`

all: sum

sum.o: sum.cc
	$(CC) $(CFLAGS) -c $<

sum: sum.o
	$(LD) $< $(LDFLAGS) -o $@

sum.bc: sum
	./sum 0 0

sum.ll: sum.bc
	llvm-dis $<

clean:
	-rm -f sum.o sum sum.bc sum.ll
