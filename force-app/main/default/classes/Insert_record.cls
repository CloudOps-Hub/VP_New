@isTest
public class Insert_record {
    public static testmethod void main(){
        Employee__c obj = new Employee__c();
        obj.Ename__c = 'Arun Kuchi';
        obj.Salary__c = 10000;
        obj.Deptno__c = 10;
        obj.Job__c = 'Manager';
        Insert obj;         
    }

}