X10CPP=/opt/x10-2.2.0.1/bin/x10c++

# environment variables
X10_NTHREADS := 24
X10_NPLACES := 3
NUM_ASYNCS = 1 1 1 2 2 2 4 4 4 8 8 8 16 16 16 32 32 32 64 64 64 128 128 128 

# DitributedSort Parameters
P1=TestClass
P1_ASYNCS=24
P1_NUM_TRIALS=3
NUM_INTS=100
SEED=40

default: $(P1).out
sort: $(P1).out
$(P1).out: $(P1_ASYNCS:%=$(P1).%.buildandrun)

$(P1).%.buildandrun: $(P1).exe
	salloc -n1 srun.x10sock ./$(P1).exe  $(DICT_LOC) $(NUM_WORDS) $(SEED) $(P1_NUM_TRIALS) $* > $(P1).$*.out
	@echo "Dumping contents of $(P1).$*.out ... "
	@grep "" $(P1).$*.out
	@echo " "
	@echo "Find your results in $(P1).$*.out"
	@echo " "
$(P1).exe: MapReduceArray.x10 tests/$(P1).x10
	@cp tests/$(P1).x10 TestClass.x10
	$(X10CPP) -t -v -report postcompile=1 -o $(P1).exe -optimize -O -NO_CHECKS tests/$(P1).x10
	@rm TestClass.x10

test: MapReduceArray.x10 tests/$(TARGET_CLASS)
	@cp tests/$(TARGET_CLASS) TestClass.x10
	$(X10CPP) MapReduceArray.x10
	@rm TestClass.x10

test-run: test
	@for num_asyncs in $(NUM_ASYNCS); do \
		./a.out $$num_asyncs ; \
	done

clean:
	rm -rf *.o *.cc *.h a.out
