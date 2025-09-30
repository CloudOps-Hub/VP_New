@isTest
public class Update_class {
    public static testmethod void main(){
        List <Employee__c> obj = new List<Employee__c>();
        obj = [select Salary__c from Employee__c];
        for(Employee__c er : obj){
            er.salary__c+=10000;
        }
        Update obj;
    }

}