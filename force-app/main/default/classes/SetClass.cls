@isTest
public class SetClass {
    public static testmethod void main(){
        Set<Integer> obj = new Set<Integer>();
        obj.add(15);//0 index vaalue 
        obj.add(20);//1
        obj.add(5);//2
        obj.add(3);//3
        obj.add(99);//4
        system.debug(obj);//ascending order automatically
        integer s;
        s = obj.size();//size()counts the total elements in set 5
        system.debug('total values in the list' +s);//5
        Set<string> s1=new Set<string>();
        s1.add('item1');
        s1.add('item2');
        system.debug(s1);//item1,item2
        Set<string> s2=new Set<string>(s1);//set elements are copied from s1
        system.debug(s2);//item1,item2
        List<integer> ls=new List<integer>();
        ls.add(1);
        ls.add(2);
        system.debug(ls);//1,2
        Set<integer> s3=new Set<integer>(ls);//copied values from list
        system.debug(s3);//1,2   
        Set<string> myString=new Set<string>{'a','b'};
            Boolean result;
        result=myString.contains('z');//check values T F
        system.debug('the result is' +result);//false
        Set<string> myString1=new Set<string>{'a','b'};
            Set<string> sString=new Set<string>{'c'};
                Set<string> rString=new Set<string>{'a','b','c'};
                    boolean result2;
        myString1.addAll(sString);//this method copies the values from one to another
        system.debug(myString1);//a b c
        result2 = myString.containsAll(rString);
        System.debug('the result is' +result2);//true
        Set<integer> myset = new set<integer>();
        Boolean res;
        res = mySet.isEmpty();
        system.debug('the result is' +res);//true
        Set<integer> mySet1 = new set<integer>{1,2,3};
            List<integer> myList=new List<integer>{1,3};
        Boolean res1 = mySet1.removeAll(myList);
        system.debug('the result is' +res1);
    }
}