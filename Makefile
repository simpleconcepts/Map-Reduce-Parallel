X10CPP=/opt/x10-2.2.0.1/bin/x10c++

# environment variables
X10_NTHREADS :=24
X10_NPLACES :=3

# Test Parameters
NUM_ASYNCS=1 2 4 8 16 24 32 64 128
NUM_TRIALS=3
NUM_INTS=100
SEED=40
INPUT_SIZE=10000000


default:MapReduceArray.out

MapReduceArray.out: $(NUM_ASYNCS:%=MapReduceArray.%.buildandrun)

MapReduceArray.%.buildandrun: MapReduceArray.exe
	salloc -n1 srun.x10sock ./MapReduceArray.exe  $(INPUT_SIZE) $(NUM_TRIALS) $* > MapReduceArray.$*.out
	@echo "Dumping contents of $(P1).$*.out ... "
	@grep "" MapReduceArray.$*.out
	@echo " "
	@echo "Find your results in $(P1).$*.out"
	@echo " "
MapReduceArray.exe: MapReduceArray.x10 tests/$(TARGET_CLASS)
	@cp tests/$(TARGET_CLASS) TestClass.x10
	$(X10CPP) -t -v -report postcompile=1 -o MapReduceArray.exe -optimize -O -NO_CHECKS MapReduceArray.x10


test: MapReduceArray.x10 tests/$(TARGET_CLASS)
	@cp tests/$(TARGET_CLASS) TestClass.x10
	$(X10CPP) -t -v -report postcompile=1 -o $(MapReduceArray).exe -optimize -O -NO_CHECKS MapReduceArray.x10
	@rm TestClass.x10

test-run: test
	@for num_asyncs in $(NUM_ASYNCS); do \
		./a.out $$num_asyncs ; \
	done

clean:
	rm -f *.o *.cc *.h *.exe *.inc *.out *.mpi *~ \#*