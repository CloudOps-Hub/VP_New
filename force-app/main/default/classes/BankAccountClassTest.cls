@isTest
public class BankAccountClassTest {
    public static testmethod void main(){
        BankAccountClass cust1 = new BankAccountClass();
        cust1.getValues();
        cust1.setValues(101, 'Raj',10000);     
        cust1.getValues();
        cust1.deposit(10000);
        cust1.balance();
        cust1.withdraw(3000);
        cust1.balance();
        cust1.getValues();
        BankAccountClass.getCount();       
    
    BankAccountClass cust2 = new BankAccountClass();
        cust2.getValues();
        cust2.setValues(102, 'Ram',20000);     
        cust2.getValues();
        cust2.deposit(14000);
        cust2.balance();
        cust2.withdraw(5000);
        cust2.balance();
        cust2.getValues();
        BankAccountClass.getCount();
    }
}