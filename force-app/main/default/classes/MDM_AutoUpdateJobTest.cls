/**
 * @description       : Test class for MDM_AutoUpdateJob
 * @author            : Rahul, Odion, Jordan, Dhruv
 * @group             : 
 * @last modified on  : 01/12/2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   01/12/2021   Dhruv   	Initial Version
 **/
@isTest
public with sharing class MDM_AutoUpdateJobTest {
	
    /**
     * @description Used for setting up data for Auto-Update Matching Rules 
     */
	@testSetup public static void setup() {
        List<MDM_Auto_Update_Matching_Rule__c> autoMatchingRuleList = new List<MDM_Auto_Update_Matching_Rule__c>();
        
        MDM_Auto_Update_Matching_Rule__c autoMatchingRule = new MDM_Auto_Update_Matching_Rule__c();
        autoMatchingRule.MDM_Active__c = true;
        autoMatchingRule.MDM_Field_Action__c =  '[{ "action" : "Update", "field" : "Name"},{ "action" : "Update", "field" : "MDM_Customer_Status__c"} ] ';
        autoMatchingRule.MDM_Object__c = 'MDM_SOURCE_CUSTOMER_STAGING__C';
        autoMatchingRule.MDM_Object_Label__c = 'Reference System IDs Staging (MDM_SOURCE_CUSTOMER_STAGING__C)';
        autoMatchingRule.MDM_Record_Action__c = '{"update_existing" : true,"create_new" : true}';
        autoMatchingRule.MDM_Active__c = true;
        autoMatchingRule.MDM_Default__c = false;
        autoMatchingRule.MDM_Matching_Key__c = '[ {"value" : null,"comparison" : "Any value","field" : "MDM_Source_System_Id__c"}' +
            ',{"field":"MDM_Source_System__c","comparison":"Has exact Value","value":"System"}]';
        insert autoMatchingRule;
        
        MDM_Auto_Update_Matching_Rule__c autoMatchingRule1 = new MDM_Auto_Update_Matching_Rule__c();
        autoMatchingRule1.MDM_Active__c = true;
        autoMatchingRule1.MDM_Field_Action__c =  '[{ "action" : "Update", "field" : "MDM_Address_1__c"},{ "action" : "Update", "field" : "MDM_Address_2__c"} ] ';
        autoMatchingRule1.MDM_Object__c = 'MDM_ADDRESS_STAGING__C';
        autoMatchingRule1.MDM_Object_Label__c = 'Address Staging (MDM_ADDRESS_STAGING__C)';
        autoMatchingRule1.MDM_Record_Action__c = '{"update_existing" : true,"create_new" : true}';
        autoMatchingRule1.MDM_Active__c = true;
        autoMatchingRule1.MDM_Default__c = true;
        autoMatchingRule1.MDM_Matching_Key__c = '[ {"value" : null,"comparison" : "Any value","field" : "MDM_Source_System_Address_Id__c"} ]';
        autoMatchingRuleList.add(autoMatchingRule1);
        
        MDM_Auto_Update_Matching_Rule__c autoMatchingRule3 = new MDM_Auto_Update_Matching_Rule__c();
        autoMatchingRule3.MDM_Active__c = true;
        autoMatchingRule3.MDM_Field_Action__c =  '[{ "action" : "Update", "field" : "Name"},{ "action" : "Update", "field" : "MDM_Email__c"} ] ';
        autoMatchingRule3.MDM_Object__c = 'MDM_CONTACT_STAGING__C';
        autoMatchingRule3.MDM_Object_Label__c = 'Contact Staging (MDM_CONTACT_STAGING__C)';
        autoMatchingRule3.MDM_Record_Action__c = '{"update_existing" : true,"create_new" : true}';
        autoMatchingRule3.MDM_Active__c = true;
        autoMatchingRule3.MDM_Default__c = false;
        autoMatchingRule3.MDM_Matching_Key__c = '[ {"value" : null,"comparison" : "Any value","field" : "MDM_Source_System_Contact_Id__c"},{"value" : null,"comparison" : "Any value","field" : "MDM_Phone__c"} ]';
        autoMatchingRuleList.add(autoMatchingRule3);
        
        MDM_Auto_Update_Matching_Rule__c autoMatchingRule4 = new MDM_Auto_Update_Matching_Rule__c();
        autoMatchingRule4.MDM_Active__c = true;
        autoMatchingRule4.MDM_Field_Action__c =  '[{ "action" : "Update", "field" : "MDM_Customer_Type__c"},{ "action" : "Append", "field" : "MDM_Description__c"},{ "action" : "Nullify", "field" : "MDM_Email__c"}]';
        autoMatchingRule4.MDM_Object__c = 'MDM_CUSTOMER_STAGING__C';
        autoMatchingRule4.MDM_Object_Label__c = 'Customer Staging (MDM_CUSTOMER_STAGING__C)	';
        autoMatchingRule4.MDM_Record_Action__c = '{"update_existing" : true,"create_new" : false}';
        autoMatchingRule4.MDM_Active__c = true;
        autoMatchingRule4.MDM_Default__c = false;
        autoMatchingRule4.MDM_Matching_Key__c = '[ {"value" : null,"comparison" : "Any value","field" : "Name"},{"value" : null,"comparison" : "Any value","field" : "MDM_DOI_or_DOB__c"}'+
            ',{"value" : null,"comparison" : "Any value","field" : "MDM_Source_LastModified__c"},{"field":"MDM_Account_Type__c","comparison":"Has exact Value","value":"Individual Account"}]';
        autoMatchingRuleList.add(autoMatchingRule4);
        
        insert autoMatchingRuleList;
		
        MDM_Customer__c customerRecord = new MDM_Customer__c(
            Name ='TestCustomer',
            MDM_Description__c = 'Description Test ',
            MDM_Account_Type__c = 'Individual Account',
            MDM_Customer_Status__c = 'Active',
            MDM_Email__c ='test@cree.com',
            MDM_Customer_Type__c = 'Prospect',
            MDM_DOI_or_DOB__c = System.today(),
            MDM_Source_LastModified__c = System.today() - 10
        );
        insert customerRecord;
		
		MDM_Contact__c contact1 = new MDM_Contact__c();
        contact1.Name = 'John';
        contact1.MDM_Fax__c = '0123456789';
        contact1.MDM_Phone__c = '0123456789';
        contact1.MDM_Customer__c = customerRecord.ID;
        contact1.MDM_Status__c = 'Active';
        contact1.MDM_Email__c = 'abc@def.com';
        contact1.MDM_Name_Suffix__c = 'Jr.';
        contact1.MDM_Title__c = 'Customer Success Manager';
        contact1.MDM_Source_System_Contact_Id__c = 45901;
        insert contact1;
        
        MDM_Address__c address1 = new MDM_Address__c();
        address1.MDM_Contact__c = contact1.ID;
        address1.MDM_Customer__c = customerRecord.ID;
        address1.MDM_Address_1__c = 'address1';
        address1.MDM_Address_2__c = 'address2';
        address1.MDM_Address_3__c = 'address3';
        address1.MDM_Address_Type__c = 'Permanent';
        address1.MDM_Fax__c = '0123456789';
        address1.MDM_Phone__c = '0123456789';
        address1.MDM_City__c = 'city';
        address1.MDM_State__c = 'state';
        address1.MDM_Country__c = 'country';
        address1.MDM_Country_Code__c = 'countryCode';
        address1.MDM_Extension__c = '0235';
        address1.MDM_Description_Notes__c = 'extension';
        address1.MDM_Zip_Code__c = 'zipcode';
        address1.MDM_Status__c = 'Active';
        address1.MDM_Source_System_Primary__c = true;
        address1.MDM_Source_System_Address_Id__c = 67890;
        insert address1;
        
        MDM_Source_Customer__c sourcecustomerRecord = new MDM_Source_Customer__c(
            Name = 'TestSourceCustomer',
            MDM_Customer__c = customerRecord.ID,
            MDM_Account_Type__c = 'Individual Account',
            MDM_is_Deleted__c = False,
            MDM_Source_System__c = 'System',
            MDM_Source_System_Id__c = '11111',
            MDM_Customer_Status__c = 'Active'
        );
        insert sourcecustomerRecord;
        
        MDM_Customer_Staging__c  custStaging = new MDM_Customer_Staging__c(
            Name ='TestCustomer',
            MDM_Account_Type__c ='Individual Account',
            MDM_Description__c = 'New Description',
            MDM_Customer_Status__c ='Active',
            MDM_Email__c ='test@cree.com',
            MDM_DOI_or_DOB__c = System.today(),
            MDM_Phone__c= '846293223',
            MDM_Customer_Type__c = 'Customer - Direct',
            MDM_Processing_Status__c = 'New',
            MDM_Is_AutoMerge__c = true,
            MDM_Source_LastModified__c = System.today() - 10
        );
        insert custStaging;
        
         MDM_Customer_Staging__c  custStaging1 = new MDM_Customer_Staging__c(
            Name ='TestCustomer1',
            MDM_Account_Type__c ='Individual Account',
             MDM_Description__c = 'New Description',
            MDM_Customer_Status__c ='Active',
            MDM_Email__c ='test@cree.com',
            MDM_DOI_or_DOB__c = System.today(),
            MDM_Phone__c= '846293223',
            MDM_Customer_Type__c = 'Customer - Direct',
            MDM_Processing_Status__c = 'New',
            MDM_Is_AutoMerge__c = true,
            MDM_Source_LastModified__c = System.today() - 10
        );
        insert custStaging1;
        
        MDM_Customer_Staging__c  custStaging2 = new MDM_Customer_Staging__c(
            Name ='TestCustomer1',
            MDM_Account_Type__c ='Business Account',
            MDM_Description__c = 'New Description',
            MDM_Customer_Status__c ='Active',
            MDM_Email__c ='test@cree.com',
            MDM_DOI_or_DOB__c = System.today(),
            MDM_Phone__c= '846293223',
            MDM_Customer_Type__c = 'Customer - Direct',
            MDM_Processing_Status__c = 'New',
            MDM_Is_AutoMerge__c = true,
            MDM_Source_LastModified__c = System.today() - 10
        );
        insert custStaging2;
        
        MDM_Contact_Staging__c  contactStaging = new MDM_Contact_Staging__c();
        contactStaging.Name ='CREE';
        contactStaging.MDM_Customer_Staging__c =custStaging.Id;
        contactStaging.MDM_Email__c = 'test@cree.com';
        contactStaging.MDM_Source_System_Contact_Id__c = 45901;
        contactStaging.MDM_Phone__c = '0123456789';
        insert contactStaging;
        
        MDM_Address_Staging__c  addressStaging = new MDM_Address_Staging__c();
        addressStaging.MDM_Address_1__c ='California';
        addressStaging.MDM_Customer_Staging__c =custStaging.Id;
        addressStaging.MDM_Country__c = 'USA';
        addressStaging.MDM_Email__c = 'test@cree.com';
        addressStaging.MDM_City__c ='Nagpur';
        addressStaging.MDM_Source_System_Address_Id__c = 67890;
        addressStaging.MDM_Address_Type__c = 'Permanent';
        insert addressStaging;
		
        MDM_Source_Customer_Staging__c sourceCustStaging = new MDM_Source_Customer_Staging__c(
            Name = 'TestSourceCustomerStaging',
            MDM_Customer_Staging__c = custStaging.ID,
            MDM_Account_Type__c = 'Individual Account',
            MDM_Source_System__c = 'System',
            MDM_Source_System_Id__c = '11111',
            MDM_Customer_Status__c = 'Active'
        );
        insert sourceCustStaging;
        
        MDM_Source_Customer_Staging__c sourceCustStaging1 = new MDM_Source_Customer_Staging__c(
            Name = 'TestSourceCustomerStaging1',
            MDM_Customer_Staging__c = custStaging.ID,
            MDM_Account_Type__c = 'Individual Account',
            MDM_Source_System__c = 'Admin',
            MDM_Source_System_Id__c = '111',
            MDM_Customer_Status__c = 'Active'
        );
        insert sourceCustStaging1;
	}
	
    /**
     * @description Test method for Auto-update
     */
	@isTest public static void goldenRecordsAutoUpdationServiceTest() {
        Test.startTest();
        MDM_AutoUpdateJob obj = new MDM_AutoUpdateJob();
        String bc = DataBase.executeBatch(obj,10);
        AsyncApexJob job;
        job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc
        ];
        System.assert(job.Id != null, 'Batch Executed Succesffylly');
        Test.stopTest();
    }
}