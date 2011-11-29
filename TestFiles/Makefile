X10CPP=/opt/x10-2.2.0.1/bin/x10c++
X10_PATH=/opt/x10-2.2.0.1/bin/

# environment variables
X10_NTHREADS := 24
#X10_STATICS_THREADS := false
#X10LAUNCHER_NPROCS := 1

# general parameters
SEED=40

# SpellCheck Parameters
P1=SpellCheck
DICT_LOC=/usr/share/dict/words
NUM_WORDS=10000
P1_ASYNCS=1 2 4
P1_NUM_TRIALS=2

# MadReduce Parameters
P2=MapReduceSequential
INVEC_SIZE=500000
P2_ASYNCS=1 2 4
P2_NUM_TRIALS=3

spellcheck: $(P1).out
$(P1).out: $(P1_ASYNCS:%=$(P1).%.buildandrun) 

$(P1).%.buildandrun: $(P1).exe   
	salloc -n1 srun.x10sock ./$(P1).exe  $(DICT_LOC) $(NUM_WORDS) $(SEED) $(P1_NUM_TRIALS) $* > $(P1).$*.out
	@echo "Dumping contents of $(P1).$*.out ... "
	@grep "" $(P1).$*.out
	@echo " "
	@echo "Find your results in $(P1).$*.out"
	@echo " "

$(P1).exe: $(P1).x10
	$(X10CPP) -t -v -report postcompile=1 -o $(P1).exe -optimize -O -NO_CHECKS $(P1).x10

sequential: MapReduceSequential.out

$(P2).out: $(PS_ASYNCS:%=MapReduceSequential.%buildandrun)

$(P2).%.buildingandrun: $(P2).exe
	salloc -n1 srun.x10sock ./$(P2).exe $(INVEC_SIZE) $(P2_NUM_TRIALS) $* > $(P2).$*.out
	@echo "Dumping contents of $(P2).$*.out ... "
	@grep "" $(P2).$*.out
	@echo " "
	@echo "Find your results in $(P2).$*.out"
	@echo " "
$(P2).exe: $(P2).x10
	$(X10_PATH)/x10c++ -t -v -report postcompile=1 -o $(P2).exe -optimize -O -NO_CHECKS $(P2).x10
	$(X10CPP) -t -v -report postcompile=1 -o $(P1).exe -optimize -O -NO_CHECKS MapReduceSequential.x10
test:
	$(X10_PATH)/x10c++ MapReduceArray.x10

all:

.PRECIOUS:
.x10:
	@echo $@
#	$(X10_PATH)/x10c++ -t -v -report postcompile=1 -o $@ -x10rt mpi -optimize -O -NO_CHECKS $<

.PHONY: $(P1).out clean

clean:
	rm -f *.cc *.h *.exe *.inc *.out *.mpi *~ \#*