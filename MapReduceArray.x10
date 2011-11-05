import x10.util.ArrayBuilder;

public class MapReduceArray[M, R]
{
	private def distSequential(mr:MapReduce[M, R], data:Array[M], start:int, length:int):R {
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

        public def distribute(mr:MapReduce[M, R], data:Array[M]) {
            return distSequential(mr, data, 0, data.size);
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
                Console.OUT.println(distributor.distribute(mapper, data.result()));
        }
}
