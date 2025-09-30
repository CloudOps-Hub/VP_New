@isTest
public class ListClass {
    public static testmethod void main(){
        List<Integer> obj = new List<Integer>();
        obj.add(10);//0 index vaalue 
        obj.add(20);//1
        obj.add(30);//2
        obj.add(30);//3
        obj.add(40);//4
        system.debug('debug' +obj);//horizantal order
        for(Integer v:obj){
            system.debug(v);//it prints all in vertical order
        }
        obj.add(2,500);//index number , value
        system.debug(obj);//10 20 500 30 40
        obj.sort();//ascending order//10 20 30 30 40 500
        system.debug(obj);
        integer n;
        n = obj.size();//size()counts the total elements in list 6
        system.debug('total values in the list' +n);
        boolean flag;//T or F
        flag = obj.isEmpty();
        system.debug('the value of flag is'+flag);//false
        Integer idx;
        idx = obj.indexOf(500);//index value of 5000
        system.debug('index of 500 is'+idx);//5
        Integer x;
        x=obj.get(2);//the index 2 value get
        system.debug('the index 2 value is' +x);
        
        List<Integer> obj1 = obj.clone();//create duplicate copy of list(obj)
        system.debug(obj1);//10 20 30 30 40 500
        obj1.clear();//it removes all the values
        system.debug(obj1);//{}
        try{
            system.debug(obj[30]);//exception array out of boundary exception
        }
        catch(exception e){
            system.debug('sorry wrong index number entered');
        }
        obj.remove(2);//removed 2 specific index value
        system.debug(obj);//10 20 30 40 500
    }
}