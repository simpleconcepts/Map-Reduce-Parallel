import x10.io.File;
import x10.util.Random;

/**
 * 
 * Distributed Bottom-Up MergeSort with MapReduce
 * Source:http://algs4.cs.princeton.edu/22mergesort/MergeBU.java.html
 */
public class DistributedSort {
	
	/*
	private val distributor:MapReduceArray[Array[Int], Array[Int]];
	private val data:Array[Int];
	 */
	/*
	public def this(){
		distributor = new MapReduceArray[Array[Int], Array[Int]];
	    val numInts = 10000;
	    val data:Array[Int] = new Array[Int](numInts);
	    data = make("tenthousand.txt");
	    
		
	}
	*/
	
	/* Method That Reads in List of Random Numbers */
	public static def make(filename:String):Array[Int]{
		
		try {
			val I = new File(filename);
			var numInts:Int = 0;
			
			for(line in I.lines())
				numInts++;
			val data = new Array[Int](numInts);
			var i:Int = 0;
			for (line in I.lines()) {
				data(i) = Int.parseInt(line.trim());
				i++;
			}
			return data;
		}
		catch(e2: x10.io.FileNotFoundException) {
			Console.OUT.println("ERROR - File not found: "+filename);
			return null;
		}

	}
	
	
	
	
	
	// stably merge a[lo..m] with a[m+1..hi] using aux[lo..hi]
	public static def merge(a:Array[Int], aux:Array[Int], lo:Int, m:Int, hi:Int){
		
		// copy to aux[]
		Array.copy(a,0,aux,0,a.size);
		
		// merge back to a[]
		var i:Int = lo;
		var j:Int = m+1;
		for(var k:Int = lo; k <= hi; k++){
			if (i > m)				  a(k) = aux(j++);
			else if (j > hi) 	      a(k) = aux(i++);
			else if (aux(j) < aux(i)) a(k) = aux(j++);
			else                      a(k) = aux(i++);
			
		}
		
	}
	
	private static def isSorted(a:Array[Int]):Boolean{
		for(var i:Int = 1; i < a.size; i++)
			if (a(i) < a(i-1)) return false;
		return true;
	}
	
	// bottom-up mergesort
	public static def sort(a:Array[Int]){
		val N = a.size;
		val aux:Array[Int] = new Array[Int](N);
		for(var n:Int = 1; n < N; n = n+n){
			for(var i:Int = 0; i < N-n; i+= n+n){
				var lo:Int = i;
				var m:Int = i+n-1;
				var hi:Int = Math.min(i+n+n-1,N-1);
				merge(a,aux,lo,m,hi);
			}
			
		}
		assert isSorted(a);
	}
	
	// print array to standard output
	private static def show(a:Array[Int]){
		for(var i:Int = 0; i < a.size; i++){
			Console.OUT.print(a(i)+" ");
		}
		Console.OUT.println();
	}	
	
    /**
     * The main method for the Hello class
     */
    public static def main(Array[String]) {
    	
    	val a = [5,6,1,3,8,7,4,11];
    	sort(a);
    	show(a);
    }

}

