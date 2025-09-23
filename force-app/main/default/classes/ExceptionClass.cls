@isTest
public class ExceptionClass {
    public static testmethod void main(){
        Integer num1,num2,num3,result;
        try{
            result = num1+num2;
        }
        catch(exception e){
            system.debug('soryy we cannot operations on null');
        }
        num1 =10;
        num2 =0;
        try{
        result = num1/num2;
        }
        catch(exception e){
            system.debug('cannot devided by 0.');
        }
            
    }

}