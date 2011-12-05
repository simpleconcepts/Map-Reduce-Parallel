X10_PATH=/opt/x10-2.2.0.1/bin

# environment variables
X10_NTHREADS := 24
#X10_STATIC_THREADS := false
#X10LAUNCHER_NPROCS := 1

# general parameters
SEED=40

# CharFrequency parameters
P1=WordCount
DICT_LOC=/usr/share/dict/words
NUM_WORDS=10
P1_ASYNCS=1 2 4
P1_NUM_TRIALS=2

default: $(P1).out
$(P1).out: $(P1_ASYNCS:%=$(P1).%.buildandrun)

$(P1).%.buildandrun: $(P1).exe
	salloc -n1 srun.x10sock ./$(P1).exe  $(DICT_LOC) $(NUM_WORDS) $(SEED) $(P1_NUM_TRIALS) $* > $(P1).$*.out
	@echo "Dumping contents of $(P1).$*.out ... "
	@grep "" $(P1).$*.out
	@echo " "
	@echo "Find your results in $(P1).$*.out"
	@echo " "

$(P1).exe: $(P1).x10
	$(X10_PATH)/x10c++ -t -v -report postcompile=1 -o $(P1).exe -optimize -O -NO_CHECKS $(P1).x10

char: CharFrequency.out

CharFrequency.out: CharFrequency.exe
	./CharFrequency.exe

CharFrequency.exe: CharFrequency.x10
	$(X10_PATH)/x10c++ -t -v -o CharFrequency.exe -optimize -O -NO_CHECKS CharFrequency.x10

clean:
	rm -f *.cc *.h *.exe *.inc *.out *.mpi *~ \#*