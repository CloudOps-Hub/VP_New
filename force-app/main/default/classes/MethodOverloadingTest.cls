@isTest
public class MethodOverloadingTest {
    public static testmethod void main(){
        Integer res1, res2, res3;
        MethodOverLoading obj= new MethodOverLoading();
        obj.setValues(10,20,30);
        res1 = obj.addition();
        System.debug('the res1 value is '+res1);
        obj.setValues(40,20,10);
        res2 = obj.substraction();
        System.debug('the res1 value is '+res2);
        obj.setValues(10,20,30,40);
        res3 = obj.multiplication();
        System.debug('the res1 value is '+res3);
    }

}