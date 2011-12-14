import x10.util.ArrayBuilder;

public class TestClass implements MapReduce[Int, Int], Testable {
    private val distributor:MapReduceArray[Int, Int];
    private val data:Array[Int];

    public def this(inputSize:Int) {
        distributor = new MapReduceArray[Int, Int]();
        val numInts = inputSize;
        val dataBuilder:ArrayBuilder[Int] = new ArrayBuilder[Int](numInts);
        for (i in 0..(numInts - 1)) {
            dataBuilder.add(i + 1);
        }

        data = dataBuilder.result();
    }

    public def map(arg:Int):Int {
        return arg;
    }
    public def reduce(arg1:Int, arg2:Int):Int {
        return arg1 + arg2;
    }

    public def demonstrateSequential() {
        distributor.distributeSequential(this, data);
    }

    public def demonstrateParallel(numAsyncs:Int) {
        distributor.distributeParallel(this, data, numAsyncs);
    }
    
    public def demonstrateMultiplePlaces(numAsyncs:Int,numPlaces:Int){
    	distributor.distributeMultiplePlaces(this,data,numAsyncs,numPlaces);
    }
    public def describe() {
        return "SumIntegers";
    }
}

