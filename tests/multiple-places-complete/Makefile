X10CPP=/opt/x10-2.2.0.1/bin/x10c++

# environment variables
X10_NTHREADS := 24
X10_NPLACES := 3
NUM_ASYNCS = 1 2 4 8 16 32 64 128

# DitributedSort Parameters
P1=DistributedSort
P1_ASYNCS=24
P1_NUM_TRIALS=3
NUM_INTS=100
SEED=40

default: $(P1).out
sort: $(P1).out
$(P1).out: $(P1_ASYNCS:%=$(P1).%.buildandrun)

$(P1).%.buildandrun: $(P1).exe
	salloc -n3 srun.x10sock ./$(P1).exe  $(DICT_LOC) $(NUM_WORDS) $(SEED) $(P1_NUM_TRIALS) $* > $(P1).$*.out
	@echo "Dumping contents of $(P1).$*.out ... "
	@grep "" $(P1).$*.out
	@echo " "
	@echo "Find your results in $(P1).$*.out"
	@echo " "
$(P1).exe: $(P1).x10
	$(X10CPP) -t -v -report postcompile=1 -o $(P1).exe -optimize -O -NO_CHECKS $(P1).x10
local: DistributedSort.x10
	$(X10CPP) -t -v -report postcompile=1 -o DistributedSort.exe -optimize -O -NO_CHECKS DistributedSort.x10
	./DistributedSort.exe

test: MapReduceArray.x10 tests/$(TARGET_CLASS)
	@cp tests/$(TARGET_CLASS) TestClass.x10
	$(X10CPP) MapReduceArray.x10
	@rm TestClass.x10

test-run: test
	@for num_asyncs in $(NUM_ASYNCS); do \
		./a.out $$num_asyncs ; \
	done

clean:
	rm -f *.cc *.h *.exe *.inc *.out *.mpi *~ \#* *.o *.cc *.h a.out
