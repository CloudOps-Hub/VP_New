/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-29-2021   Priya Sharma   Initial Version
**/

@isTest
public class MDM_ContactTriggerHelperTest {
     @testSetup static void setup() {  
        MDM_TestDataFactory.dqiAttributeTestData();  
		MDM_TestDataFactory.createContact();  
    }
    
    @isTest
    public static void contactTest(){
        Test.startTest();
         MDM_Data_Quality__c dataQuality = new MDM_Data_Quality__c(
             Name = 'Contact Email Data Quality',
             //MDM_Field_Label__c = 'Email',
             MDM_Field_API_Name__c = 'MDM_Fax__c',
             MDM_Object__c = 'MDM_Contact__c'
         );
         insert dataQuality; 
         MDM_DQI_Attribute__c dqi = new MDM_DQI_Attribute__c(
             Name = 'DQI Contact Fax',
             MDM_Data_Quality__c = dataQuality.Id ,
             MDM_Is_Active__c = true,
             MDM_Percentage__c = 0
         );
        insert dqi;
       	MDM_Contact__c contact = [SELECT Id,Name,  MDM_Fax__c,MDM_Email__c, MDM_DQI_Score__c, MDM_DQI_Description__c
                                        FROM MDM_Contact__c];
        contact.MDM_Email__c = null;
        contact.MDM_Fax__c = null;
        update contact;
        system.assert(contact.Id != null, 'contact.id is not NULL');
        contact.MDM_Email__c = 'xyz@gmail.com';
        contact.MDM_Fax__c = '13235551234';

        update contact;        
        List<MDM_Contact__c> contactUpdate = [SELECT Name, MDM_Email__c, MDM_DQI_Score__c, MDM_DQI_Description__c
                                        FROM MDM_Contact__c
                                        WHERE ID =: contact.Id];
        if(contactUpdate.size()>0) {
        	System.assertEquals(100.0, contactUpdate[0].MDM_DQI_Score__c, 'All fields are Present');
        }        
        delete contact;
        
        Test.stopTest();
        
        
    }
    
}