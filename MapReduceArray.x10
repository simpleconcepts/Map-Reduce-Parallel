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
    public static def block(R:Region(1),P:Int):Rail[Region(1)] = {
    	   assert P >= 0;
	   val low = R.min()(0), high = R.max()(0), count = high-low+1;
	   val baseSize = count/P, extra = count - baseSize*P;
	   new Rail[Region(1)](P, (i:Int):Region(1) => {
	       val start = low+i*baseSize+(i <extra? i:extra);
	       start..(start+baseSize+(i < extra?0:-1))
	       })
    }

   


    public def distributeMultiplePlaces(mr:MapReduce[M, R], data:Array[M]{rank==1},
    	       				inNumAsyncs:Int,inNumPlaces:Int){R haszero, M haszero} {
	
	val N = data.region.max(0) + 1;
	var numAsyncsTemp:Int = inNumAsyncs;
	var numPlacesTemp:Int = inNumPlaces;
	if (N < numAsyncsTemp)
	   numAsyncsTemp = N;
	if(numPlacesTemp > Place.MAX_PLACES)
	   numPlacesTemp = Place.MAX_PLACES;
	val numAsyncs:Int = numAsyncsTemp; 
	val numPlaces:Int = numPlacesTemp;
	val Reg = block(0..(N-1),numPlaces);
	
	val D = Dist.makeUnique();
	val results = new Array[R](numPlaces);
	
	val args = new Array[Array[M]](numPlaces);
	val inputsPerPlace = data.size / numPlaces;
	for (i in 0..(numPlaces - 1)) {
		val start = i * inputsPerPlace;
		val end = (i == (numPlaces - 1)) ? data.size - 1 : (start + inputsPerPlace - 1);
		val len = end - start + 1;
		args(i) = new Array[M](len);
		Array.copy(data, start, args(i), 0, len);
	}

	val mapper:MapReduceArray[M,R] = new MapReduceArray[M,R]();

	finish for (p in Place.places()) {
         	    val myA = args(p.id);
                    val myMr = mr;
                    val myNumAsyncs = inNumAsyncs;
		    async results(p.id) = at(p) (new MapReduceArray[M, R]()).distributeParallel(myMr,myA,myNumAsyncs);
	}

	var accumulator:R = results(0);
	for (i in 1..(numPlaces-1)) {
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

        val insize = Int.parseInt(argv(0));
	val num_trials = Int.parseInt(argv(1));
	val numAsyncs = Int.parseInt(argv(2));
	val numPlaces = Int.parseInt(argv(3));
        Console.OUT.println("Running with "+numAsyncs+" asyncs");
	Console.OUT.println("Running with "+numPlaces+" places");
	val mapper:TestClass = new TestClass(insize);
       	
	//serial result
	var serialTime:Long = 0;
	for(t in 0..(num_trials-1)){
        val start:Long = Timer.milliTime();
        mapper.demonstrateSequential();
        val end:Long = Timer.milliTime();
	val sequentialTime = end - start;
	serialTime += sequentialTime;
	}

        Console.OUT.println("Sequential map reduce benchmark completed in "+
                             serialTime/num_trials+" milliseconds on average.");

        // parallel result
	var parallelTime:Long = 0;
	for(t in 0..(num_trials-1)){ 
        var start:Long = Timer.milliTime();
        mapper.demonstrateParallel(numAsyncs);
        var end:Long = Timer.milliTime();
        var pTime:Long = end - start;
	parallelTime += pTime;
	}
        Console.OUT.println("Parallel map reduce benchmark completed in "+
                             parallelTime/num_trials+" milliseconds on average.");

	//Multiple-Place time
	var multiplePlaceTime:Long = 0;
	for(t in 0..(num_trials-1)){
	var start:Long = Timer.milliTime();
	mapper.demonstrateMultiplePlaces(numAsyncs,numPlaces);
	var end:Long = Timer.milliTime();
	val twoTime = end - start;
	multiplePlaceTime += twoTime;
	}	
	Console.OUT.println("Multiple-Place map reduce benchmark completed in "+
				       multiplePlaceTime/num_trials+" milliseconds on average.");
	

/*	
        if (parallelTime.bitCount() == 0) {
            Console.OUT.println("Parallel computation completed in less than a millisecond.");
            Console.OUT.println("Not showing comparison results");
        } else {
            val speedup =(sequentialTime as Float) / parallelTime;
            Console.OUT.println("Parallel speedup saw improvement of "+speedup);
	    val speedupMult = (sequentialTime as Float) / multipleTime;
	    Console.OUT.println("Multiple-Place speed up saw improvement of "+speedupMult);
            Console.OUT.println("FrameworkTag: "+numAsyncs+" "+speedup);
        }
*/
    }
}

