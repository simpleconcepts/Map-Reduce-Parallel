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

	public static def main(argv:Array[String]) {
		Console.OUT.println("Hello, World");
	}
}
