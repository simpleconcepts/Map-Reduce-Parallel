import x10.util.*;
import x10.io.InputStreamReader.*;
import x10.io.File;
import x10.io.ReaderIterator;
import x10.lang.String;

public class WordCount implements MapReduce[String,HashMap[String,Int]] {

       //results
       var serialMax: Int = 0;
       var parallelMax: Int = 0;
       var serialTime:Long = 0;
       var parallelTime:Long = 0;
       static val Meg = 1000*1000;

public def map(var arg:String):HashMap[String, Int] {
	val I = new File(arg);
	var linenumber:Int = 0;
	var map:HashMap[String,Int] = new HashMap[String,Int]();
	
	for(inputline in I.lines()){
		var line:String = inputline.trim().toLowerCase();
		var words:Rail[String] = line.split(" ");
		var length:Int = words.size;
		for(var i:Int = 0; i < length; i++){
			var obj:Box[Int] = map.get(words(i));
			var word:String = words(i);
			word = removePunctuation(word);
			if(obj == null){
			     map.put(word, 1);
			}else{
				var k:Int = obj.value + 1;
				map.put(words(i),k);
			}
			
		}
	}
	
	return map;	
}

       public def removePunctuation(input:String):String{

       var word:String = input;
       var acceptableChars:String = "abcdefghijlmnopqrstuvwxyz0123456789";
       var result:String = "";
       for(var i:Int = 0; i < input.length(); i++){
	       var ascii:Int = input.charAt(i).ord();
       	       if(!isNotPChar(ascii)){
	       	   result += input.charAt(i);
	        }
	}
	return word;
	}

	public def isNotPChar(input:Int):Boolean{
	       	var ascii:Int = input;	
		var isPChar:Boolean = false;

		if(ascii.operator>=(33) && ascii.operator<=(64)){
		    isPChar = true;
		    return isPChar;
		}
		else if (ascii.operator>=(94) && ascii.operator<=(96)){
		     isPChar = true;
		     return isPChar;
		}
		else if (ascii.operator>=(123) && ascii.operator<=(126)){
		     isPChar = true;
		     return isPChar;
		}
		else if (ascii.operator>=(48) && ascii.operator<=(57)){
		     isPChar = true;
		     return isPChar;
		}


		return isPChar;

	}


	public def runInParallel(numAsyncs:Int){
	
	val time = System.nanoTime();

	parallelTime += (System.nanoTime()-time)/Meg;

	} 

	/** helper for validating result **/

	public def compareSeqVsParallel(): Boolean{

	       return false;
	}

	public def runSequential(words:Rail[String],serialResult:Rail[Boolean]){

	val time = System.nanoTime();

	for(var i:Int = 0; i < (words.size-1); i++){
	
	


	}

	serialTime += (System.nanoTime()-time)/Meg;

	}

	/** print words and frequencies **/
	public static def printResults(words:Map[String,Int]){




	}


public  def reduce(var arg1:x10.util.HashMap[x10.lang.String, x10.lang.Int], var arg2:x10.util.
		HashMap[x10.lang.String, x10.lang.Int]):x10.util.HashMap[x10.lang.String,
		                                                         x10.lang.Int] {

	// Think of Map1 as Left and Map2 and Right Circles of Venn Diagram
	var mergedMap:HashMap[String,Int] = new HashMap[String,Int]();
	var keysMapOne:Set[String] = arg1.keySet();
	var keysMapTwo:Set[String] = arg2.keySet();

	
	for(key in keysMapOne){
		val entryLeft:Box[Int] = arg1.get(key);

		if(keysMapTwo.contains(key)){
			var entryRight:Box[Int] = arg2.get(key);
			var value:Int = entryLeft.value + entryRight.value;
			arg2.remove(key);
			mergedMap.put(key,value);
		}else
			mergedMap.put(key,entryLeft.value);
	}
	
	/** Get New List After Removal **/
	
	keysMapTwo = arg2.keySet();

	for(key in keysMapTwo){
		var entryRight:Box[Int] = arg2.get(key);
		mergedMap.put(key, entryRight.value);
	}
	
	return mergedMap;
	}

	/** Methods for collecting timing numbers **/
	public def resetTimers(){
	       serialTime = 0;
	       parallelTime = 0;


	}

	public def serialTime(): Long{

	       return serialTime;

	}

	public def parallelTime() : Long{
	
		return parallelTime;
	}


	public static def main(args:Array[String]){

	Console.OUT.println("Hello World!");
	

	var start:Long;
	var end:Long;

	start = Timer.milliTime();
	end = Timer.milliTime();
	
	/** Map Function Test **/
	Console.OUT.println("Map Function Test...");
	val mapper:WordCount = new WordCount();

	var intermediate:HashMap[String,Int] = mapper.map("data/1.txt");
	var entries:Set[Map.Entry[String,Int]] = intermediate.entries();

	for(entry in entries){
	
		var key:String = entry.getKey();
		var value:Int = entry.getValue();
		Console.OUT.println("Key: "+key +" Value: "+value);
	   
	}

	Console.OUT.println();

	/** Reduce Function Test **/
	Console.OUT.println("Reduce Function Test...");
	Console.OUT.println();
	
	var intermediate2:HashMap[String,Int] = mapper.map("data/2.txt");
	var mergedMap:HashMap[String,Int] = mapper.reduce(intermediate, intermediate2);
	var mergedEntries:Set[Map.Entry[String,Int]] = mergedMap.entries();

	for(entry in mergedEntries){
	
		var key:String = entry.getKey();
		var value:Int = entry.getValue();
		Console.OUT.println("Key: "+key+ " Value: "+value);


	}	
	
	




	
	}



}

