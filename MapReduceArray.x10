import x10.util.Timer;
import x10.util.ArrayBuilder;
import x10.lang.Place;

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

    public def distributeParallel(mr:MapReduce[M, R], data:Array[M]{rank==1},
                                  inNumAsyncs:Int){R haszero}:R {
        val length = data.region.max(0) + 1;
        var numAsyncs:Int = inNumAsyncs;
	
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

    public static def main(argv:Array[String]) {
        val numAsyncs = Int.parse(argv(0));
        Console.OUT.println("Running with "+numAsyncs+" asyncs");

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
        mapper.demonstrateParallel(numAsyncs);
        end = Timer.milliTime();

        val parallelTime = end - start;
        Console.OUT.println("Parallel map reduce benchmark completed in "+
                             parallelTime+" milliseconds");
	
	start = Timer.milliTime();
//	mapper.demonstrateMultiplePlaces(numAsyncs,numPlaces);
	end = Timer.milliTime();
	val multipleTime = end - start;
	Console.OUT.println("Multiple Place map reduce benchmark completed in "+
				      	   multipleTime+" milliseconds" );
	
        if (parallelTime.bitCount() == 0) {
            Console.OUT.println("Parallel computation completed in less than a millisecond.");
            Console.OUT.println("Not showing comparison results");
        } else {
            val speedup =(sequentialTime as Float) / parallelTime;
            Console.OUT.println("Parallel speedup saw improvement of "+speedup);
            Console.OUT.println("FrameworkTag: "+mapper.describe()+" "+numAsyncs+" "+speedup);
        }

    }
}

