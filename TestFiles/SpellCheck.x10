import x10.io.File;
import x10.util.Random;

/**
 ** A homemade spellchecker
 **
 ** Facilities to read a dictionary of words are provided. You
 ** must implement check().
 **/
public class SpellCheck {
    var dict:Rail[String];
    var nwords:Int; 
    var serialTime:Long=0;
    var parallelTime:Long=0;
    
    static val Meg = 1000*1000;

    /* Constructor */
    public def this(dictionary:Rail[String]) {
    	
    	dict = dictionary;
    	nwords = dict.size ;
    	serialTime = 0; 
    	parallelTime = 0;
    }
    
    /* Factory method that reads in a dictionary */
    public static def make(filename:String) : SpellCheck {
    	
    	Console.OUT.println("Reading dictionary from: " + filename);
    	
    	try { 
    		val I  = new File(filename);
    		var numwords:Int = 0;
    		
    		for (line in I.lines()) 
    			numwords++;
    		
    		Console.OUT.println(numwords + " in dictionary");
    		
    		val dict = new Rail[String](numwords,"");
    		var i:Int = 0;
    		for (line in I.lines()) {
    			// Note that we are converting all words to lowercase to simplify binary searching
    			dict(i) = line.trim().toLowerCase(); 
    			i++;
    		}
    		
    		val s = new SpellCheck(dict); 
    		return s;
    	} 
    	catch (  e2 : x10.io.FileNotFoundException ) { 
    		Console.OUT.println("ERROR - File not found : " + filename);
    		return null;
    	}
    	
    }
    
    /* Methods to keep track of time */
    public def timerReset() { 
    	serialTime = 0; 
    	parallelTime = 0;
    	
    }
    public def serialTime() : Long { 
    	
    	return serialTime; 
    }
    public def parallelTime() : Long { 
    	return parallelTime; 
    }
    
    
    public def check(word:String):Boolean {
    	/**
    	 * * Implement a capitalization-insensitive spellcheck here.
    	 * */
    	
    	var low:Int = 0;
    	var high:Int = dict.size - 1;
    	
    	while (low <= high){
    		
    		var mid:Int = (low + high)/2;
    		
    		if(dict(mid).compareToIgnoreCase(word) < 0)
    			low = mid + 1;
    		else if(dict(mid).compareToIgnoreCase(word) > 0)
    			high = mid - 1;
    		else if (dict(mid).compareToIgnoreCase(word) == 0)
    			return true;
    	}
    	
    			return false;
    		
}
    	
    	
    	
    	
    	

	
    /** Search the dictionary in sequence */
    public def runSequential(words:Rail[String],serialResult:Rail[Boolean]) { 
    	
    	var correct:Boolean = false;
    	
    	val time = System.nanoTime();
    	
    	for(i in 0..(words.size - 1)){
    		
    		correct = check(words(i));
    		serialResult(i) = correct;

	}
    	
    	serialTime += (System.nanoTime()-time)/Meg;

    	
    }
    
    public def runChunk(words:Rail[String], parallelResult:Rail[Boolean], range:IntRange) {
//	Console.OUT.println("CHUNK: (" + range.min + "," + range.max + ") start = " + System.nanoTime()/Meg);
	for (var i:Int = range.min; i <= range.max; i++) {
	    parallelResult(i) = check(words(i));
	}
//	Console.OUT.println("CHUNK: (" + range.min + "," + range.max + ") finish = " + System.nanoTime()/Meg);
    }
    

    /** Search the dictionary in parallel */
    public def runInParallel(words:Rail[String], parallelResult:Rail[Boolean], numAsyncs:Int) { 
    	
    	val time = System.nanoTime();
/*	Console.OUT.println("start: " + time); */
	//    	var ranges:Rail[IntRange];
	//    	var currentRange:IntRange;
    	
	//    	val N = words.size;
	//    	val nPerThread = N/numAsyncs;
	//    	val railSize:Int = words.size;
    	val ranges = makeRanges(numAsyncs, words.size);
    	
	finish for(k in 0..(numAsyncs-1)) async {
		runChunk(words,parallelResult,ranges(k));
	}
    	
    	parallelTime += (System.nanoTime()-time)/Meg;
    }
    

    
    
    /** Reads in <n> words randomly from the dictionary, then randomly 
     chooses <percentBad> victims and corrupts them */
    public def populateWords(n:Int, percentBad:Float, seed:Int ) : Array[String] { 
    	
    	val r = new Random(seed); 
    	
    	var strArray : Array[String] = new Array[String](n);
    	var corrupted : Array[Boolean] = new Array[Boolean](n,false); 
    	
    	for ( i in (0..(n-1)) ) 
    		strArray(i) = dict(r.nextInt(nwords)); 
    	
    	val numbad = (strArray.size * percentBad * 0.01) as Int; 
    	var victim:Int = 0;  
    	
    	Console.OUT.println("num bad = " + numbad ) ; 
    	
    	var i:Int = 0; 
    	while ( i < numbad ) { 
    		victim = r.nextInt(strArray.size);
    		if ( !corrupted(victim) ) { 
    			corrupted(victim) = true;
    			strArray(victim) = strArray(victim) + "@"; 
    			i++; 
    		} 
    	}
    	
    	return strArray;
    	
    }

    public static def makeRanges(numAsyncs:Int, railSize:Int):Rail[IntRange]{
    	
    	var ranges:Rail[IntRange];
    	var startIndex:Int;
    	var endIndex:Int;
    	var r:IntRange;

    	val nPerThread = railSize/numAsyncs;
    	val remainder = railSize%numAsyncs;
    	
    	ranges = new Rail[IntRange](numAsyncs);
    	
    	for(i in 0..(numAsyncs -1)){
    		
    		if(i==0){
    			startIndex = 0;
    			endIndex = nPerThread - 1;
    		}
    		else if(i == (numAsyncs - 1)){
    			startIndex = i*nPerThread;
    			endIndex = railSize - 1;
    		}
    		else{
    			startIndex = i*nPerThread;
    			endIndex =  i*nPerThread + nPerThread - 1;
    		}
    		
    		r = new IntRange(startIndex, endIndex);
    		
	//	Print Start and End Indices For Debugging
/* Console.OUT.println("Start Index: "+ startIndex+"End Index:  "+endIndex);*/
		
    		ranges(i) = r;
    		
    	}
    	
    	return ranges;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /** print number of misspelled words **/
    public static def printResults(words:Array[String],result:Array[Boolean]) { 
    	
    	var nmiss : Int = 0; 
    	for ( i in (0..(result.size-1)) ) { 
    		if ( !result(i) ) { 
    			
    			Console.OUT.println("Misspeeled Word : " + words(i)); 
    			nmiss++; 
    		}     		
    	}
    	Console.OUT.println(nmiss + " misspelled words " ) ;
    }
    
    
    /** Compares sequential to parallel result to validate **/
    public static def compareSeqToParallel(words:Array[String],seqResult:Array[Boolean], parallelResult:Array[Boolean] ) : Boolean { 
    	var count:Int = 0;
    	if ( seqResult.size != parallelResult.size ) { 
    		Console.OUT.println( "FAILED : parallelResult array is not sized the same as seqArray " ) ; 
    		return false;
    	}
    	
    	for ( i in (0..(seqResult.size-1)) ) { 
    		if ( seqResult(i) != parallelResult(i) ) { 
    			Console.OUT.println( "FAILED : words(" + i + ") = " + words(i) + " did not match" );
			
    		//	return false;
    		}
    	}// end for
    	
    	Console.OUT.println( "PASSED!" ) ;
    	return true;
    }	


    /** Main **/
    public static def main( args:Array[String] ) {
    	
    	if (args.size < 5) {
    		Console.OUT.println("Usage: SpellCheck <dictionary:String> <numWordsToCheck:Int> <percent_bad:Int> <num_trials> <num_asyncs> ");
    		return;
    	}
    	
    	val seed = 100;
    	
    	val dictionary = args(0); 
    	val n = Int.parseInt(args(1));
    	val percBad = Int.parseInt(args(2));
    	val numTrials = Int.parseInt(args(3));
    	val numAsyncs = Int.parseInt(args(4));
    	
    	if ( (percBad < 0 ) || ( percBad > 100 )) { 
    		Console.OUT.println("Percent Bad has to be b/w 0 and 100. Exiting ..." );  
    		return;
    	} 
    	
    	
    	Console.OUT.println( "Dictionary file : " + dictionary + " , " + " num_words_to_check : " + n + ", percent_bad : " + percBad + ", num_trials : " + numTrials + ", num_asyncs : " + numAsyncs  );   
    	
    	
    	val checker = SpellCheck.make(dictionary); 
    	if ( checker == null )  return;
    	
    	Console.OUT.println("number of words to check = " + n) ; 
    	
    	val wordsToCheck = checker.populateWords(n,percBad,seed); 
    	
    	val seqResult =  new Rail[Boolean](n,false); 
    	val parallelResult = new Rail[Boolean](n,false); 
    	
    	// warmup run 
    	Console.OUT.println( "Warmup Run, serial ... " );
    	checker.runSequential(wordsToCheck,seqResult);
    	
    	Console.OUT.println( "Warmup Run, parallel ... " );
    	checker.runInParallel(wordsToCheck,parallelResult,numAsyncs);
    	
    	// For debugging
    	//printResults(wordsToCheck,seqResult); 
    	
    	// Verify the correctness
    	if ( ! compareSeqToParallel( wordsToCheck, seqResult, parallelResult ) ) 
    	{
    		Console.OUT.println( " Correctness test failed. Bye! " );
    		return;
    	}
    	
    	
    	checker.timerReset(); 
    	
    	
    	Console.OUT.println( " Performance Runs ... " );
    	
    	for ( t in 0..(numTrials-1) ) { 
    		Console.OUT.println("Trial " + t + "...") ; 
    		checker.runSequential(wordsToCheck,seqResult); 
    		checker.runInParallel(wordsToCheck,parallelResult,numAsyncs); 
    	}
    	
    	var serialNumber:Long = checker.serialTime()/(numTrials as Long);
    	var parallelNumber:Long = checker.parallelTime()/(numTrials as Long) ; 
    	var speedup:Long = serialNumber/ parallelNumber ; 
    	
    	Console.OUT.println("[Done.] Over " + numTrials + " trials, average time" 
    			+ " to compute serially is " + serialNumber
    			+ ", and to compute in parallel is " + parallelNumber 		);
    	
    	
    }
}