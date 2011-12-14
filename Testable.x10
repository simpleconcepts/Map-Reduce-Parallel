interface Testable {
    public def demonstrateSequential():void;
    public def demonstrateParallel(numAsyncs:Int):void;
    public def describe():String;
    public def demonstrateMultiplePlaces(numAsyncs:Int,numPlaces:Int):void;
}
