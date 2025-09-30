/**
* @description       : 
* @author            : Dhruv Agrawal
* @group             : 
* @last modified on  : 05-20-2021
* @last modified by  : Dhruv Agrawal
* Modifications Log 
* Ver   Date         Author         Modification
* 1.0   05-06-2021   Dhruv Agrawal   Initial Version
**/
@isTest
public class MDM_PublishCustomerPlatformEventsJobTest {
    @testSetup static void setup() {
        MDM_TestDataFactory.createCustomer();
    }
    static testMethod void testMethod1() 
    {
        MDM_Customer__c customerRecord = [SELECT Id, Name, MDM_Account_Type__c, MDM_Customer_Status__c
                                          FROM MDM_Customer__c LIMIT 1];
        customerRecord.Name='Test Staging';
        customerRecord.MDM_Account_Type__c='Individual Account';
        customerRecord.MDM_Email__c ='test@cree.com';
        customerRecord.MDM_DOI_or_DOB__c = System.today();
        customerRecord.MDM_Record_Status__c = 'Published';
        customerRecord.MDM_Customer_Status__c = 'Active';
        update customerRecord;
        Test.startTest();
        MDM_PublishCustomerPlatformEventsJob obj = new MDM_PublishCustomerPlatformEventsJob(0,true);
        String bc = DataBase.executeBatch(obj,1);
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