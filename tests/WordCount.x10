import x10.util.*;
import x10.io.*;
import x10.lang.*;

public class TestClass implements MapReduce[String,HashMap[String,Int]], Testable {
        private val distributor:MapReduceArray[String, HashMap[String, Int]];
        private val data:Array[String];
   
	public def this() {
	       distributor = new MapReduceArray[String,HashMap[String,Int]]();
	       val numFiles = 37;
	       val dataBuilder:ArrayBuilder[String] = new ArrayBuilder[String](numFiles);
	       for(i in 0..(numFiles)){
	       	     dataBuilder.add("tests/two-cities/data/"+i+".txt");
	       }
	       data = dataBuilder.result();
	}

	public def map(var arg:String):HashMap[String, Int] {
	       var I:File;
	       var map:HashMap[String,Int] = new HashMap[String,Int]();
	       var lines:ReaderIterator[String];
	       try {
	       	   I = new File(arg);
		   lines = I.lines();
	       } catch (FileNotFoundException) {
	       	  return map;
	       }
	       var linenumber:Int = 0;
	      
	       for(inputline in lines){
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
		if(ascii >= 33 && ascii <= 64){
		    isPChar = true;
		    return isPChar;
		}
		else if (ascii >=(94) && ascii <=(96)){
		     isPChar = true;
		     return isPChar;
		}
		else if (ascii >=(123) && ascii <=(126)){
		     isPChar = true;
		     return isPChar;
		}
		else if (ascii >=(48) && ascii <=(57)){
		     isPChar = true;
		     return isPChar;
		}
		return isPChar;
	}

	public  def reduce(var arg1:HashMap[String,Int], var arg2:HashMap[String,Int]):HashMap[String, Int] {
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
		keysMapTwo = arg2.keySet();
		for(key in keysMapTwo){
		var entryRight:Box[Int] = arg2.get(key);
		mergedMap.put(key, entryRight.value);
	}
		return mergedMap;
	}

	public def demonstrateSequential() {
	       distributor.distributeSequential(this, data);
	}

	public def demonstrateParallel(numAsyncs:Int) {
	       distributor.distributeParallel(this, data, numAsyncs);
	}
	
	public def demonstrateMultiplePlaces(numAsyncs:Int,numPlaces:Int) {
	       distributor.distributeMultiplePlaces(this,data,numAsyncs,numPlaces);
	}

        public def describe() {
            return "Word Count - A Tale of Two Cities";
        }
}

