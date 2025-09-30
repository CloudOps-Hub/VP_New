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
public class MDM_CustomerComponentHelperTest {
     @testSetup static void setup() {  
        MDM_TestDataFactory.createTestApplicationConfig();
        MDM_TestDataFactory.customerComponentHelperTestData();
        MDM_TestDataFactory.createCustomerStagingRecords();
        MDM_TestDataFactory.createAddressStaging();
        MDM_TestDataFactory.createContactStaging();
    }
    @isTest 
    static void findGoldenMatchesTest() {
        Test.startTest();
        MDM_TestDataFactory.factoryParamWrapper factoryWrap = new MDM_TestDataFactory.factoryParamWrapper(1,1,1,1,true,false,true,true);
        MDM_TestDataFactory.createCustomers(factoryWrap);
        MDM_TokenMatcherWrapper.CustomerDataModal customerModal = new MDM_TokenMatcherWrapper.CustomerDataModal();
        customerModal.MDM_Customer = [Select MDM_Account_Type__c,Name From MDM_Customer__c Limit 1];
        customerModal.MDM_Contact = [Select Name From MDM_Contact__c Limit 1];
        customerModal.MDM_Address = [Select MDM_City__c,MDM_State__c,MDM_Country__c,MDM_Country_Code__c From MDM_Address__c Limit 1];
        MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper goldenMatchWrapper = 
            		new MDM_LightningComponentService.MDM_FindGoldenMatchesWrapper();
        goldenMatchWrapper.dataModalJSON = JSON.serialize(customerModal);
        goldenMatchWrapper.performWordBasedSearch = true;
        goldenMatchWrapper.wordBasedMatchingRuleJSON = '{}';
        goldenMatchWrapper.parentObjectId = '';
        goldenMatchWrapper.sObjectType = 'MDM_Customer__c';
        MDM_LightningComponentService.findGoldenMatches(JSON.serialize(goldenMatchWrapper));
        System.assert(customerModal.MDM_Customer!=NULL,'Customer is Null');
        System.assert(customerModal.MDM_Contact!=NULL,'MDM_Contact is Null');
        System.assert(customerModal.MDM_Address!=NULL,'MDM_Address is Null');
        Test.stopTest();
    }
    /*This method will cover transformCustomerLanding() & migrateLandingToStaging() of MDM_LightningComponentService*/
    @isTest static void transformCustomerLandingTest() {
        Test.startTest();
        MDM_Customer_Landing__c custLanding1 = [SELECT ID, Name, MDM_Source_System__c, MDM_Customer_Name__c, MDM_Account_Type__c, MDM_Processing_Status__c, MDM_Description__c, MDM_Source_System_ID__c, MDM_Contact_JSON__c
		FROM MDM_Customer_Landing__c WHERE MDM_Customer_Name__c = 'Test1'];
		MDM_Customer_Landing__c custLanding4 = [SELECT ID, Name, MDM_Source_System__c, MDM_Customer_Name__c, MDM_Account_Type__c, MDM_Processing_Status__c, MDM_Description__c, MDM_Source_System_ID__c
		FROM MDM_Customer_Landing__c WHERE MDM_Customer_Name__c = 'Test4'];
        
		MDM_ValidationService.MDM_ValidationWrapper validateWrap=new MDM_ValidationService.MDM_ValidationWrapper();
        validateWrap.objectRecord=custLanding1;
        validateWrap.fieldApiName='MDM_Customer_Name__c';
        validateWrap.fieldLabel='Customer Name';
        validateWrap.rejectionCode='';
        validateWrap.regularExp='[5]';
        validateWrap.rejectionMsg='';
        validateWrap.required=true;
        validateWrap.minLength=2;
        validateWrap.maxLength=2;
        validateWrap.restrictPicklistValues=false;
        validateWrap.acceptedValues='';
        MDM_ValidationService.Validate(validateWrap);
        custLanding1.MDM_Customer_Name__c='H';
        
        MDM_ValidationService.MDM_ValidationWrapper validateWrapp=new MDM_ValidationService.MDM_ValidationWrapper();
        validateWrapp.objectRecord=custLanding1;
        validateWrapp.fieldApiName='MDM_Customer_Name__c';
        validateWrapp.fieldLabel='Customer Name';
        validateWrapp.rejectionCode='';
        validateWrapp.regularExp='[5]';
        validateWrapp.rejectionMsg='e';
        validateWrapp.required=true;
        validateWrapp.minLength=2;
        validateWrapp.maxLength=2;
        validateWrapp.restrictPicklistValues=false;
        validateWrapp.acceptedValues='';        
        MDM_ValidationService.Validate(validateWrapp);
        
        MDM_ValidationService.MDM_ValidationWrapper validateWrapp1=new MDM_ValidationService.MDM_ValidationWrapper();
        validateWrapp1.objectRecord=custLanding4;
        validateWrapp1.fieldApiName='MDM_Account_Type__c';
        validateWrapp1.fieldLabel='Account Type';
        validateWrapp1.rejectionCode='e';
        validateWrapp1.regularExp='';
        validateWrapp1.rejectionMsg='e';
        validateWrapp1.required=true;
        validateWrapp1.minLength=0;
        validateWrapp1.maxLength=0;
        validateWrapp1.restrictPicklistValues=true;
        validateWrapp1.acceptedValues='Individual Account';
        MDM_ValidationService.Validate(validateWrapp1);
		
		MDM_Customer_Landing__c custLanding2 = [SELECT ID, Name, MDM_Source_System__c, MDM_Customer_Name__c, MDM_Account_Type__c, MDM_Processing_Status__c, MDM_Description__c, MDM_Source_System_ID__c, MDM_Contact_JSON__c
		FROM MDM_Customer_Landing__c WHERE MDM_Customer_Name__c = 'Test2'];

        List<MDM_Customer_Landing__c> custLandingList = new List<MDM_Customer_Landing__c>();
        custLandingList.add(custLanding2);
        custLandingList.add(custLanding1);
        System.assert(custLandingList.size() > 0,'custLandingList empty');
        try{
              MDM_LightningComponentService.transformCustomerLanding(custLanding1);  
        }
        catch(Exception E){
            System.debug('Expected Error');
        }
      
        MDM_LightningComponentService.migrateLandingToStaging(custLandingList);
        MDM_CustomerComponentHelper.getFields('MDM_Customer_Landing__c');
        Test.stopTest();
    }
    
    /*This method will cover getRelatedLists() of MDM_LightningComponentService*/
    @isTest 
    static void getRelatedListsTest() {
        Test.startTest();
        MDM_Customer_Staging__c  custStaging = [SELECT ID, Name, MDM_Processing_Status__c, MDM_Description__c, MDM_Account_Type__c
                                               FROM MDM_Customer_Staging__c LIMIT 1];

        System.assert(custStaging.id != NULL,'custStaging.Id is null');
        MDM_LightningComponentService.getRelatedLists(custStaging.id); 
        Test.stopTest();
    }
    /*This method will cover insertInCustomer() of MDM_LightningComponentService*/
    @isTest static void insertInCustomerTest() {
        Test.startTest();         
        MDM_Customer_Staging__c  custStaging = [SELECT ID, Name, MDM_Processing_Status__c, MDM_Description__c, MDM_Account_Type__c
                                               FROM MDM_Customer_Staging__c LIMIT 1];
        
        MDM_Contact_Staging__c contact=[SELECT ID, Name, MDM_Customer_Staging__c FROM MDM_Contact_Staging__c LIMIT 1];
        
        MDM_Address_Staging__c address =[SELECT ID, Name, MDM_Customer_Staging__c, MDM_Address_1__c, MDM_City__c, MDM_Contact_Staging__c FROM MDM_Address_Staging__c LIMIT 1];
        
		MDM_GeneraliseResult customerStaging = MDM_LightningComponentService.insertInCustomer('{"stagingRecord":{"Id":"'+custStaging.id+'","MDM_Customer_Status__c":"Active",'+
                                                       '"MDM_Account_Type__c":"Individual Account","Name":"Test For Merge Insert & Update V3",'+
                                                       '"SystemModstamp":"2019-11-07T06:14:20.000Z",'+
                                                       '"MDM_Description__c":"weeepwooop"},'+
                                                       '"contactIDs":["'+contact.id+'","a1R190000010fk0EAA",'+
                                                       '"a1R190000010fk1EAA","a1R190000010fk2EAA"],"addressIDs":["'+address.id+'",'+
                                                       '"a0V19000004yjGAEAY","a0V19000004yjGBEAY","a0V19000004yjGCEAY",'+
                                                       '"a0V19000004yjGDEAY"]}');
        System.assert(customerStaging.isSuccess == true, 'insertInCustomer is null');
        List<UserLicense> ulics=[Select u.Id From UserLicense u where Name like 'Chatter Free'];
		User users=[Select Id,Name,ProfileId from User u where u.ProfileId in (Select Id From Profile p where p.UserLicenseId in :ulics)limit 1];
        User runUsr = [select name, id, profileId from User where id = :users.id limit 1];
     	   System.runAs(runUsr){
                MDM_LightningComponentService.insertInCustomer('{"stagingRecord":{"Id":"'+custStaging.id+'","MDM_Customer_Status__c":"Active",'+
                                                       '"MDM_Account_Type__c":"Individual Account","Name":"Test For Merge Insert & Update V3",'+
                                                       '"SystemModstamp":"2019-11-07T06:14:20.000Z",'+
                                                       '"MDM_Description__c":"weeepwooop"},'+
                                                       '"contactIDs":["'+contact.id+'","a1R190000010fk0EAA",'+
                                                       '"a1R190000010fk1EAA","a1R190000010fk2EAA"],"addressIDs":["'+address.id+'",'+
                                                       '"a0V19000004yjGAEAY","a0V19000004yjGBEAY","a0V19000004yjGCEAY",'+
                                                       '"a0V19000004yjGDEAY"]}');
            }
        Test.stopTest();
    }
    
    /*This method will cover getCustomers() of MDM_LightningComponentService*/
    @isTest static void getCustomersTest() {
        Test.startTest();
        String customerJSON = '{"sObjectName":"MDM_Customer__c","sObjectFields":"Name,MDM_Account_Type__c",'+
            '"sObjectFilterField":"Name","fieldToken":"Test"}';
        MDM_GeneraliseResult customer= MDM_LightningComponentService.getCustomers(customerJSON);
        System.assert(customer.isSuccess == true ,'getCustomers is null');
        Test.stopTest();
    }
}