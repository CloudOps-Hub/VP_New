/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-27-2021   Dhruv Agrawal   Initial Version
**/
@isTest
public class MDM_CustomerRegistrationTriggerTest {
 /**  
* @description Provides test coverage for all methods of MDM_CustomerStagingTriggerHelper
	*/
     @testSetup static void setup() {  
        MDM_TestDataFactory.createTestApplicationConfig();
        MDM_TestDataFactory.createCustomerRegistration();
    }
    
    @isTest
    static void massApprovalTest() 
    {
        Test.startTest();
        
        MDM_Customer_Registration__c newCustomerRegistration = [SELECT ID, MDM_Account_Type__c, MDM_Processing_Status__c,
                                                               MDM_ContactAddress_JSON__c, MDM_Mass_Approval_Status__c
                                                               FROM MDM_Customer_Registration__c LIMIT 1];
        
        newCustomerRegistration.MDM_Mass_Approval_Status__c = 'Approved';
        update newCustomerRegistration;
        
        System.assertEquals('Approved', newCustomerRegistration.MDM_Mass_Approval_Status__c,'Status is approved');
      
        Test.stopTest();        
    }
 
}