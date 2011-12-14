import x10.io.File;
import x10.util.Random;
import x10.util.ArrayBuilder;
/**
 * 
 * Distributed Bottom-Up MergeSort with MapReduce
 * Source:http://algs4.cs.princeton.edu/22mergesort/MergeBU.java.html
 *
*/

public class TestClass implements MapReduce[Array[Int],Array[Int]], Testable {
	private val distributor:MapReduceArray[Array[Int], Array[Int]];
	private val data:Array[Array[Int]];
	
	public def this(inputSize:Int,numAsyncs:Int){
	       distributor = new MapReduceArray[Array[Int], Array[Int]]();
	       val numSets = 15;
	       val numInts = inputSize;
	       var temp:Array[Int];
	       val dataBuilder:ArrayBuilder[Array[Int]] = new ArrayBuilder[Array[Int]](numSets);
	       for(var j:Int = 0; j < numSets; j++){
	       	       temp = new Array[Int](numInts);
		       val rand:Random = new Random(37*j);
		       for(var i:Int = 0; i < numInts; i++){
		       	       temp(i) = rand.nextInt();
			  }
		       dataBuilder.add(temp);
		  }
		  data = dataBuilder.result();	  
	} 
	
	public def this(){
	    distributor = new MapReduceArray[Array[Int], Array[Int]]();
	    val numSets = 15;
	    val numInts = 1000;
	    var temp:Array[Int];
	    val dataBuilder:ArrayBuilder[Array[Int]] = new ArrayBuilder[Array[Int]](numSets);
	    for(var j:Int = 0; j < numSets; j++){
	        temp = new Array[Int](numInts);
		val rand:Random = new Random(37*j);
	        for(var i:Int = 0; i < numInts; i++){
	            temp(i) = rand.nextInt();
	    	}
	        dataBuilder.add(temp);	
	    }
	    data = dataBuilder.result();
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
	
	public def map(arg:Array[Int]):Array[Int]{
	       val result = sort(arg);

	       return result;
	}
	
	public def reduce(arg1:Array[Int], arg2:Array[Int]):Array[Int]{     
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
		//assert isSorted(a);
		return aux;
	}
	
	// print array to standard output
	private static def show(a:Array[Int]){
		for(var i:Int = 0; i < a.size; i++){
			Console.OUT.print(a(i)+" ");
		}
		Console.OUT.println();
	}	

    	public def demonstrateSequential() {
               val result = data(0);
	       Console.OUT.println("Result Size: "+result.size);
    	       Console.OUT.println("Size of Data: "+data.size);
	       distributor.distributeSequential(this, data);
	}
    
	public def demonstrateParallel(numAsyncs:Int) {
               distributor.distributeParallel(this, data, numAsyncs);
    	}
	
	public def demonstrateMultiplePlaces(numAsyncs:Int, numPlaces:Int) {
	       distributor.distributeMultiplePlaces(this, data,numAsyncs,numPlaces);
	}
	
    /* 
	public static def main(Array[String]) {
    	       val a = [5,6,1,3,8,7,4,11];
    	       val result = map(a);
    	       Console.OUT.print("The sorted array: ");
	       show(result);
	       val merged = reduce(a,a);
	       Console.OUT.print("The merged array: ");
	       show(merged);
    }
    */

    public def describe() {
        return "Distributed Sort";
    }
}

