import x10.lang.Math.*;
import x10.util.ArrayList;



public class QuadraticSieve {
	
	public static def factorBaseSize():Int{
		val log2N:Int = 32;
		val lnN:Double = log2N*Math.log(2.0);
		val lnlnN:Double = Math.log(lnN);
		val base:Double = Math.exp(Math.sqrt(lnN * lnlnN));
		val exponent:Double = Math.sqrt(2)/4;
		val size:Double = Math.pow(base,exponent);
		return Int.operator_as(size);
	}
	
	public static def factorBase(N:Int):Array[Int]{
		var size:Int = 32;	
		var a:Array[Int] = new Array[Int](size);
		var numPrimes:Int = 0;
		var p:Int = 2;
		
		do{
			if(isPrimeByTrialDivision(p) && legendreSymbol(N,p) == 1 ){
				a(numPrimes) = p;
				Console.OUT.println("p: "+p);
				numPrimes++;
			}
			p = p + 1;
		}while(numPrimes < 3); 
		 
		return a;
	}
	
		
	public static def isPrimeByTrialDivision(n:Int):Boolean {
		if(n < 2) return false;
		if(n == 2 || n ==3) return true;
		if (n%2 == 0 || n%3 == 0) return false;
		var sqrtN:Double = Math.sqrt(n)+1;
		 for(var i:Double = 6D; i <= sqrtN; i = i + 6){
			 if((n.operator%(Int.operator_as(i-1)) == 0) || n%(Int.operator_as(i+1)) == 0){
				 return false;
			 }
		 }
		return true;  
	}
	
	
	public static def legendreSymbol(a:Int,p:Int):Int{
		if(a.operator%(p) == 0){
			return 0;
		}
		var exponent:Int = p ;
		exponent = exponent/2;
		val result = Int.operator_as(Math.pow(a,exponent)%p); //a.operator%(Int.operator_as(Math.pow(exponent,p)));
		
		if(result == 1){
			return 1;
		}else if (result == p - 1){
			return -1;
		}else
			return 0;
	}
	
	
	
	
	
	
    public static def main(args: Array[String]) {
        
    	val N = 1559;
    	
    	/* Test #1 isPrimeByTrialDivision
    	 * Input: 1559 
    	 * Output (Expected): true
    	 */
    	
    	Console.OUT.println("1159"+": "+isPrimeByTrialDivision(1559));
    	
    	/* Test #2 legendreSymbol
    	 * Input:87463 2
    	 * Output: 1
    	 */
    	Console.OUT.println(legendreSymbol(87463, 13));
    	
    	//val factorArray = factorBase(87463);
    	for(var i:Int = 0; i < 10; i++){
    		//Console.OUT.println(factorArray(i));
    	}

        
    }
}