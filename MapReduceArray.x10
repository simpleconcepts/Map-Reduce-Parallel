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

	public static def main(argv:Array[String]) {
		Console.OUT.println("Hello World!");

                val mapper:SumIntegers = new SumIntegers();
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
}

