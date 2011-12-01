interface MapReduce[M, R]
{
	public def map(arg:M):R;
	public def reduce(arg1:R, arg2:R):R;
	
	/*
	public def inputreader(arg3:String):Rail[String];
	public def partition(arg4:R):void;
	public def compare(arg5:[T],arg6:[T]):Int;
	public def outputWriter(arg7:[T]);
	*/
}
