X10CPP=/opt/x10-2.2.0.1/bin/x10c++

test: MapReduceArray.x10 tests/$(TARGET_CLASS)
	cp tests/$(TARGET_CLASS) TestClass.x10
	$(X10CPP) MapReduceArray.x10
	rm TestClass.x10

clean:
	rm -rf *.o *.cc *.h a.out
