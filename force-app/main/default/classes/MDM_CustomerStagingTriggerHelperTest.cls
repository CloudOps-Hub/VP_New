/**
* @Class Name : MDM_CustomerStagingTriggerHelperTest
* @author : Sourabh
* @description This Class covers MDM_CustomerStagingTriggerHelper
*/
@isTest
public class MDM_CustomerStagingTriggerHelperTest {
    /**  
    * @description Provides test coverage for all methods of MDM_CustomerStagingTriggerHelper
    */
    @testSetup static void setup() {  
        MDM_TestDataFactory.createTestApplicationConfig();
        MDM_TestDataFactory.createCustomerRegistration();
    }
    
    @isTest
    static void updateCustomerRegistrationStatusTest() {
        Test.startTest();
        MDM_Customer_Registration__c custReg = [SELECT ID, Name, MDM_Account_Type__c, MDM_Processing_Status__c FROM MDM_Customer_Registration__c];        
        custReg.MDM_Processing_Status__c = 'Approved';
        update custReg;
        
        MDM_Customer_Staging__c custStaging = new MDM_Customer_Staging__c();
        custStaging.MDM_Processing_Status__c = 'New';
        custStaging.Name = custReg.Name;
        custStaging.MDM_Account_Type__c = custReg.MDM_Account_Type__c;
        insert custStaging;
        
        custReg.MDM_Customer_Staging__c = custStaging.Id;
        update custReg;
        
        MDM_Contact_Staging__c contact =new MDM_Contact_Staging__c(
            Name='Name',
            MDM_Customer_Staging__c =custStaging.id
        );
        insert contact;
        MDM_Contact_Staging__c contact1 =new MDM_Contact_Staging__c(
            Name='Name',
            MDM_Customer_Staging__c =custStaging.id
        );
        
        MDM_Address_Staging__c add = new MDM_Address_Staging__c(
            MDM_Customer_Staging__c =custStaging.id
        );
        insert add;
        MDM_Address_Staging__c add1 = new MDM_Address_Staging__c(
            MDM_Customer_Staging__c =custStaging.id
        );
        
        List<UserLicense> ulics=[Select u.Id From UserLicense u where Name like 'Chatter Free'];
        User users=[Select Id,Name,ProfileId from User u where u.ProfileId in (Select Id From Profile p where p.UserLicenseId in :ulics)limit 1];
        User runUsr = [select name, id, profileId from User where id = :users.id limit 1];
        List<MDM_Address_Staging__c> adrList = new List<MDM_Address_Staging__c>();
        adrList.add(add);
        adrList.add(add1);
        try{
            System.runAs(runUsr){
                insert adrList;	
            }
            insert adrList;
        }
        catch(Exception e) {
            system.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
        }
        List<MDM_Contact_Staging__c> conList = new List<MDM_Contact_Staging__c>();
        conList.add(contact);
        conList.add(contact1);
        try{
            System.runAs(runUsr){
                insert conList;	
            }
            insert conList;
        }
        catch(Exception e) {
            system.debug(LoggingLevel.ERROR, 'Exception: ' + e.getMessage());
        }

        custStaging.MDM_Processing_Status__c = 'Processed';
        update custStaging;

        List<MDM_Address_Staging__c> addressStagingList = new List<MDM_Address_Staging__c>();
        addressStagingList.add(add);

        List<MDM_Contact_Staging__c> contactStagingList = new List<MDM_Contact_Staging__c>();
        contactStagingList.add(contact);

        List<MDM_Customer_Staging__c> customerStagingList = new List<MDM_Customer_Staging__c>();
        customerStagingList.add(custStaging);
        
        MDM_SalesforceUitility.apexDMLHandler(addressStagingList, 'MDM_Address_Staging__c', 'delete');
        MDM_SalesforceUitility.apexDMLHandler(contactStagingList, 'MDM_Contact_Staging__c', 'delete');
        MDM_SalesforceUitility.apexDMLHandler(customerStagingList, 'MDM_Customer_Staging__c', 'delete');
        System.assertEquals(contact.MDM_Customer_Staging__c,custStaging.Id,'Contact is associated to Customer Staging');
        Test.stopTest();
    }
}