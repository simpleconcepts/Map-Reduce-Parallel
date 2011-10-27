interface MapReduce[M, R]
{
	public def map(arg:M):R;
	public def reduce(arg1:R, arg2:R):R;
}
