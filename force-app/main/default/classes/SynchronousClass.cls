//business class
public class SynchronousClass {
    //member method
    public void fun1(){
        System.debug('Iam in fun1 start');
       
        System.debug('Iam in fun1 ending');   
         fun2();
    }
  
    public static void fun2(){
        System.debug('Iam in fun2 starting');
                System.debug('Iam in fun2 ending');
    }
}