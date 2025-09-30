/**
 * @description       : 
 * @author            : Dhruv Agrawal
 * @group             : 
 * @last modified on  : 05-28-2021
 * @last modified by  : Dhruv Agrawal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   03-23-2021   Dhruv Agrawal   Initial Version
**/
public with sharing class MDM_CustomerStagingTriggerHelper {
    
    /**
    * @description : This method calls functions based on condition
    * @param triggerWrapper 
    **/
    public static void triggerConditionForMethodInvoke(MDM_TriggerWrapper triggerWrapper){
        if(triggerWrapper.isBefore){
            if(triggerWrapper.isDelete){ deleteStagingObjectRecord(triggerWrapper); }
            if(trigger.isInsert || trigger.isUpdate){
                setAutoMergeCriteria(triggerWrapper);
            }
        }
    }
   
    
    
    /**
    * @description : This prevents deleting Contact Staging record if Status is 'Processed'
    * @param triggerWrapper 
    **/
    public static void deleteContactStaging(MDM_TriggerWrapper triggerWrapper){
        if(Schema.sObjectType.MDM_Contact_Staging__c.isAccessible()) {
            for (MDM_Contact_Staging__c contactStaging :[
            select MDM_Customer_Staging__r.MDM_Processing_Status__c from MDM_Contact_Staging__c 
            where id in :triggerWrapper.oldSObjectMap.keyset() WITH SECURITY_ENFORCED
            ]){
                if(contactStaging.MDM_Customer_Staging__r.MDM_Processing_Status__c=='Processed') {
                    triggerWrapper.oldSObjectMap.get(contactStaging.ID).addError('Contact cannot be deleted for Processed requests');
                }
            }
        }
    }
    
    /**
    * @description : Prevent deleting Address Staging record if Status is 'Processed'
    * @param triggerWrapper 
    **/
    public static void deleteAddressStaging(MDM_TriggerWrapper triggerWrapper){
        if(Schema.sObjectType.MDM_Address_Staging__c.isAccessible()) {
            for (MDM_Address_Staging__c addressStaging :[
                select MDM_Customer_Staging__r.MDM_Processing_Status__c from MDM_Address_Staging__c 
                where id in :triggerWrapper.oldSObjectMap.keyset() WITH SECURITY_ENFORCED
            ]){
                if(addressStaging.MDM_Customer_Staging__r.MDM_Processing_Status__c=='Processed') {
                    triggerWrapper.oldSObjectMap.get(addressStaging.ID).addError('Address cannot be deleted for Processed requests');
                }
            }
        }
    }
   
    /**
    * @description : Prevent deleting Customer Staging object if Status is 'Processed'
    * @param triggerWrapper 
    **/
    public static void deleteStagingObjectRecord(MDM_TriggerWrapper triggerWrapper){
        for(SObject stagingRecord : triggerWrapper.oldSObjectList){
            if(stagingRecord.get('MDM_Processing_Status__c')=='Processed') { stagingRecord.addError('Processed Requests can not be deleted'); }
        }       
    }
    
    /**
    * @description 
    * @author Dhruv Agrawal | 05-28-2021 
    * @param triggerWrapper 
    **/
    public static void setAutoMergeCriteria(MDM_TriggerWrapper triggerWrapper){
        List<MDM_Customer_Staging__c> stagingList = triggerWrapper.newSObjectList;
        List<MDM_Application_Configuration__c> appConfig = new List<MDM_Application_Configuration__c>();
        try{
            appConfig = [Select id,MDM_Allow_Auto_Merge__c
            from MDM_Application_Configuration__c 
            WITH SECURITY_ENFORCED limit 1];
        }
        catch(Exception E){
            MDM_HandleCustomException.logException(e);
        }
            
        for(MDM_Customer_Staging__c custStaging:stagingList){
            if(custStaging.MDM_Manual_Merge_Allowed__c == false  && appConfig.size() > 0)
            {custStaging.MDM_is_AutoMerge__c = appConfig[0].MDM_Allow_Auto_Merge__c;}
            else if(custStaging.MDM_Manual_Merge_Allowed__c == true)
            {custStaging.MDM_is_AutoMerge__c = false;}
        } 
    }
}