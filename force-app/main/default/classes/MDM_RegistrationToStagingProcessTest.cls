/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-12-2021   Priya Sharma   Initial Version
**/

@isTest
public class MDM_RegistrationToStagingProcessTest {
    @testSetup static void setup() {  
        MDM_TestDataFactory.createTestApplicationConfig();
    }
    @isTest
    static void massApprovalTest() 
    {
        Test.startTest();
        List<MDM_Customer_Registration__c> registrationList =new  List<MDM_Customer_Registration__c>();
        MDM_Customer_Registration__c customer = new MDM_Customer_Registration__c(
            //Name = 'Test 1', 
            MDM_Account_Type__c='Individual Account',
           MDM_ContactAddress_JSON__c='[{"addresses":[{"MDM_Address_1__c":"add1","MDM_City__c":"City"}], "contact":{"Name":"odz"}}]'
        );
        registrationList.add(customer);
        
        List<Database.SaveResult> result;
        result = Database.insert(registrationList);
       
        
        MDM_Contact_Registration__c newContact= new MDM_Contact_Registration__c(
            MDM_Contact_Registration_Name__c='test',
            MDM_Customer_Registration__c=registrationList[0].id
        );
        insert newContact;
        MDM_Address_Registration__c newAddress= new MDM_Address_Registration__c(
            MDM_Customer_Registration__c=registrationList[0].id,
            MDM_Contact_Registration__c=newContact.id
        );
        insert newAddress;
        customer.MDM_Processing_Status__c='Pending Approval';
        update customer;
        
        MDM_RegistrationToStagingProcessHelper.createCustomerStagings(new list<string>{registrationList[0].id});
        System.assertEquals( 1,[select id from MDM_Customer_Staging__c].size() , 'Inserted in customer staging');
        Test.stopTest();        
    }
}