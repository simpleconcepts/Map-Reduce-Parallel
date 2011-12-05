X10CPP=/opt/x10-2.2.0.1/bin/x10c++

NUM_ASYNCS = 1 2 4 8 16 32 64 128

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
