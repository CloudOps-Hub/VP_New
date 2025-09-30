@isTest
public class MapClass {
    public static testmethod void main(){
        Map<integer,string> m1 = new Map<integer,string>();
        m1.put(1,'Jashu');
        m1.put(2,'Sandy');
        m1.put(3,'Rinku');
        m1.put(4,'raju');
        m1.put(5,'shiva');
        m1.put(6,'balu');
        m1.put(4,'ramu');
        System.debug(m1);
        Map<integer,string> m2 = new Map<integer,string>(m1);
        system.debug(m2);
        m1.remove(6);
        system.debug(m1);
        m2.clear();
        system.debug(m2);
        Set<integer> obj1 = new Set<integer>();
        obj1=m1.keySet();
        system.debug(obj1);
        List<string> obj2= new List<string>();
        obj2 = m1.values();
        system.debug(obj2);
        string k=m1.get(2);
        system.debug(k);
    }

}