import x10.io.File;
import x10.util.Random;
import x10.util.ArrayBuilder;
import x10.lang.Place;
/*
 * 
 * Distributed Bottom-Up MergeSort with MapReduce
 * Source:http://algs4.cs.princeton.edu/22mergesort/MergeBU.java.html
 */

public class DistributedSort{
	private val data:Array[Int];
	public def this(){
	    val numSets = 15;
	    val numInts = 50;
	    val SEED = 40;
	    var temp:Array[Int];
	    val dataBuilder:ArrayBuilder[Int] = new ArrayBuilder[Int](numInts);
		val rand:Random = new Random(40);
	        for(var i:Int = 0; i < numInts; i++){
	     	    dataBuilder.add(rand.nextInt(40));      
	    	}
	   	data = dataBuilder.result();
	}
	
	public static def distSequential(data:Array[Int]{rank==1}, start:int, length:int):Array[Int]{
		return map(data);
        }		      
	
	public static def doParallelMultiplePlaces():Array[Int]{
	       val numInts:Int = 100;
	       val numPlaces = 3;
               val inputsPerPlace:Int = 100;
	       val results:Array[Array[Int]] = new Array[Array[Int]](Place.MAX_PLACES,(i:Int)=>new Array[Int](10));
	       val D = Dist.makeUnique();
	       val b:Array[Int] = [9,8,7,6,5,4,3,2,1,0];
	       val c:Array[Int] = [20,19,18,17,16,15,14,13,12,11,10];
	       val e:Array[Int] = [31,30,29,28,27,26,25,24,23,22,21];
	       val a = new Array[Array[Int]](numPlaces);

	       finish for (p in Place.places()) {
	       	       val myA = a(p.id);

		       async at(p) {
		       	     if(p.id == 0) {Console.OUT.print("Before: ");compute(map(b));val x = map(b);val str = compute(x);Console.OUT.println("After: "+str);}
			     if(p.id ==	1) {Console.OUT.print("Before: ");compute(map(c));val x = map(c);val str = compute(x);Console.OUT.println("After: "+str);}
			     if(p.id ==	2) {Console.OUT.print("Before: ");compute(map(e));val x = map(e);val str = compute(x);Console.OUT.println("After: "+str);}
	       		     }
			    
	           }
		  
	           var accumulator:Array[Int] = reduce(a(0),a(1));
		   accumulator = reduce(accumulator,a(2));
	    	   return accumulator;
	}

	public static def compute(data:Array[Int]) {
	       show(data);
	       var str:String = data.toString();
	       return str;
	}

	
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
	
	public static def mergeReduce(left:Array[Int],right:Array[Int]):Array[Int]{
	       val N = left.size + right.size;
	       var result:Array[Int] = new Array[Int](N);
	       var i:Int = 0, leftPos:Int = 0, rightPos:Int = 0, leftSize:Int = left.size, rightSize:Int = right.size;
	       while(leftPos < leftSize && rightPos < rightSize)
	           result(i++) = (left(leftPos) <= right(rightPos))
		   	       ? left(leftPos++)
			       : right(rightPos++);
	       while (leftPos < leftSize)
	           result(i++) = left(leftPos++);
	       while (rightPos < rightSize)
	           result(i++) = right(rightPos++);
	       return result;
	 }	
	
	// stably merge a[lo..m] with a[m+1..hi] using aux[lo..hi]
	public static def merge(a:Array[Int], aux:Array[Int], lo:Int, m:Int, hi:Int){
		// copy to aux[]
		Array.copy(a,0,aux,0,a.size);
		
		// merge back to a[]
		var i:Int = lo;
		var j:Int = m+1;
		for(var k:Int = lo; k <= hi; k++){
			if (i > m)		  a(k) = aux(j++);
			else if (j > hi) 	  a(k) = aux(i++);
			else if (aux(j) < aux(i)) a(k) = aux(j++);
			else                      a(k) = aux(i++);
		}
		
	}
	
	public static def map(arg:Array[Int]):Array[Int]{
	       val result = sort(arg);
	       return result;
	}
	
	public static def reduce(arg1:Array[Int], arg2:Array[Int]):Array[Int]{     
	       val result = mergeReduce(arg1,arg2);
	       return result;
	}

	private static def isSorted(a:Array[Int]):Boolean{
		for(var i:Int = 1; i < a.size; i++)
			if (a(i) < a(i-1)) return false;
		return true;
	}
	
	// bottom-up mergesort
	public static def sort(a:Array[Int]):Array[Int]{
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
		return aux;
	}
	
	// print array to standard output
	private static def show(a:Array[Int]){
		for(var i:Int = 0; i < a.size; i++){
			Console.OUT.print(a(i)+" ");
		}
		Console.OUT.println();
	}	
/*
    	public def demonstrateSequential() {
	       distributor.distributeSequential(this, data);
	}
 
	public def demonstrateParallel(numAsyncs:Int) {
               distributor.distributeParallel(this.distributor, data, numAsyncs);
    	}
*/
	/*
	public def demonstrateMultiplePlaces(numAsyncs:Int, numPlaces:Int) {
	       distributor.distributeMultiplePlaces(this, data,numAsyncs,numPlaces);
	}
	*/
   
	public static def main(Array[String]) {
	/*
    	       val mapper:DistributedSort = new DistributedSort();
	       mapper.demonstrateSequential();
	       start = Timer.milliTime();
	       mapper.demonstrateSequential();
	       end = Timer.milliTime();
	       val sequentialTime = end - start;
	       Console.OUT.println("Sequential map reduce benchmark completed in "+
	       			    sequentialTime+" milliseconds");
	*/
	       
	       val a = [5,6,1,3,8,7,4,11];
	       val mapper:DistributedSort = new DistributedSort();
    	      /*
	       val result = distSequential(mapper.data,0,mapper.data.size);
    	       Console.OUT.print("The sorted array: ");
	       show(result);
	       val merged = reduce(result,result);
	       Console.OUT.print("The merged array: ");
	       show(merged);
	       */

	      
	              val multiple = doParallelMultiplePlaces();
		      show(multiple);

	      
    }
    

}

