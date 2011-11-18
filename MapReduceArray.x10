import x10.util.Timer;
import x10.util.ArrayBuilder;

public class MapReduceArray[M, R]
{
    private def distSequential(mr:MapReduce[M, R], data:Array[M]{rank==1}, start:int, length:int):R {
            if (length == 1) {
                    return mr.map(data(start));
            } else if (length == 2) {
                    return mr.reduce(mr.map(data(start)), mr.map(data(start + 1)));
            } else {
                    val firstLength  = length / 2;
                    val secondLength = length - firstLength;

                    return mr.reduce(distSequential(mr, data, start, firstLength),
                                     distSequential(mr, data, start + firstLength, secondLength));
            }
    }

    public def distributeSequential(mr:MapReduce[M, R], data:Array[M]{rank==1}) {
        return distSequential(mr, data, 0, data.size);
    }

    private def doParallelChunk(mr:MapReduce[M, R], data:Array[M]{rank==1},
                                          id:Int, numAsyncs:Int):R {
        val length = data.region.max(0) + 1;
        val inputsPerAsync = length / numAsyncs;
        val start = id * inputsPerAsync;
        val end = (id == (numAsyncs - 1)) ? length - 1 : (start + inputsPerAsync - 1);

        var accumulator:R = mr.map(data(start));

        for (i in (start + 1)..end) {
            val value = data(i);
            accumulator = mr.reduce(accumulator, mr.map(value));
        }

        return accumulator;
    }

    public def distributeParallel(mr:MapReduce[M, R], data:Array[M]{rank==1}){R haszero}:R {
        var numAsyncs:Int = 24;
        val length = data.region.max(0) + 1;

        if (length < numAsyncs)
            numAsyncs = length;

        val results = new Array[R](numAsyncs);
        finish for (id in 0..(numAsyncs - 1)) async {
            results(id) = doParallelChunk(mr, data, id, numAsyncs);
        }

        var accumulator:R = results(0);
        for (i in 1..(numAsyncs - 1)) {
            accumulator = mr.reduce(accumulator, results(i));
        }
        return accumulator;
    }

    /*
    private def correctnessTest() {
        val mapper = new SumIntegers();

        val distributor:MapReduceArray[Int, Int] = new MapReduceArray[Int, Int]();
        val numInts = 10000;
        val data:ArrayBuilder[Int] = new ArrayBuilder[Int](numInts);
        for (i in 0..(numInts - 1)) {
            data.add(i + 1);
        }

        val dataArray:Array[Int] = data.result();

        val sequentialResult = distributor.distributeSequential(mapper, dataArray);
        val parallelResult = distributor.distributeParallel(mapper, dataArray);

        Console.OUT.println("Sequential result: "+sequentialResult);
        Console.OUT.println("Parallel result  : "+parallelResult);

        if (sequentialResult != parallelResult)
            Console.OUT.println("Error: correctness mismatch");
    }
    */

    public static def main(argv:Array[String]) {
        Console.OUT.println("Hello World!");

        val mapper:TestClass = new TestClass();
        var start:Long;
        var end:Long;

        start = Timer.milliTime();
        mapper.demonstrateSequential();
        end = Timer.milliTime();

        val sequentialTime = end - start;
        Console.OUT.println("Sequential map reduce benchmark completed in "+
                             sequentialTime+" milliseconds");

        start = Timer.milliTime();
        mapper.demonstrateParallel();
        end = Timer.milliTime();

        val parallelTime = end - start;
        Console.OUT.println("Parallel map reduce benchmark completed in "+
                             parallelTime+" milliseconds");

        if (parallelTime.bitCount() == 0) {
            Console.OUT.println("Parallel computation completed in less than a millisecond.");
            Console.OUT.println("Not showing comparison results");
        } else {
            val speedup =(sequentialTime as Float) / parallelTime;
            Console.OUT.println("Parallel speedup saw improvement of "+speedup);
        }
    }
}

