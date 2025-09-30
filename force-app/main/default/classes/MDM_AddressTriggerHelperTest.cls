/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   05-19-2021   Dhruv Agrawal   Initial Version
**/


@isTest
public class MDM_AddressTriggerHelperTest {
    
    @testSetup static void setup() {  
        MDM_TestDataFactory.dqiAttributeTestData();  
        MDM_TestDataFactory.createAddress(); 
        MDM_TestDataFactory.createContact(); 
    }
    
    @isTest
    public static void addresstTest(){
        Test.startTest();
        MDM_Address__c addressRecord = new MDM_Address__c();
        addressRecord.MDM_Address_2__c = 'Pune';
        insert addressRecord;
        
        MDM_Contact__c contact = [SELECT Id,Name, MDM_Email__c, MDM_DQI_Score__c, MDM_DQI_Description__c
                                  FROM MDM_Contact__c];
        MDM_Address__c address = [SELECT Name, MDM_City__c, MDM_DQI_Score__c, MDM_DQI_Description__c
                                  FROM MDM_Address__c Where MDM_Address_2__c != 'Pune'];
        system.assert(address.Id != null, 'address inserted successfully');
        address.MDM_Contact__c = contact.id;
        update address;
        
        address.MDM_City__c = 'Pune';
        update address;        
        
        List<MDM_Address__c> addressUpdate = [SELECT Name, MDM_City__c, MDM_DQI_Score__c, MDM_DQI_Description__c
                                              FROM MDM_Address__c
                                              WHERE ID =: address.Id];
        
        if(addressUpdate.size()>0) {
            System.assertEquals(100.0, addressUpdate[0].MDM_DQI_Score__c, 'All fields are Present');
        }
        
        delete address;
        
        Test.stopTest();
        
    }
    
}