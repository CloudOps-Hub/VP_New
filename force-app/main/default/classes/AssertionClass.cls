@isTest
public class AssertionClass {
    public static testmethod void main(){
        Integer num1,num2,result;
        num1=10;
        num2=5;
        //if condition false then it display error msg
        //System.assert(num2!=0,'Sorry we cannot devide number by 0');
        System.assertNotEquals(num2,0,'Sorry we cannot devide number by 0');
        System.assertEquals(num2,0,'Sorry we cannot devide number by 0');
        result = num1/num2;
        system.debug('result is' +result); 
    }

}