import x10.io.File;
import x10.util.Random;
import x10.util.*;
import x10.lang.*;

public class CharFrequency {

       var dict:Rail[String];
       var nwords:Int;
       
       public def this(dictionary:Rail[String]){

       dict = dictionary;
       nwords = dict.size;
      
       }

       public static def make(filename:String): CharFrequency {


       try {
		val I = new File(filename);
		var numwords:Int = 0;
		
		for(line in I.lines())
			 numwords++;

		Console.OUT.println(numwords + " in dictionary");

		val dict = new Rail[String](numwords,"");
		var i:Int = 0;
		for (line in I.lines()) {
		// Note that we are converting all words to lowercase to simplify binary searching
		dict(i) = line.trim().toLowerCase();
		i++;

		}
		
		val s = new CharFrequency(dict);
		return s;

	}
	catch (e2 : x10.io.FileNotFoundException ){
	      Console.OUT.println("ERROR - File not found : " + filename);
	      return null;

       }



}      

       
       public static def map(arg:String):Array[Int]{

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

       }// end for

       for(var j:Int = 0; j < map.size; j++){

       if(map(j) > 0){

       var c:Char = Char.operator_as(j);      
       Console.OUT.println(c +": "+map(j));
       
       }



       }
       


       return map;

       }



	public static def main(args:Array[String]){


//	val dictionary = "/usr/share/dict/words";
	val dictionary = "input.txt";
//	val checker = CharFrequency.make(dictionary);
	val checker = CharFrequency.map(dictionary);	


	}


}// end class 




