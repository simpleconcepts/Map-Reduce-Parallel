public class SumIntegers implements MapReduce[Int, Int] {
    public def map(arg:Int):Int {
        return arg;
    }
    public def reduce(arg1:Int, arg2:Int):Int {
        return arg1 + arg2;
    }
}

