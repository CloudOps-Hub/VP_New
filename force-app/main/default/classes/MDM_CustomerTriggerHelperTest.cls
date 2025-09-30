/**
 * @description       : Test class for MDM_CustomerTriggerHelper.cls
 * @author            : Komal Sonsale
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   04-26-2021   Komal Sonsale   Initial Version
**/

@isTest
public class MDM_CustomerTriggerHelperTest {
    
    @testSetup static void setup() {  
        MDM_TestDataFactory.dqiAttributeTestData(); 
        MDM_TestDataFactory.createTestApplicationConfig();
        /*MDM_Application_Configuration__c appConfig = new MDM_Application_Configuration__c();
        appconfig.MDM_Allow_Auto_Merge__c = true;
        appconfig.MDM_Allow_Platform_Events__c = true;
        appconfig.MDM_Platfrom_Event_Batch_Size__c = '1';
        appconfig.Name = 'Test Config';
        insert appConfig;*/
    }
    
    @isTest
    public static void testCalculateDQIScore(){
        Test.startTest();

        MDM_Customer__c customer = new MDM_Customer__c(
            Name = 'MDM Pvt. Ltd.'
        );
        insert customer;
        system.assert(customer.Id != null, 'customer inserted successfully');
        
        customer.MDM_DOI_or_DOB__c = System.today();
        update customer;
        
		List<MDM_Customer__c> customerUpdate = [SELECT Name, MDM_DOI_or_DOB__c, MDM_Email__c, MDM_DQI_Score__c, MDM_DQI_Description__c
                                        FROM MDM_Customer__c
                                        WHERE ID =: customer.Id];
        
        if(customerUpdate.size()>0) {
        	System.assertEquals(89, customerUpdate[0].MDM_DQI_Score__c, 'All fields are Present');
        }
        Test.stopTest();
    }
}