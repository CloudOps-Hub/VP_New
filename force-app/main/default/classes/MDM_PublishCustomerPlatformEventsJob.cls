/**
 * @description       : 
 * @author            : Priya Sharma
 * @group             : 
 * @last modified on  : 05-27-2021
 * @last modified by  : Komal Sonsale
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   04-16-2021   Priya Sharma   Initial Version
**/

global class MDM_PublishCustomerPlatformEventsJob implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    public Integer numberOfRetryAttempts; 
    public Boolean publishPlatformEvents; 
    /**
    * @description This is a constructor
    * @param numberOfRetryAttempts
    * @param publishPlatformEvents
    */
    global MDM_PublishCustomerPlatformEventsJob(Integer numberOfRetryAttempts, Boolean publishPlatformEvents) {
        this.numberOfRetryAttempts = numberOfRetryAttempts; 
        this.publishPlatformEvents = publishPlatformEvents; 
    }
    /**
    * @description This Function returns record list that were updated/created in previous n minutes
    * @param bc
    * @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String recordStatus;
        recordStatus = 'Published';
        String query = 'SELECT Id FROM MDM_Customer__c WHERE ' +
            ' MDM_Account_Type__c != NULL AND MDM_Customer_Status__c != NULL' + 
            ' AND MDM_Record_Status__c = :recordStatus';
        return Database.getQueryLocator(query);
    }
    /**
    * @description This Function publishes the events
    * @param bc
    * @param customerIdList  
    */
    global void execute(Database.BatchableContext bc, List<MDM_Customer__c> customerIdList) {
        List<MDM_Customer_Create_Update__e> customerCreateUpdateEvents = new List<MDM_Customer_Create_Update__e>();
        List<MDM_Customer_Create_Update__e> customerEventsTobePublishedList = new List<MDM_Customer_Create_Update__e>();
        //fetch customers that were created or updated in last 10 minutes
       
        List<MDM_Customer__c> customers = [
            Select ID, Name,MDM_Id__c, MDM_Customer_Status__c, MDM_Account_Type__c, LastModifiedDate, CreatedDate,  MDM_Pending_Platform_Event__c, (
                SELECT MDM_Source_System_Id__c, Name, MDM_Source_System__c FROM Source_Customers__r LIMIT 200
            ) 
            From MDM_Customer__c 
            WHERE Id IN :customerIdList
            ORDER BY MDM_Id__c NULLS LAST
        ];
        //create events for each customer fetched
        for(MDM_Customer__c customer: customers) {
            MDM_Customer_Create_Update__e customerCreateUpdateEvent = new MDM_Customer_Create_Update__e();
            customerCreateUpdateEvent.MDM_Id__c = customer.MDM_Id__c;
            customerCreateUpdateEvent.MDM_Name__c = customer.Name;
            customerCreateUpdateEvent.MDM_Event__c = (customer.LastModifiedDate == customer.CreatedDate?'create':'update');
            customerCreateUpdateEvent.MDM_Status__c = customer.MDM_Customer_Status__c;
            customerCreateUpdateEvent.MDM_Customer_Type__c = customer.MDM_Account_Type__c;
            customerCreateUpdateEvent.MDM_External_Ids__c = customer.Source_Customers__r.isEmpty()?NULL:JSON.serialize(customer.Source_Customers__r);
            customerCreateUpdateEvent.MDM_Customer_Created_Date__c = customer.CreatedDate;
            customerCreateUpdateEvent.MDM_Customer_Last_Modified_Date__c = customer.LastModifiedDate;
            customerCreateUpdateEvents.add(customerCreateUpdateEvent);
            if(customer.MDM_Pending_Platform_Event__c) { customerEventsTobePublishedList.add(customerCreateUpdateEvent); }
            customer.MDM_Pending_Platform_Event__c = false;
        }
        
        if(publishPlatformEvents) {
            Eventbus.publish(customerEventsTobePublishedList);
            MDM_NotificationFlagHelper.enableUpdate = false;
            update customers;
        }     
    }
    /**
    * @description This Function finishes the execution of Platform Event Job
    * @param bc
    */
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job;
        job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        
    }
}