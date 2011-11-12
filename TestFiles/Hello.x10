
public class HelloWorld { 
  public static def main(Rail[String]) {
    for (p in Dist.makeUnique()) at (p)
      Console.OUT.println("Hello World");
  }
}