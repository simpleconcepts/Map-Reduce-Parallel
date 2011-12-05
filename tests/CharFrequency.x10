import x10.io.*;
import x10.util.*;
import x10.lang.*;

public class TestClass implements MapReduce[String , Array[Int]], Testable {
       
       private val distributor:MapReduceArray[String ,Array[Int]];
       private val data:Array[String];
       
       public def this(){
       	      distributor = new MapReduceArray[String , Array[Int]]();
	      val numFiles = 38;
	      val dataBuilder:ArrayBuilder[String] = new ArrayBuilder[String](numFiles);
	      for(i in 0..(numFiles)){
	      	    dataBuilder.add("two-cities/data/"+i+".txt");
	      }

	      data = dataBuilder.result();
       }
       
       public def map(arg:String):Array[Int]{
              val I = new File(arg);
      	      var map:Array[Int] = new Array[Int](256);

      	       for(var i:Int = 0; i < map.size; i++){
       	       	        map(i) = 0;
		}
      		for(inputline in I.lines()){
      		    var line:String = inputline.trim().toLowerCase();
      		    var charArray:Array[Char] = line.chars();    

		    for(var i:Int = 0; i < charArray.size; i++){
		    	    val c = charArray(i);
       			    val charValue:Int = c.ord(); 
			    var count:Int = map(c.ord());
			    count = count + 1;
			    map(c.ord()) = count;
       		    }
       		 }
       return map;
       }

       public def reduce(arg1:Array[Int], arg2:Array[Int]):Array[Int] {
       	      var combined:Array[Int] = new Array[Int](256);
       	      for(var i:Int = 0; i < arg1.size; i++){
	      	       combined(i) = arg1(i) + arg2(i);
       	      }
      	       return combined;       
       }
       
       public def demonstrateSequential() {
       	      distributor.distributeSequential(this, data);
       }

       public def demonstrateParallel(numAsyncs:Int) {
       	      distributor.distributeParallel(this, data, numAsyncs);
       }



       

}




